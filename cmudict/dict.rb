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

$cmudict = nil
def cmudict()
  if $cmudict.nil?
    $cmudict = load_cmudict_as_hash
  end
  $cmudict
end

def load_cmudict_as_hash()
  # word => [pronunciation1, pronunciation2 ...]
  # pronunciation = [syllable1, syllable1, ...]
  JSON.parse(File.read("cmudict.json"))
end

# note copied from rhyme.rb, @todo refactor
def rhyme_signature_array(pron)
  # The rhyme signature is everything including and after the final fully stressed vowel,
  # which is indicated in cmudict by a "1"
  # input: [IH0 N S IH1 ZH AH0 N] # the pronunciation of 'incision'
  # output: [IH1 ZH AH0 N] # the pronunciation of '-ision'
  rsig = Array.new
  pron.reverse.each { |syl|
    rsig.unshift(syl) # prepend
    if(syl.include?("1"))
      break # we found the main stressed syllable, we can stop now
    end
  }
  rsig
end

# note copied from rhyme.rb, @todo refactor
def rhyme_signature(pron)
  # this makes for a better hash key
  rhyme_signature_array(pron).join(" ")
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
  # remove all words that don't rhyme with anything
  rdict = rdict.reject!{|rsig, words| words.length <= 1 }
  rdict
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
  filtered_cmudict
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
