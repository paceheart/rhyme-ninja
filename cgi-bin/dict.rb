#!/usr/bin/env ruby
# Once we know the data format we want, we'll want to preprocess the cmudict data into that format, then save it.

require 'json'

$cmudict = Hash.new

def load_cmudict_as_hash()
  # word => [pronunciation1, pronunciation2 ...]
  # pronunciation = [syllable1, syllable1, ...]
  JSON.parse(File.read("cmudict.json"))
end

def rhyme_signature(pron)
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

def build_rhyme_signature_dict()
  rdict = Hash.new {|h,k| h[k] = [] } # hash of arrays
  i = 0;
  for word, prons in $cmudict
    for pron in prons
      rsig = rhyme_signature(pron)
      rdict[rsig].push(word)
    end
    i = i + 1;
    if(i > 2120)
      break # for testing
    end
  end
  # sort, and remove duplicate words
  for rsig, words in rdict
    new_words = words.sort!.uniq!
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

def build_signature_rhymes_dict()
end
  
$cmudict = load_cmudict_as_hash
#puts $cmudict["nunnery"][0]
#puts rhyme_signature($cmudict["nunnery"][0])

puts build_rhyme_signature_dict
