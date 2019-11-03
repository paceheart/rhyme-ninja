#!/usr/bin/env ruby

#
# control parameters
#

OUTPUT_FORMAT = 'cgi' # 'cgi' or 'text'
DEBUG_MODE = false

#
# Front end for Rhyme Ninja.
#
# Input: word1, word2 (optional)
# Output: A bunch of stuff
#

require_relative 'ninja'

def cgi_puts(string)
  if(OUTPUT_FORMAT == 'cgi')
    puts string
  end
end

cgi = CGI.new;
word1 = cgi['word1'].downcase;
word2 = cgi['word2'].downcase;

if(word1 == "" and word2 != "")
  word1, word2 = word2, word1
end

head = IO.read("html/header.html");

# tweak the title of the webpage to include the submitted word(s)
clarifier = ""
if(word1 != "")
    clarifier = ": #{word1}"
    if(word2 != "")
      clarifier += " / #{word2}"
    end
end
head = head.gsub("<title>Rhyme Ninja</title>","<title>Rhyme Ninja#{clarifier}</title>")

cgi_puts head
debug "DEBUG MODE"

type = :error
goals = [ ]
widths = [ ]

if(word1 == "")
  type = :vacuous
elsif(word2 == "")
  goals = [ "rhymes", "related", "set_related" ]
#  widths = [25, 25, 46]
  widths = [31, 31, 33]
else
  goals = [ "related_rhymes", "pair_related" ]
  widths = [45, 53]
end

def print_words_or_tuples(something, is_tuples)
  if(is_tuples)
    print_tuples(something)
  else
    print_words(something)
  end
end

goals.length.times do |i|
  goal = goals[i]
  width = widths[i]
  cgi_puts "<td style='vertical-align: top; width:#{width}%;' label='#{goal}'>"
  output, dregs, type, header = rhyme_ninja(word1, word2, goal, OUTPUT_FORMAT, DEBUG_MODE)
  case type # :words, :tuples, :bad_input, :vacuous, :error
  when :words
    cgi_puts header
    if output.empty?
      puts "No matching results."
    else
      print_words(output)
    end
  when :tuples
    cgi_puts header
    if output.empty?
      puts "No matching results."
    else
      print_tuples(output)
    end
  when :bad_input
    puts header
  when :vacuous
  when :error
    puts "Unexpected error."
  else
    puts "Very unexpected error."
  end
  cgi_puts "</td>"
  unless(i == goals.length - 1)
    cgi_puts "<td style='border-left: 2px solid; width:2%;'> </td>"
  end  
end

cgi_puts IO.read("html/footer.html");
