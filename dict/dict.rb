#!/usr/bin/env ruby

TRACE_WORD = nil

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

#
# parse cmudict
#

def delete_blacklisted_keys_from_hash(cmudict)
  count = 0
  for bad_word in blacklist
    if(cmudict.delete(bad_word.chomp))
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
  line = line.chomp()
  line = line.gsub("IH1 R", "IY1 R") # ear [IY R] rhymes with beer [IH R]
  line = line.gsub("IH2 R", "IY2 R")
  line = line.gsub("IH0 R", "IY0 R")
  # imperfect rhymes. @todo allow this to be toggleable at runtime instead of dictionary-building time
  line = line.gsub(" AO", " AA") # caught [AA T] rhymes with fought [AO T]
  line = line.gsub("N D Z", "N Z") # make tons [T AH1 N Z] rhyme with funds [F AH1 N D Z] 
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
      if(!(word =~ /\d/) || word == "w00t") # ignore words containing digits, except w00t
        hash[word].push(tokens)
        if(word == TRACE_WORD)
          puts "TRACE Loaded #{word} as #{tokens}"
        end
      else
        puts "filtered out #{word}"
      end
    else
      puts "Ignoring cmudict line: #{line}"
    end
  }
  puts "Loaded #{hash.length} words from cmudict"
  return hash
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
      line.chomp!
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
    # +1 because words get a boost just from being in WordNet at all
    frequency += (lemma.tagsense_count + 1) * WORDNET_TAGSENSE_COUNT_MULTIPLICATION_FACTOR
    if(word == TRACE_WORD)
      puts "TRACE lemma #{lemma.inspect}, tagsense_count = #{lemma.tagsense_count}, wn_frequency = #{frequency}"
    end
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
  # filter out pronunciations with no rhymes
  filtered_cmudict = Hash.new
  proncount = 0
  total = 0
  for word, prons in cmudict
    filtered_cmudict[word] = Array.new # we still want entries for words with no pronunciations, though, in case they have frequency data
    if(word == TRACE_WORD)
      puts "TRACE prons = #{prons}"
    end
    for pron in prons
      total += 1
      rsig = rhyme_signature(pron)
      if(!rdict[rsig].empty?)
        proncount += 1
        filtered_cmudict[word].push(pron)
        if(word == TRACE_WORD)
          puts "TRACE #{pron} passed filters because it rhymes with #{rdict[rsig]}"
        end
      end
    end
  end
  puts "#{proncount} out of #{total} pronunciations remain in the dictionary after removing pronunciations with no rhymes"
  return filtered_cmudict
end

def filter_word_dict(word_dict)
  filtered_word_dict = Hash.new
  for word, entry in word_dict
    freq, prons = entry
    if(!prons.empty? || freq > 0)
      filtered_word_dict[word] = entry
      if(word == TRACE_WORD)
        puts "TRACE freq #{freq} passed filters"
      end
    end
  end
  puts "#{filtered_word_dict.length} out of #{word_dict.length} entries remain in the dictionary after removing words with no rhymes and zero frequency"
  return filtered_word_dict
end

def add_frequency_info(cmudict, lemmadict, freqdict)
  count = 0;
  hash = Hash.new
  for word, prons in cmudict
    freqdict_freq = freqdict[word] || 0
    wn_freq = wn_frequency(word, lemmadict)
    if(stop_word?(word))
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
  return hash
end

def build_word_dict(cmudict, lemmadict, freqdict, rdict)
  cmudict = filter_cmudict(cmudict,rdict)
  word_dict = add_frequency_info(cmudict, lemmadict, freqdict)
  return filter_word_dict(word_dict)
end

def rebuild_rhyme_ninja_dictionaries()
  cmudict = load_cmudict
  delete_blacklisted_keys_from_hash(cmudict)
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
