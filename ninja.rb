#!/usr/bin/env ruby
# coding: utf-8

Gem.paths = { 'GEM_PATH' => '/usr/local/rvm/gems/ruby-2.6.5/' }

#
# control parameters
# Don't tweak these here, tweak them in frontend.rb
#

DEFAULT_DATAMUSE_MAX = 1000
$datamuse_max = DEFAULT_DATAMUSE_MAX
$debug_mode = false
$output_format = 'text'
$display_word_frequencies = false
DATAMUSE_ENABLED = true

#
# Public interface: rhyme_ninja(word1, word2, goal, output_format='text', debug_mode=false, datamuse_max=400)
# see rhyme.rb for documentation
# 

require 'rwordnet'
require 'net/http'
require 'uri'
require 'json'
require 'cgi'
require_relative 'dict/utils_rhyme'

#
# utilities
#

def debug(string)
  if($debug_mode)
    puts string
  end
end

def cgi_print(string)
  if($output_format == 'cgi')
    print string
  end
end

#
# Local rhyme computation
#

$word_dict = nil
def word_dict()
  # word => [frequency, pronunciations]
  # pronunciations = [pronunciation1, pronunciation2 ...]
  # pronunciation = [syllable1, syllable1, ...]
  if $word_dict.nil?
    $word_dict = load_word_dict_as_hash
  end
  $word_dict
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

def load_word_dict_as_hash()
  JSON.parse(File.read("dict/word_dict.json")) or die "First run dict/dict.rb to generate dictionary caches"
end

def load_rhyme_signature_dict_as_hash()
  load_string_hash("dict/#{RHYME_SIGNATURE_DICT_FILENAME}") or die "First run dict/dict.rb to generate dictionary caches"
end

def pronunciations(word, lang)
  case lang
  when "en"
    return english_pronunciations(word)
  when "es"
    return spanish_pronunciations(word)
  else
    abort "Unexpected language #{lang}"
  end
end

def english_pronunciations(word)
  word_info = word_dict[word]
  if(word_info)
    return word_info[1]
  else
    return [ ]
  end
end

def spanish_pronunciations(word)
  english_pronunciations(word) # stub
end

def frequency(word)
  word_info = word_dict[word]
  if(word_info)
    return word_info[0]
  else
    return 0
  end
end  

def rdict_lookup(rsig)
  rdict[rsig] || [ ]
end

def find_preferred_rhyming_words(word, lang)
  # filters out dispreferred spelling variants and identical rhymes
  result = find_rhyming_words(word, lang, false).map { |word| preferred_form(word) }
  if result
    result.sort!.uniq!
    result = result - all_forms(word)
    debug "preferred: #{result.inspect}"
  end
  return result || [ ]
end

def find_rhyming_words(word, lang, identical_ok=true)
  # merges multiple pronunciations of WORD
  # use our compiled rhyme signature dictionary; we don't need the Datamuse API for simple rhyme lookup
  rhyming_words = Array.new
  unless(blacklisted?(word))
    for form in all_forms(word) # to increase the likelihood of a hit, try all spelling variants
      for pron in pronunciations(word, lang)
        for rhyme in find_rhyming_words_for_pronunciation(pron, identical_ok)
          rhyming_words.push(rhyme)
        end
      end
      rhyming_words.delete(word)
      if(rhyming_words)
        rhyming_words = rhyming_words.uniq
      end
    end
  end
  return rhyming_words || [ ]
end

def is_identical_rhyme(rhyme, target_rhyme_syllables_array)
  # Used to filter out identical rhymes, where the entire final stressed syllable is identical to the one in RSIG.
  # e.g. if you input "leave", this will return "grieve" but not "believe", because the rhyming syllable
  # "L_IY_V" is identical.
  lang = 'en' # @hack
  for pron in pronunciations(rhyme, lang)
    debug "Is #{rhyme} (#{rhyme_syllables_array(pron)}) identical to #{target_rhyme_syllables_array}?"
    if rhyme_syllables_array(pron) != target_rhyme_syllables_array
      return false; # we found a pronunciation with a different rhyming syllable; this rhyme is perfect
    end
  end
  return true;
