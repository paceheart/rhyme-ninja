#!/usr/bin/env ruby

# Preprocess the cmudict data into a format that's efficient for looking up rhyming words.
# Assumes cmudict.json is in the current directory. Writes out rhyme_signature_dict.json to the current directory.
#
# We use a two-step lookup process to avoid storing lots of redundant data, e.g. all 500+ "-ation" rhymes as values for "elation", "consternation", etc.
# Step 1: Given a word, use the CMU Pronouncing Data to get its pronunciation.
# Step 1.5: Get the word's rhyme signature
# Step 2: Given the rhyme signature, look up all words that rhyme with it (including itself)
# Step 2.5: Filter out bad rhymes, like the word itself and subwords (e.g. important rhyming with unimportant)
# build_rhyme_signature_dict builds the dictionary used in Step 2.
#
# We could improve performance even more by assigning an arbitrary index 0..N
# to each rhyme signature, having a list of those be the keys for Dict 1, and
# having Step 2 be an array lookup instead of a hash lookup.

require 'json'
require 'rwordnet'
require_relative 'utils_rhyme'

WordNet::DB.path = "WordNet3.1/"
WORDNET_TAGSENSE_COUNT_MULTIPLICATION_FACTOR = 100 # each tagsense_count from wordnet counts as this many occurrences in some corpus

STOP_WORDS = ["i", "me", "my", "myself", "we", "our", "ours", "ourselves", "you", "your", "yours", "yourself", "yourselves", "he", "him", "his", "himself", "she", "her", "hers", "herself", "it", "its", "itself", "they", "them", "their", "theirs", "themself", "themselves", "what", "which", "who", "whom", "this", "that", "these", "those", "am", "is", "are", "was", "were", "be", "been", "being", "have", "has", "had", "having", "do", "does", "did", "doing", "a", "an", "the", "and", "but", "if", "or", "because", "as", "until", "while", "of", "at", "by", "for", "with", "about", "against", "between", "into", "through", "during", "before", "after", "above", "below", "to", "from", "up", "down", "in", "out", "on", "off", "over", "under", "again", "further", "then", "once", "here", "there", "when", "where", "why", "how", "all", "any", "both", "each", "few", "more", "most", "other", "some", "such", "no", "nor", "not", "only", "own", "same", "so", "than", "too", "very", "can", "will", "just", "dont", "should", "now"] # from https://gist.github.com/sebleier/554280, removed "s" "t", added "themself", and changed "don" to "dont"

#
# parse cmudict
#

def delete_blacklisted_words(cmudict)
  count = 0
  for bad_word in blacklist
    if(cmudict.delete(bad_word.chop))
      count = count + 1
    end
  end
  puts "Removed #{count} blacklisted words from the dictionary"
end

