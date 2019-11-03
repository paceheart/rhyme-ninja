#
# control parameters
#

OUTPUT_FORMAT = 'cgi' # 'cgi' or 'text'
DEBUG_MODE = false

#
# Front end for Rhyme Ninja.
#

require_relative 'ninja'

def cgi_puts(string)
  if(OUTPUT_FORMAT == 'cgi')
    puts string
  end
end

def parse_cgi_input
  cgi = CGI.new;
  word1 = cgi['word1'].downcase;
  word2 = cgi['word2'].downcase;

  if(word1 == "" and word2 != "")
    word1, word2 = word2, word1
  end
  return word1, word2
end

def print_html_header(word1, word2, lang)
  # ignore lang, @todo 
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

  if(lang=="es")
    head = head.gsub("rhyme.rb", "rimar.rb")
    head = head.gsub("value=Search", "value=Busca")
    head = head.gsub("(optional)", "(opcional)")
  end
  cgi_puts head
  debug "DEBUG MODE"
end

def compute_and_print_html_middle(word1, word2, lang)
  goals = [ ]
  widths = [ ]

  if(word1 == "")
    # vacuous: no goals means nothing will happen
  elsif(word2 == "")
    goals = [ "rhymes", "related", "set_related" ]
    #  widths = [25, 25, 46]
    widths = [31, 31, 33]
  else
    goals = [ "related_rhymes", "pair_related" ]
    widths = [45, 53]
  end

  goals.length.times do |i|
    goal = goals[i]
    width = widths[i]
    output, dregs, type, header = rhyme_ninja(word1, word2, goal, lang, OUTPUT_FORMAT, DEBUG_MODE)
    print_html_column(goal, output, dregs, type, header, width, lang, i == goals.length - 1)
  end
end

def print_html_column(goal, output, dregs, type, header, width, lang, is_last_column)
  # don't bother to display related dregs - there are already plenty of related words
  if(goal == "related")
    dregs = [ ]
  end
  cgi_puts "<td style='vertical-align: top; width:#{width}%;' label='#{goal}'>"
  print_html_column_data(output, dregs, type, header, lang)
  cgi_puts "</td>"
  unless(is_last_column)
    cgi_puts "<td style='border-left: 2px solid; width:2%;'> </td>"
  end  
end

def print_html_column_data(output, dregs, type, header, lang)
  case type # :words, :tuples, :bad_input, :error
  when :words
    print_interesting_html_column_data(output, dregs, header, lang, false)
  when :tuples
    print_interesting_html_column_data(output, dregs, header, lang, true)
  when :bad_input
    puts header
  when :error
    case lang
    when "en"
      puts "Unexpected error."
    when "es"
      puts "Error inesperado."
    else
      puts "Unexpected language #{lang}"
    end
  else
    case lang
    when "en"
      puts "Very unexpected error."
    when "es"
      puts "Error muy inesperado."
    else
      puts "Unexpected language #{lang}"
    end
  end
end

def print_interesting_html_column_data(output, dregs, header, lang, is_tuples)
  cgi_puts header
  if output.empty?
    if dregs.empty?
      puts lang(lang, "No matching results.", "Ningun resultados coincidos.")
    else
      puts lang(lang, "No good results.", "Ningun resultados buenos.")
    end
  else
    print_words_or_tuples(output, lang, is_tuples)
  end
  if(!dregs.empty?)
    cgi_puts "<br/><hr><p>"
    puts lang(lang, "For the desperate:", "Para los desesperados:")
    cgi_puts "</p>"
    print_words_or_tuples(dregs, lang, is_tuples)
  end
end

def print_words_or_tuples(output, lang, is_tuples)
  if(is_tuples)
    print_tuples(output, lang)
  else
    print_words(output, lang)
  end
end

def print_html_footer
  cgi_puts IO.read("html/footer.html");
end

def compute_and_print_html(lang)
  # CGI Input: word1, word2 (optional)
  # Output: A bunch of stuff
  word1, word2 = parse_cgi_input
  print_html_header(word1, word2, lang)
  compute_and_print_html_middle(word1, word2, lang)
  print_html_footer
end