end
  
def find_rhyming_words_for_pronunciation(pron, identical_ok=true)
  # use our compiled rhyme signature dictionary; we don't need the Datamuse API for simple rhyme lookup
  results = Array.new
  rsig = rhyme_signature(pron)
  rsyllables = rhyme_syllables_array(pron)
  rdict_lookup(rsig).each { |rhyme|
    unless(!identical_ok && is_identical_rhyme(rhyme, rsyllables))
      results.push(rhyme)
    else
      debug "Filtered out identical rhyme: #{pron} / #{rhyme}"
    end
  }
  return results || [ ]
end

def has_rhyming_word?(word, lang)
  unless(blacklisted?(word))
    for pron in pronunciations(word, lang)
      rsig = rhyme_signature(pron)
      if(! rdict_lookup(rsig).empty?)
        return true
      end
    end
  end
  return false
end

def filter_out_rhymeless_words(words, lang)
  words.select { |word| has_rhyming_word?(word, lang) }
end

# def is_stupid_rhyme(pron, rhyme)
  # word.include?(rhyme) or rhyme.include?(word)
  # consider filtering out words where the rhyming syllable is identical. But for now it's better to overinclude than overexclude.
#   word == rhyme
# end

#
# WordNet stuff
#

def find_synsets(word, lang)
  # ignore lang, @todo hook up Spanish WordNet
  lemmas = WordNet::Lemma.find_all(word)
  synsets = lemmas.map { |lemma| lemma.synsets }
  return synsets.flatten || [ ]
end

def find_synonyms(word)
  results = Array.new
  for synset in find_synsets(word) do
    for word in synset.words do
      results << word
    end
  end
  return results.uniq!.sort!
end

#
# Datamuse stuff
#

def results_to_related_words(results)
  results_to_words(results).select { |res| relatable_word?(res) }
end

def results_to_words(results)
  words = [ ]
  results.each { |result|
    word = result["word"]
    unless(blacklisted?(word))
      words.push(word)
    end
  }
  return words
end
  
def find_related_words(word, include_self, lang)
  words = results_to_related_words(find_datamuse_results("", word, lang))
  if(include_self)
    words.push(word)
  end
  return words
end

def find_related_rhymes(rhyme, rel, lang)
  results_to_related_words(find_datamuse_results(rhyme, rel, lang))
end

def find_datamuse_results(rhyme, rel, lang)
  if(blacklisted?(rhyme) || blacklisted?(rel) || !DATAMUSE_ENABLED)
    return [ ]
  else
    return really_find_datamuse_results(rhyme, rel, lang)
  end
end

def really_find_datamuse_results(rhyme, rel, lang)
  request = "https://api.datamuse.com/words?"
  if(lang != "en")
    request += "v=#{lang}&"
  end
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

def find_rhyming_tuples(input_rel1, lang)
  # Rhyming word sets that are related to INPUT_REL1.
  # Each element of the returned array is an array of words that rhyme with each other and are all related to INPUT_REL1.
  # Algorithm:
  # Compute the set of all words semantically related to INPUT_REL1, call it RELATEDS1.
  # For each word REL1 in RELATEDS1,
  #   Get all rhymes RHYME1 of REL1.
  #   If R is in RELATEDS1, compute R's rhyme signature RSIG and put RHYME1 in the bucket labeled RSIG.
  # Return all buckets with two or more words in them.
  related_rhymes = Hash.new {|h,k| h[k] = [] } # hash of arrays
  unless(blacklisted?(input_rel1))
    relateds1 = find_related_words(input_rel1, true, lang)
    relateds1.each { |rel1|
      for rel1pron in pronunciations(rel1, lang)
        rsig = rhyme_signature(rel1pron)
        debug "Rhymes for #{rel1} [#{rsig}]:"
        find_rhyming_words_for_pronunciation(rel1pron, true).each { |rhyme1|
          if(relateds1.include? rhyme1) # we only care about relateds of input_rel1
            rhyme1 = preferred_form(rhyme1) # push 'honor' instead of 'honour'. This will ensure we don't push both.
            related_rhymes[rsig].push(rhyme1)
            debug " #{rhyme1}"
          end
        }
      end
    }
  end
  tuples = [ ]
  related_rhymes.each { |rsig, relrhymes|
    relrhymes.sort!.uniq!
    if(relrhymes.length > 1)
      tuples.push(relrhymes.sort!)
    end
  }
  return tuples
