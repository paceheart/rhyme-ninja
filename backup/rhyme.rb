#!/usr/bin/ruby

require 'cgi'
require 'net/http'
require 'uri'
require 'json'

MAX_API_REQUESTS = 100; # don't overload the datamuse API
DEBUG_MODE = false;

cgi = CGI.new;
rhyme1 = cgi['rhyme1'];
rel1 = cgi['rel1'];

def find_words(rhyme, rel, print_header)
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

def find_rhymes(rhyme)
  find_words(rhyme, "", false)
end

def debug(string)
  if(DEBUG_MODE)
    puts string
  end
end

def find_rhyming_tuples(input_rel1) # todo rel2
  related_rhymes = Hash.new {|h,k| h[k] = [] } # hash of arrays
  rel_results1 = find_words("", input_rel1, false)
  apiCount = 0;
  relateds1 = [ ]
  rel_results1.each { |rel_result1|
    relateds1.push(rel_result1["word"])
  }
  rel_results1.each { |rel_result1|
    apiCount += 1;
    if(apiCount > MAX_API_REQUESTS)
      break
    end
    rel1 = rel_result1["word"]
    debug "rhymes for #{rel1}:<br>"
    find_rhymes(rel1).each { |rhyme_result1|
      rhyme1 = rhyme_result1["word"]
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

def print_tuple(tuple)
  # prints TUPLE separated by slashes
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

# main

puts "Content-type: text/html\n\n";

puts "<html>
  <head>
  </head>
  <body>
<h2>RHYME NINJA</h2>"

debug "DEBUG MODE"

if(rhyme1 != "" || rel1 != "")
  
if(rhyme1 == "smiley" && rel1 == "love")
    puts "<font size=80><bold>KYELI!</bold></font>";
else
  if(rhyme1 != "")
    results = find_words(rhyme1, rel1)
    if results
      results.each { |result|
        word = result["word"];
        score = result["score"];
        numSyllables = result["numSyllables"]
        puts "#{word}<br/>";
      }
    else puts "No matching results."
    end
  else # rhyme1 == ""
    puts "Rhyming word sets that are related to <b>#{rel1}</b>:<br>"
    tuples = find_rhyming_tuples(rel1)
    if(!tuples.empty?)
      tuples.each { |tuple|
        print_tuple(tuple)
        puts "<br>"
      }
    else puts "No matching results."
    end
  end
  puts "<br/><br/>";
end
end

# do it again
puts IO.read("/var/www/html/form.html");
puts "</body></html>"

