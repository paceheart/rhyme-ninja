#!/usr/bin/env ruby

#
# control parameters
#

OUTPUT_FORMAT = 'text' # 'cgi' or 'text'
DEBUG_MODE = false

#
# Front end for Rhyme Ninja.
#
# Input: word1, word2 (optional), goal ("rhymes", "related", "set_related", "pair_related", "related_rhymes")
# Output: A list of words or word tuples, one per line, bearing the "goal" relation to the inputs.
#
# For example, if word1="slice" and goal="rhymes", the output (in text mode) will be
# advice
# berneice
# bice
# brice
# ...
#
# If word1="crime", word2="heaven", and goal="pair_related", the output (in text mode) will be
# arrest / blessed
# arrest / blest
# assassination / damnation
# assassination / salvation
# ...
#

require_relative 'ninja'

cgi_puts IO.read("html/header.html");
debug "DEBUG MODE"

cgi = CGI.new;
word1 = cgi['word1'].downcase;
word2 = cgi['word2'].downcase;
goal = cgi['goal'].downcase;

output, type, header = rhyme_ninja(word1, word2, goal, OUTPUT_FORMAT)
case type # :words, :tuples, :bad_input, :vacuous, :error
when :words
  if output.empty?
    puts "No matching results."
  else
    cgi_puts header
    print_words(output)
  end
when :tuples
  if output.empty?
    puts "No matching results."
  else
    cgi_puts header
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

if(OUTPUT_FORMAT == 'cgi')
  # do it again
  form = IO.read("html/footer.html");

  # make the dropdown box default to the most recent one you picked
  target_string = "<option value=\"#{goal}\""
  tweaked_form = form.sub(target_string, target_string + " selected")
  puts tweaked_form
end