end

def find_rhyming_pairs(input_rel1, input_rel2, lang)
  # Pairs of rhyming words where the first word is related to INPUT_REL1 and the second word is related to INPUT_REL2
  # Each element of the returned array is a pair of rhyming words [W1 W2] where W1 is related to INPUT_REL1 and W2 is related to INPUT_REL2
  # Algorithm:
  # Compute the set of all words semantically related to INPUT_REL1, call it RELATEDS1.
  # Compute the set of all words semantically related to INPUT_REL2, call it RELATEDS2.
  # For each word REL1 in RELATEDS1,
  #   Get all rhymes RHYME of REL1.
  #   If RHYME rhymes with REL1 and is related to INPUT_REL2, we win! "REL1 / RHYME" is a pair.
  related_rhymes = Hash.new {|h,k| h[k] = [] } # hash of arrays
  unless(blacklisted?(input_rel1) || blacklisted?(input_rel2))
    relateds1 = find_related_words(input_rel1, true, lang)
    relateds2 = find_related_words(input_rel2, true, lang)
    relateds1.each { |rel1|
      # rel1 is a word related to input_rel1. We're looking for rhyming pairs [rel1 rel2].
      debug "rhymes for #{rel1}:<br>"
      # If we find a word 'RHYME' that rhymes with REL1 and is related to INPUT_REL2, we win!
      find_rhyming_words(rel1, lang).each { |rhyme| # check all rhymes of rel1, call each one 'RHYME'
        if(relateds2.include? rhyme) # is RHYME related to input_rel2? If so, we win!
          related_rhymes[rel1].push(rhyme)
          debug rhyme;
        end
      }
      debug "<br><br>"
    }
  end
  pairs = [ ]
  related_rhymes.each { |relrhyme1, relrhyme2_list|
    if(!relrhyme2_list.empty?)
      relrhyme2_list.each { |relrhyme2|
        pairs.push([relrhyme1, relrhyme2])
      }
    end
  }
  return pairs
end

#
# Display
#

def print_synsets(synsets, input_word, lang)
  # prints the synsets in SYNSETS that are nontrivial wrt INPUT_WORD
  isFirst = true
  for synset in synsets
    synonyms = synset.words - [ input_word ]
    unless(synonyms.empty?)
      unless isFirst
        cgi_print "<br>"
      end
      isFirst = false;
      cgi_print "<i>"
      puts short_gloss(synset)
      cgi_print "</i>"
      puts
      print_words(synonyms, lang)
    end
  end
end

def short_gloss(synset)
  gloss = synset.gloss
  i = gloss.index(';')
  if i
    return gloss[0,i]
  else
    return gloss
  end
end

def print_tuple(tuple, lang)
  # print TUPLE separated by slashes
  i = 0
  cgi_print "<div class='output_tuple'><p class='output_p'>"
  tuple.each { |elem|
    if(i > 0)
      print " / "
    end
    print_word(elem, lang)
    i += 1
  }
  cgi_print "</p></div>"
  puts
  STDOUT.flush
end

def print_tuples(tuples, lang)
  # return boolean, did I print anything? i.e. was TUPLES nonempty?
  success = !tuples.empty?
  if(success)
    tuples.sort.uniq.each { |tuple|
      print_tuple(tuple, lang)
    }
  end
  return success