def useful_cmudict_line?(line)
  # ignore entries that start with comment characters, punctuation, or numbers
  if(line =~ /\A'/)
    whitelisted_apostrophe_words = ["'allo", "'bout", "'cause", "'em", "'til", "'tis", "'twas", "'kay", "'gain"] # most of the words in cmudict that begin with an apostrophe are shit, but these are okay.
    whitelisted_apostrophe_words.include?(line.split.shift.downcase)
  else
    line =~ /\A[[A-Z]]/
  end
rescue ArgumentError => error
  false
end

def preprocess_cmudict_line(line)
  # merge some similar-enough-sounding syllables
  line = line.chop()
  line = line.gsub("IH1 R", "IY1 R") # ear [IY1 R] rhymes with beer [IH1 R]
  line = line.gsub("IH2 R", "IY2 R")
  line = line.gsub("IH0 R", "IY0 R")
  return line
end

def load_cmudict()
  # word => [pronunciation1, pronunciation2 ...]
  # pronunciation = [syllable1, syllable1, ...]
  hash = Hash.new {|h,k| h[k] = [] } # hash of arrays
  IO.readlines("cmudict/cmudict-0.7c.txt").each{ |line|
    if(useful_cmudict_line?(line))
      line = preprocess_cmudict_line(line)
      tokens = line.split
      word = tokens.shift.downcase # now TOKENS contains only syllables
      word = word.gsub("_", " ")
      if(word =~ /\([0-9]\)\Z/)
        word = word[0...-3]
      end
      hash[word].push(tokens)
    else
      puts "Ignoring cmudict line: #{line}"
    end
  }
  puts "Loaded #{hash.length} words from cmudict"
  return hash
end

#
# parse blacklist
#

$blacklist = nil
def blacklist()
  if $blacklist.nil?
    $blacklist = load_blacklist_as_array
  end
  return $blacklist
end

def load_blacklist_as_array
  return IO.readlines("blacklist.txt")
end

#
# parse lemma dict
#

def load_lemma_dict()
  lemmahash = Hash.new # word form => base word (lemma)
  freqhash = Hash.new(0) # hash of numbers (word occurrence frequencies), default 0
  wordcount = 0
  IO.readlines("lemma_en/lemma.en.txt").each{ |line|
    if(useful_lemma_dict_line?(line))
      line.chop!
      wordcount += 1
      entry, altforms_str = line.split(' -> ')
      word, freq_str = entry.split('/')
      # update lemmehash
      for altform in altforms_str.split(',')
        lemmahash[altform] = word
      end
      # update freqhash
      if(freq_str)
        freq = freq_str.to_i
      else
        freq = 1
      end
      freqhash[word] += freq
      for altform in altforms_str.split(',')
        freqhash[altform] += freq
      end
    else
      puts "Ignoring lemma_dict line: #{line}"
    end
  }
  # this slightly overcounts because it double-counts altforms that are the same as lemma
  puts "Mapped #{lemmahash.length + wordcount} words to #{wordcount} lemmas"
  puts "Loaded #{freqhash.length} words from the frequency data"
  return lemmahash, freqhash
end

def useful_lemma_dict_line?(line)
  # comments are not useful
  return !(line =~ /\A;/)
end

#
# WordNet
#

def wn_frequency(word, lemmadict)
  frequency = 0
  lemmas = WordNet::Lemma.find_all(word)
  # If you didn't find it, try using the lemmadict to get the base form of WORD
  if(lemmas.empty?)
    base_word = lemmadict[word]
    if(base_word)
      lemmas = WordNet::Lemma.find_all(base_word)
    end
  end
  lemmas.each { |lemma|
    frequency += lemma.tagsense_count * WORDNET_TAGSENSE_COUNT_MULTIPLICATION_FACTOR
  }
  return frequency
end

#
# put it all together
#

def build_rhyme_signature_dict(cmudict)
  rdict = Hash.new {|h,k| h[k] = [] } # hash of arrays
  i = 0;
  for word, prons in cmudict
    for pron in prons
      rsig = rhyme_signature(pron)
      rdict[rsig].push(word)
    end
    i = i + 1;
  end
  # sort, and remove duplicate words
  for rsig, words in rdict
    new_words = words.sort.uniq
    if(new_words.nil?)
      rdict.delete(rsig)
    else
      rdict[rsig] = new_words
    end
  end
  print "Identified #{rdict.length} unique rhyme signatures, "
  rdict = rdict.reject!{|rsig, words| words.length <= 1 }
  puts "#{rdict.length} of which are nonempty"
  return rdict
end

def filter_cmudict(cmudict, rdict)
  filtered_cmudict = Hash.new {|h,k| h[k] = [] } # hash of arrays. We don't need the whole cmudict, just the words with at least one rhyme.
  for word, prons in cmudict
    for pron in prons
      rsig = rhyme_signature(pron)
      if(!rdict[rsig].empty?)
        filtered_cmudict[word].push(pron)
      end
    end
  end
  puts "#{filtered_cmudict.length} entries remain in the pronunciation dictionary after removing words with no rhymes"
  return filtered_cmudict
end

def add_frequency_info(cmudict, lemmadict, freqdict)
  count = 0;
  hash = Hash.new
  for word, prons in cmudict
    freqdict_freq = freqdict[word] || 0
    wn_freq = wn_frequency(word, lemmadict)
    if(STOP_WORDS.include?(word))
      freq = 999999 # very common
    else
      freq = freqdict_freq + wn_freq
    end
    # including freqdict_freq has the pro of including good things like
    #   bettor 1, holy 2994, mod 456, paroled 237, saffron 180, slacker 561, trillion 1, vanes 153
    # at the cost of including some crap and proper nouns like
    #   nardo 1, bors 27, matias 2, soweto 96, steinman 1
    # A random sample of 15 words with a freqdict_freq of 1 yielded:
    #   5 good: gasoline (wn 1), chicanery, noncombatants, propagandize, psilocybin
    #   1 whatever: parimutuel (wn 1)
    #   5 names: adam (wn 1), ciardi, cydonia, tuscaloosa, walter
    #   2 initialisms: cctv, ni
    #   2 rare: junco, stylites
    # Only a third of them are good. Is it worth adding 2/3 crap to get the 1/3 good?
    if(freq > 0)
      count += 1
    end
    entry = [freq, prons]
    hash[word] = entry
  end
  puts "#{count} of those entries have frequency data"
  hash
end

def build_word_dict(cmudict, lemmadict, freqdict, rdict)
  cmudict = filter_cmudict(cmudict,rdict) # we only care about the words with entries in rdict
  add_frequency_info(cmudict, lemmadict, freqdict)
end

def rebuild_rhyme_ninja_dictionaries()
  cmudict = load_cmudict
  delete_blacklisted_words(cmudict)
  rdict = build_rhyme_signature_dict(cmudict)
  File.open("rhyme_signature_dict.json", "w") do |f|
    f.write(rdict.to_json)
  end
  lemma_dict, freq_dict = load_lemma_dict
  word_dict = build_word_dict(cmudict, lemma_dict, freq_dict, rdict)
  File.open("word_dict.json", "w") do |f|
    f.write(word_dict.to_json)
  end
end

rebuild_rhyme_ninja_dictionaries
