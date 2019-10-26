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
require_relative 'utils_rhyme'

$cmudict = nil
def cmudict()
  if $cmudict.nil?
    $cmudict = load_cmudict_as_hash
    puts "Loaded #{$cmudict.length} words from cmudict"
    delete_blacklisted_words_from_cmudict
  end
  $cmudict
end

def delete_blacklisted_words_from_cmudict()
  count = 0
  for bad_word in blacklist
    if($cmudict.delete(bad_word.chop))
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

def preprocess_line(line)
  # merge some similar-enough-sounding syllables
  line = line.chop()
  line = line.gsub("IH1 R", "IY1 R") # ear [IY1 R] rhymes with beer [IH1 R]
  line = line.gsub("IH2 R", "IY2 R")
  line = line.gsub("IH0 R", "IY0 R")
  return line
end

def load_cmudict_as_hash()
  # word => [pronunciation1, pronunciation2 ...]
  # pronunciation = [syllable1, syllable1, ...]
  hash = Hash.new {|h,k| h[k] = [] } # hash of arrays
  IO.readlines("cmudict-0.7c.txt").each{ |line|
    if(useful_cmudict_line?(line))
      line = preprocess_line(line)
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
  return hash
end

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

def build_rhyme_signature_dict()
  rdict = Hash.new {|h,k| h[k] = [] } # hash of arrays
  i = 0;
  for word, prons in cmudict
    for pron in prons
      rsig = rhyme_signature(pron)
      rdict[rsig].push(word)
    end
    i = i + 1;
    if(i > 99999999999)
      break # for testing
    end
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

def filter_cmudict(rdict)
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

def rebuild_rhyme_ninja_dictionaries()
  rdict = build_rhyme_signature_dict
  File.open("rhyme_signature_dict.json", "w") do |f|
    f.write(rdict.to_json)
  end
  File.open("filtered_cmudict.json", "w") do |f|
    f.write(filter_cmudict(rdict).to_json)
  end
end

rebuild_rhyme_ninja_dictionaries