end

def print_words(words, lang)
  success = !words.empty?
  if(success)
    words.sort.uniq.each { |word|
      cgi_print "<div class='output_tuple'>"
      cgi_print "<p class='output_p'>"
      print_word(word, lang)
      if($display_word_frequencies)
        print " (#{frequency(word)})"
      end
      cgi_print "</p>"
      cgi_print "</div>"
      puts
    }
  end
  return success
end

def ubiquity(word)
  # 0-255
  result = 0
  case frequency(word)
  when 0
    result = 0
  when 1
    result = 40
  when 2..5
    result = 80
  when 6..20
    result = 120
  when 21..100
    result = 160
  when 101..1000
    result = 200
  else
    result = 255
  end
  result
end

def rare?(word)
  frequency(word) == 0
end

def filter_out_rare_words(words)
  # When you enter e.g. 'kitten', you'll get back some reasonable
  # things like 'bitten', 'britain', and 'smitten', but you'll also
  # get back crap like 'bitton', 'brittain', 'brittan', 'brittin',
  # 'britton', 'ditton', 'fitton', etc.
  #
  # Some of these are rare words, and some are just
  # mistakes. Regardless, we don't want them in our output. They
  # clutter up the place and make the good rhymes harder to see.
  #
  # We don't want to get rid of them entirely, though; occasionally
  # that rare word is exactly the one you want, or a good word gets
  # misfiled as rare. So instead we put them in the 'dregs' bucket,
  # which shows up as "For the desperate:" on the website.
  good = words.reject{ |w| rare?(w) }
  bad = words.select { |w| rare?(w) }
  return good, bad
end

def print_word(word, lang)
  word = word.gsub(/\(.*\)/, '') # remove stuff in parentheses
  got_rhymes = !pronunciations(word, lang).empty?
  if(got_rhymes)
    # @todo urlencode
    cgi_print lang(lang, "<a href='rhyme.rb?word1=#{word}'>", "<a href='rimar.rb?word1=#{word}'>")
  end
  ubiq = ubiquity(word)
  #  cgi_print "<span style='color: rgb(#{ubiq}, #{ubiq}, #{ubiq});'>"
  word = word.gsub('_', ' ')
  print word
#  cgi_print "</span>"
  if(got_rhymes)
    cgi_print "</a>"
  end
end

#
# Central dispatcher
#

def focal_word(word)
  return "\"<span class='focal_word'>#{word}</span>\""
end

