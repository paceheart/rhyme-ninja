#!/usr/bin/env ruby

require 'cgi'
require 'net/http'
require 'uri'
require 'json'

DEBUG_MODE = false
$datamuse_max = 400

def debug(string)
  if(DEBUG_MODE)
    puts string
  end
end

#
# Local rhyme computation
#

$cmudict = nil
def cmudict()
  # word => [pronunciation1, pronunciation2 ...]
  # pronunciation = [syllable1, syllable1, ...]
  if $cmudict.nil?
    $cmudict = load_filtered_cmudict_as_hash
  end
  $cmudict
end

$rdict = nil # rhyme signature -> words hash
def rdict
  # rhyme_signature => [rhyming_word1 rhyming_word2 ...]
  # where rhyme_signature = "syllable1 syllable2 ..."
  if $rdict.nil?
    $rdict = load_rhyme_signature_dict_as_hash
  end
  $rdict
end

def load_filtered_cmudict_as_hash()
  JSON.parse(File.read("filtered_cmudict.json"))
end

def load_rhyme_signature_dict_as_hash()
  JSON.parse(File.read("rhyme_signature_dict.json"))
end

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

def rhyme_signature(pron)
  # this makes for a better hash key
  rhyme_signature_array(pron).join(" ")
end

def pronunciations(word)
  cmudict[word] || [ ]
end

def rdict_lookup(rsig)
  rdict[rsig] || [ ]
end

def find_rhyming_words(word)
  # use our local dictionaries, we don't need the Datamuse API for simple rhyme lookup
  results = Array.new
  pronunciations(word).each { |pron|
    rsig = rhyme_signature(pron)
    rdict_lookup(rsig).each { |rhyme|
      unless is_stupid_rhyme(word, rhyme)
        results.push(rhyme)
      end
    }
  }
  results || [ ]
end

def is_stupid_rhyme(word, rhyme)
  word.include?(rhyme) or rhyme.include?(word)
end

#
# Datamuse stuff
#

def results_to_words(results)
  words = [ ]
  results.each { |result|
    words.push(result["word"])
  }
  words
end
  
def find_related_words(word)
  words = results_to_words(find_datamuse_results("", word))
  words.push(word) # every word is related to itself
end

def find_datamuse_results(rhyme, rel)
  request = "https://api.datamuse.com/words?"
  if(rhyme != "")
    request += "rel_rhy=#{rhyme}&";
  end
  if(rel != "")
    request += "ml=#{rel}&";
  end
  if($datamuse_max != 100) # 100 is the default
    request += "max=#{$datamuse_max}" # no trailing &, must be the last thing
  end
  request = URI.escape(request)

  debug "#{request}<br/><br/>";
  uri = URI.parse(request);
  response = Net::HTTP.get_response(uri)
  if(response.body() != "")
    JSON.parse(response.body());
  else
    # @todo refactor
    puts "Error connecting to Datamuse API: #{request} <br> Try again later."
    abort
  end
end

def find_words(rhyme, rel)
  results_to_words(find_datamuse_results(rhyme, rel))
end

def find_rhyming_tuples(input_rel1)
  # Rhyming word sets that are related to INPUT_REL1.
  # Each element of the returned array is an array of words that rhyme with each other and are all related to INPUT_REL1.
  related_rhymes = Hash.new {|h,k| h[k] = [] } # hash of arrays
  relateds1 = find_related_words(input_rel1)
  apiCount = 0;
  relateds1.each { |rel1|
    debug "rhymes for #{rel1}:<br>"
    find_rhyming_words(rel1).each { |rhyme1|
      if(relateds1.include? rhyme1) # we only care about relateds of input_rel1
        related_rhymes[rel1].push(rhyme1)
        debug rhyme1;
      end
    }
    debug "<br><br>"
  }
  tuples = [ ]
  related_rhymes.each { |relrhyme1, relrhyme_rest|
    if(!relrhyme_rest.empty?)
      relrhyme_rest.push(relrhyme1) # relrhyme_rest is now relrhymes_all
      tuples.push(relrhyme_rest.sort!)
    end
  }
  tuples.sort!().uniq()
end

