#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'json'
require 'cgi'

DEBUG_MODE = false
$output_format = 'text'
$datamuse_max = 400

def debug(string)
  if(DEBUG_MODE)
    puts string
  end
end

def cgi_print(string)
  if($output_format == 'cgi')
    print string
  end
end

def cgi_puts(string)
  if($output_format == 'cgi')
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
  if(rel == "")
    find_rhyming_words(rhyme)
  else
    results_to_words(find_datamuse_results(rhyme, rel))
  end
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
# Display
#

def print_tuple(tuple)
  # print TUPLE separated by slashes
  i = 0
  cgi_print "<div class='tuple'>"
  tuple.each { |elem|
    if(i > 0)
      print " / "
    end
    cgi_print "<span class='output_word'>"
    print elem
    cgi_print "</span>"
    i += 1
  }
  cgi_print "</div>"
  puts
  STDOUT.flush
end

def print_tuples(tuples)
  # return boolean, did I print anything? i.e. was TUPLES nonempty?
  success = !tuples.empty?
  if(success)
    tuples.each { |tuple|
      print_tuple(tuple)
    }
  end
  success
end

def print_words(words)
  success = !words.empty?
  if(success)
    words.each { |word|
      cgi_print "<div class='output_tuple'>"
      cgi_print "<span class='output_word'>"
      print word
      cgi_print "</span>"
      cgi_print "</div>"
      puts
    }
  end
  success
end

#
# Central dispatcher
#

def be_a_ninja(word1, word2, goal, output_format='text')
  $output_format = output_format
  result = nil
  result_type = :error # :words, :tuple, :bad_input, :empty, :error
  result_header = "Unexpected error."

  # special cases
  if(word1 == "" and word2 == "")
    return nil, :empty, ""
  end
  if(word1 == "" and word2 != "")
    word1, word2 = word2, word1
  end
  if(word1 == "smiley" and word2 == "love" and goal == "related_rhymes")
    result_header = "<font size=80><bold>KYELI!</bold></font>"; # easter egg for Kyeli
    return [ ], :words, result_header
  end

  # @todo  if(word1.include?(" "))

  # main list of cases
  case goal
  when "rhymes"
    result_header = "Rhymes for \"<span class='focal_word'>#{word1}</span>\":<div class='results'>"
    result = find_rhyming_words(word1)
    result_type = :words
  when "related"
    result_header = "Words conceptually related to \"<span class='focal_word'>#{word1}:</span>\":<div class='results'>"
    result = find_words("", word1)
    result_type = :words
  when "set_related"
    result_header = "Rhyming word sets that are related to \"<span class='focal_word'>#{word1}</span>\":<div class='results'>"
    result = find_rhyming_tuples(word1)
    result_type = :tuple
  when "pair_related"
    if(word1 == "" or word2 == "")
      result_header = "I need two words to find rhyming pairs. For example, Word 1 = <span class='focal_word'>crime</span>, Word 2 = <span class='focal_word'>heaven</span>"
      result_type = :bad_input
    else
      result_header = "Rhyming word pairs where the first word is related to \"<span class='focal_word'>#{word1}</span>\" and the second word is related to \"<span class='focal_word'>#{word2}</span>\":<br>"
      result = find_rhyming_pairs(word1, word2)
      result_type = :tuple
    end
  when "related_rhymes"
    if(word1 == "" or word2 == "")
      result_header = "I need two words to find related rhymes pairs. For example, Word 1 = <span class='focal_word'>please</span>, Word 2 = <span class='focal_word'>cats</span>"
      result_type = :bad_input
    else
      result_header = "Rhymes for \"<span class='focal_word'>#{word1}</span>\" that are conceptually related to \"<span class='focal_word'>#{word2}</span>\":<div class='results'>"
      result = find_words(word1, word2)
      result_type = :words
    end
  else
    result_header = "Invalid selection."
    result_type = :bad_input
  end
  return result, result_type, result_header
end

#
# main
#

cgi_puts IO.read("header.html");
debug "DEBUG MODE"

cgi = CGI.new;
word1 = cgi['word1'].downcase;
word2 = cgi['word2'].downcase;
goal = cgi['goal'].downcase;

output, type, header = be_a_ninja(word1, word2, goal, $output_format)
case type # :words, :tuple, :bad_input, :empty, :error
when :words
  cgi_puts header
  print_words(output)
when :tuples
  cgi_puts header
  print_tuples(output)
when :bad_input
  puts header
when :empty
  puts "No matching results."
when :error
  puts "Unexpected error."
else
  puts "Very unexpected error."
end

if($output_format == 'cgi')
  # do it again
  form = IO.read("rhyme.html");

  # make the dropdown box default to the most recent one you picked
  target_string = "<option value=\"#{goal}\""
  tweaked_form = form.sub(target_string, target_string + " selected")
  puts tweaked_form
end