def rhyme_ninja(word1, word2, goal, lang='en', output_format='text', debug_mode=false, datamuse_max=DEFAULT_DATAMUSE_MAX)
  # When you enter a single word,
  #   Rhyme Ninja displays rhymes for that word (see find_rhyming_words), separating out the rare words (see rare?)
  #   and in a separate column, displays sets of rhyming words (see find_rhyming_tuples)
  # When you enter two words,
  #   Rhyme Ninja first displays rhymes for WORD1 that are semantically related to WORD2 (see related_rhymes),
  #   and in a separate column, displays pairs of rhyming words (RHYME1 / RHYME2) in which RHYME1 is related to WORD1 and RHYME2 is related to WORD2. (see find_rhyming_pairs)
  $output_format = output_format
  $debug_mode = debug_mode
  $datamuse_max = datamuse_max
  header_eol = ":<div class='results'>"
  
  result = nil
  dregs = [ ]
  result_type = :error # :words, :tuples, :bad_input, :vacuous, :error
  result_header = "Unexpected error."

  # special cases
  if(word1 == "" and word2 == "")
    return nil, :vacuous, ""
  end
  if(word1 == "" and word2 != "")
    word1, word2 = word2, word1
  end
  if(word1 == "smiley" and word2 == "love" and goal == "related_rhymes")
    result_header = "<font size=80><bold>KYELI!</bold></font>"; # easter egg for Kyeli
    return [ ], :words, result_header
  end

  # main list of cases
  case goal
  when "rhymes"
    result_header = lang(lang, "Rhymes for", "Rimas para") + " " + focal_word(word1) + header_eol
    result, dregs = filter_out_rare_words(find_preferred_rhyming_words(word1, lang))
    result_type = :words
  when "synonyms"
    result_header = lang(lang, "Synonyms of", "Sinónimos para") + " " + focal_word(word1) + header_eol
    result = find_synsets(word1, lang)
    dregs = [ ]
    result_type = :synsets
  when "related"
    result_header = lang(lang, "Words related to", "Palabras relacionadas con") + " " + focal_word(word1) + header_eol
    unless DATAMUSE_ENABLED
      result_header = "<i>This section currently under (re)construction. Try back in a couple of days. I'm working on it! -Pace</i>"
    end
    result, dregs = filter_out_rare_words(filter_out_rhymeless_words(find_related_words(word1, false, lang), lang))
    result_type = :words
  when "set_related"
    result_header = lang(lang, "Rhyming word sets related to", "Conjuntos de rimas relacionadas con") + " " + focal_word(word1) + header_eol
    unless DATAMUSE_ENABLED
      result_header = "<i>This section currently under (re)construction. Try back in a couple of days. I'm working on it! -Pace</i>"
    end
    result = find_rhyming_tuples(word1, lang)
    result_type = :tuples
  when "pair_related"
    if(word1 == "" or word2 == "")
      result_header = lang(lang, "I need two words to find rhyming pairs. For example, Word 1 = <span class='focal_word'>crime</span>, Word 2 = <span class='focal_word'>heaven</span>", "Necesito dos palabras para buscar pares rimandos")
      unless DATAMUSE_ENABLED
        result_header = "<i>This section currently under (re)construction. Try back in a couple of days. I'm working on it! -Pace</i>"
      end
      result_type = :bad_input
    else
      result_header = lang(lang, "Rhyming word pairs where the first word is related to", "Pares de palabras rimandas, la primera palabra está relacionada con") + " " + focal_word(word1) + " " + lang(lang, "and the second word is related to ", "y la segunda palabra está relacionada con") + " " + focal_word(word2) + header_eol
      unless DATAMUSE_ENABLED
        result_header = "<i>This section currently under (re)construction. Try back in a couple of days. I'm working on it! -Pace</i>"
      end
      result = find_rhyming_pairs(word1, word2, lang)
      result_type = :tuples
    end
  when "related_rhymes"
    if(word1 == "" or word2 == "")
      result_header = lang(lang, "I need two words to find related rhyming pairs. For example, Word 1 = <span class='focal_word'>please</span>, Word 2 = <span class='focal_word'>cats</span>", "Necesito dos palabras para buscar pares rimandos relacionados.")
      unless DATAMUSE_ENABLED
        result_header = "<i>This section currently under (re)construction. Try back in a couple of days. I'm working on it! -Pace</i>"
      end
      result_type = :bad_input
    else
      result_header = lang(lang, "Rhymes for", "Rimas para") + " " + focal_word(word1) + " " + lang(lang, "that are related to", "que están relacionadas con") + " " + focal_word(word2) + header_eol
      unless DATAMUSE_ENABLED
        result_header = "<i>This section currently under (re)construction. Try back in a couple of days. I'm working on it! -Pace</i>"
      end
      result = find_related_rhymes(word1, word2, lang)
      result_type = :words
    end
  else
    result_header = lang(lang, "Invalid selection.", "Selección invalida.")
    result_type = :bad_input
  end
  debug "result = #{result}"
  debug "result_type = #{result_type}"
  return result, dregs, result_type, result_header
end

#
# Utilities
#

def rhymes?(word1, word2, lang="en", identical_ok=true)
  # Does word1 rhyme with word2?
  find_rhyming_words(word1, lang, identical_ok).include?(word2)
end

def related?(word1, word2, include_self=false, lang="en")
  # Is word1 conceptually related to word2?
  find_related_words(word1, include_self, lang).include?(word2)
end