def find_rhyming_pairs(input_rel1, input_rel2)
  # Pairs of rhyming words where the first word is related to INPUT_REL1 and the second word is related to INPUT_REL2
  # Each element of the returned array is a pair of rhyming words [W1 W2] where W1 is related to INPUT_REL1 and W2 is related to INPUT_REL2
  related_rhymes = Hash.new {|h,k| h[k] = [] } # hash of arrays
  relateds1 = find_related_words(input_rel1)
  relateds2 = find_related_words(input_rel2)
  apiCount = 0;
  relateds1.each { |rel1|
    # rel1 is a word related to input_rel1. We're looking for rhyming pairs [rel1 rel2].
    debug "rhymes for #{rel1}:<br>"
    # If we find a word 'RHYME' that rhymes with rel1 and is related to input_rel2, we win!
    find_rhyming_words(rel1).each { |rhyme| # check all rhymes of rel1, call each one 'RHYME'
      if(relateds2.include? rhyme) # is RHYME related to input_rel2? If so, we win!
        related_rhymes[rel1].push(rhyme)
        debug rhyme;
      end
    }
    debug "<br><br>"
  }
  pairs = [ ]
  related_rhymes.each { |relrhyme1, relrhyme2_list|
    if(!relrhyme2_list.empty?)
      relrhyme2_list.each { |relrhyme2|
        pairs.push([relrhyme1, relrhyme2])
      }
    end
  }
  pairs.sort!().uniq()
end

#
# Main loop and display
#

def print_tuple(tuple)
  # print TUPLE separated by slashes
  i = 0
  tuple.each { |elem|
    if(i > 0)
      print " / "
    end
    print elem
    i += 1
  }
  STDOUT.flush
end

def print_tuples(tuples)
  # return boolean, did I print anything? i.e. was TUPLES nonempty?
  success = !tuples.empty?
  if(success)
    tuples.each { |tuple|
      print_tuple(tuple)
      puts "<br>"
    }
  end
  success
end

def print_words(words)
  success = !words.empty?
  if(success)
    words.each { |word|
      puts word
      puts "<br>"
    }
  end
  success
end

def be_a_ninja(word1, word2, goal)
  # return SUCCESS?

  # special cases
  if(word1 == "" and word2 == "")
    return true # vacuous success, no need to say "No matching results"
  end
  if(word1 == "" and word2 != "")
    word1, word2 = word2, word1
  end
  if(word1 == "smiley" and word2 == "love" and goal == "related_rhymes")
    puts "<font size=80><bold>KYELI!</bold></font>"; # easter egg for Kyeli
    return true
  end

  # @todo  if(word1.include?(" "))

  # main list of cases
  case goal
  when "rhymes"
    puts "Rhymes for \"<b>#{word1}</b>\":<br><br>"
    print_words(find_words(word1, ""))
  when "related"
    puts "Words conceptually related to \"<b>#{word1}:</b>\":<br><br>"
    print_words(find_words("", word1))
  when "set_related"
    puts "Rhyming word sets that are related to \"<b>#{word1}</b>\":<br><br>"
    print_tuples(find_rhyming_tuples(word1))
  when "pair_related"
    if(word1 == "" or word2 == "")
      puts "I need two words to find rhyming pairs. For example, Word 1 = crime, Word 2 = heaven"
    else
      puts "Rhyming word pairs where the first word is related to \"<b>#{word1}</b>\" and the second word is related to \"<b>#{word2}</b>\":<br>"
      print_tuples(find_rhyming_pairs(word1, word2))
    end
  when "related_rhymes"
    if(word1 == "" or word2 == "")
      puts "I need two words to find related rhymes pairs. For example, Word 1 = please, Word 2 = cats"
    else
      puts "Rhymes for \"<b>#{word1}</b>\" that are conceptually related to \"<b>#{word2}</b>\":<br><br>"
      print_words(find_words(word1, word2))
    end
  else
    puts "Invalid selection."
  end
end

# main

puts "Content-type: text/html\n\n";

puts "<html>
  <head>
  </head>
  <body>
<h2>RHYME NINJA</h2>"

debug "DEBUG MODE"

cgi = CGI.new;
word1 = cgi['word1'];
word2 = cgi['word2'];
goal = cgi['goal'];

if !be_a_ninja(word1, word2, goal)
  puts "No matching results."
end

# do it again
puts "<br><br>"
form = IO.read("/var/www/html/rhyme.html");

# make the dropdown box default to the most recent one you picked
target_string = "<option value=\"#{goal}\""
tweaked_form = form.sub(target_string, target_string + " selected")
puts tweaked_form

puts "</body></html>"
