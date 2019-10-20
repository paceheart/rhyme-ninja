#!/usr/bin/env ruby

require 'cgi'
require 'net/http'
require 'uri'
require 'json'

DEBUG_MODE = false;
$max_api_requests = 100 # don't overload the datamuse API

def debug(string)
  if(DEBUG_MODE)
    puts string
  end
end

def results_to_words(results)
  words = [ ]
  results.each { |result|
    words.push(result["word"])
  }
  words
end
  
def find_related_words(word)
  words = results_to_words(find_results("", word))
  words.push(word) # every word is related to itself
end

def find_results(rhyme, rel, print_header=false)
  if(rhyme.include?(" "))
    if(print_header)
      puts "Can't handle phrases, only single words."
    end
    [ ]
  else
    header = ""
    request = "https://api.datamuse.com/words?"
    if(rhyme != "")
      request += "rel_rhy=#{rhyme}&";
      if(header == "")
        header = "Rhymes for "
      else
        header += " that rhyme with "
      end
      header += "<b>#{rhyme}</b>"
    end
    if(rel != "")
      request += "ml=#{rel}&";
      if(header == "")
        header = "Words related to "
      else
        header += " that are related to "
      end
      header += "<b>#{rel}:</b>"
    end
    header += ":<br/><br/>"
    if(print_header)
      puts header
    end
    if($max_api_requests != 100)
      request += "max=#{$max_api_requests}" # no trailing &, must be the last thing
    end
    request = URI.escape(request)
    debug "#{request}<br/><br/>";

    uri = URI.parse(request);
    response = Net::HTTP.get_response(uri)
    if(response.body() != "")
      JSON.parse(response.body());
    else
      puts "Error connecting to Datamuse API: #{request}"
      abort
    end
  end
end

def find_words(rhyme, rel, print_header=false)
  results_to_words(find_results(rhyme, rel, print_header))
end

def find_rhyming_words(rhyme)
  results_to_words(find_results(rhyme, ""))
end

def find_rhyming_tuples(input_rel1)
  # Rhyming word sets that are related to INPUT_REL1.
  # Each element of the returned array is an array of words that rhyme with each other and are all related to INPUT_REL1.
  related_rhymes = Hash.new {|h,k| h[k] = [] } # hash of arrays
  relateds1 = find_related_words(input_rel1)
  apiCount = 0;
  relateds1.each { |rel1|
    apiCount += 1;
    if(apiCount > $max_api_requests)
      break
    end
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
    apiCount += 1;
    if(apiCount > $max_api_requests)
      break
    end
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

def be_a_ninja(rhyme1, rel1, rel2)
  # return SUCCESS?

  # special cases
  if(rhyme1 == "" and rel1 == "" and rel2 == "")
    return true # vacuous success, no need to say "No matching results"
  end
  if(rel1 == "" and rel2 != "")
    rel1, rel2 = rel2, rel1
  end
  if(rhyme1 == "smiley" && rel1 == "love")
    puts "<font size=80><bold>KYELI!</bold></font>";
    return true
  end

  # main list of cases
  if(   rhyme1 == "" and rel1 != "" and rel2 == "")
    puts "Rhyming word sets that are related to <b>#{rel1}</b>:<br>"
    print_tuples(find_rhyming_tuples(rel1))
  elsif(rhyme1 == "" and rel1 != "" and rel2 != "")
    puts "Pairs of rhyming words where the first word is related to <b>#{rel1}</b> and the second word is related to <b>#{rel2}</b>:<br>"
    print_tuples(find_rhyming_pairs(rel1, rel2))
  elsif(rhyme1 != ""                and rel2 != "")
    puts "If you specify a rhyming word, you can only specify one related word."
    true # don't say "No matching results."
  elsif(rhyme1 != ""                and rel2 == "")
    $max_api_requests = 1000 # we're not going to loop, so we can bump this up
    print_words(find_words(rhyme1, rel1, true))
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
rhyme1 = cgi['rhyme1'];
rel1 = cgi['rel1'];
rel2 = cgi['rel2'];

if !be_a_ninja(rhyme1, rel1, rel2)
  puts "No matching results."
end

# do it again
puts "<br><br>"
puts IO.read("/var/www/html/rhyme.html");
puts "</body></html>"

