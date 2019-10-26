require_relative '../ninja'

# conditionalizes tests that we don't expect to work yet
OPTIMISTIC = false

NOT_WORKING = false; #don't edit this one

#
# rhymes
#

def oughta_rhyme(word1, word2, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "'#{word1}' oughta rhyme with '#{word2}'"
    it test_name do
      expect(rhymes?(word1, word2)).to eql(true), "'#{word1}' (pronounced #{pronunciations(word1)}) oughta rhyme with '#{word2}' ((pronounced #{pronunciations(word2)}), but instead it only rhymes with #{find_rhyming_words(word1)}, and #{word2} only rhymes with #{find_rhyming_words(word2)}"
      expect(rhymes?(word2, word1)).to eql(true), "'#{word2}' (pronounced #{pronunciations(word2)}) oughta rhyme with '#{word1}' (pronounced #{pronunciations(word1)}), but instead it only rhymes with #{find_rhyming_words(word2)}, and #{word1} only rhymes with #{find_rhyming_words(word1)}"
    end
  end
end
                
def ought_not_rhyme(word1, word2, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "'#{word1}' ought not rhyme with '#{word2}'"
    it test_name do
      expect(rhymes?(word1, word2)).to eql(false), "'#{word1}' (pronounced #{pronunciations(word1)}) ought not rhyme with '#{word2}' (pronounced #{pronunciations(word2)}), but it does, and it also rhymes with #{find_rhyming_words(word1)}"
      expect(rhymes?(word2, word1)).to eql(false), "'#{word2}' (pronounced #{pronunciations(word2)}) ought not rhyme with '#{word1}' (pronounced #{pronunciations(word1)}), but it does, and it also rhymes with #{find_rhyming_words(word2)}"
    end
  end
end

describe 'rhymes' do

  context 'no self-rhymes' do
    ought_not_rhyme 'red', 'red'
  end
  
  context 'basic' do
    oughta_rhyme 'rhyme', 'crime'
    ought_not_rhyme 'beer', 'wine'
    oughta_rhyme 'gay', 'hooray'
    oughta_rhyme 'space', 'place'
  end
  
  context 'tricky' do
    oughta_rhyme "we're", 'queer'
    oughta_rhyme 'station', 'nation'
    oughta_rhyme 'station', 'education'
    ought_not_rhyme 'station', 'cation' # it's pronounced "CAT-EYE-ON"
    ought_not_rhyme 'education', 'cation'
    ought_not_rhyme 'anion', 'onion' # it's pronounced "ANN-EYE-ON"
  end
  
  context 'perfect rhymes must rhyme the last primary-stressed syllable, not just the last syllable' do
    ought_not_rhyme 'station', 'shun'
    ought_not_rhyme 'under', 'fur'
    ought_not_rhyme 'tea', 'bounty'
  end

  if(OPTIMISTIC)
  context "you can't just add a prefix and call it a rhyme" do
    oughta_rhyme 'grape', 'ape' # gr- is not a prefix
    oughta_rhyme 'pot', 'spot' # s- is not a prefix
    oughta_rhyme 'under', 'plunder' # pl- is not a prefix
    
    ought_not_rhyme 'promising', 'unpromising'
    ought_not_rhyme 'ion', 'cation'
    
    oughta_rhyme 'able', 'cable'
    oughta_rhyme 'unable', 'cable'
    ought_not_rhyme 'able', 'unable'

    ought_not_rhyme 'traction', 'attraction'
    oughta_rhyme 'action', 'traction'
    oughta_rhyme 'action', 'attraction'

    oughta_rhyme 'ice', 'dice'
    oughta_rhyme 'ice', 'deice' # de-ice
    ought_not_rhyme 'ice', 'deice'

    oughta_rhyme 'stand', 'strand'
    oughta_rhyme 'understand', 'strand'
    ought_not_rhyme 'stand', 'understand'
  end
  end
  
  context 'profanity is allowed' do
    oughta_rhyme 'truck', 'fuck'
  end
  
  context 'slurs are forbidden' do
    ought_not_rhyme 'tipsy', 'gypsy'
    ought_not_rhyme 'fop', 'wop'
  end
  
  context 'Limerick Heist' do
    oughta_rhyme 'heist', 'sliced'
    oughta_rhyme 'heist', 'iced'
    oughta_rhyme 'tons', 'funds', NOT_WORKING
  end

  context 'imperfect rhymes' do
    oughta_rhyme 'mushroom', 'doom', NOT_WORKING # no pronunciation for 'mushroom'
  end
  
  # context 'filter rare words' do
  # 'saddle' has a bunch of rare words
  # end
end

#
# related
#

def oughta_be_related(word1, word2, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "'#{word1}' oughta be related to '#{word2}'"
    it test_name do
      expect(related?(word1, word2, false)).to eql(true), "Related words for '#{word1}' oughta include '#{word2}', but instead we just get #{find_related_words(word1)}"
    end
  end
end
  
def ought_not_be_related(word1, word2, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "'#{word1}' ought not be related to '#{word2}'"
    it test_name do
      expect(related?(word1, word2, false)).to eql(false), "Related words for '#{word1}' ought not include '#{word2}'"
    end
  end
end
  
describe 'related' do
  
  context 'basic' do
    oughta_be_related 'meow', 'cat'
    oughta_be_related 'grave', 'death'
  end

  context 'reflexivity' do
    ought_not_be_related 'death', 'death'
  end

  context 'examples from the documentation' do
    oughta_be_related 'death', 'bled'
    oughta_be_related 'death', 'dead'
    oughta_be_related 'death', 'dread'
  end

  if(OPTIMISTIC)
  context 'pirate' do
    ought_not_be_related 'pirate', 'pew', NOT_WORKING
  end
  end
  
end

#
# set_related
#

def set_related_contains?(input, output1, output2)
  # Generate set_related rhymes for INPUT. Does one of them contain both OUTPUT1 and OUTPUT2?
  # e.g. 'pirate', 'handsome', 'ransom'
  for tuple in find_rhyming_tuples(input) do
    if(tuple.include?(output1) and tuple.include?(output2))
      return true
    end
  end
  return false
end

def set_related_oughta_contain(input, output1, output2, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "set_related #{input} -> #{output1} / #{output2}"
    it test_name do
      expect(set_related_contains?(input, output1, output2)).to eql(true), "Set-related rhymes for '#{input}' oughta include '#{output1}' (pronounced #{pronunciations(output1)}) / '#{output2}' (pronounced #{pronunciations(output2)}) / ..., but instead we just get #{find_rhyming_tuples(input)}"
    end
  end
end

def set_related_ought_not_contain(input, output1, output2, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "set_related #{input} !-> #{output1} / #{output2}"
    it test_name do
      expect(set_related_contains?(input, output1, output2)).to eql(false), "Set-related rhymes for '#{input}' ought not include '#{output1}' / '#{output2}' / ..."
    end
  end
end

describe 'set_related' do

  context 'examples from the documentation' do
    set_related_oughta_contain 'death', 'bled', 'dread'
    set_related_oughta_contain 'death', 'bled', 'dead'
    set_related_oughta_contain 'death', 'dead', 'dread'
  end
  
  context 'pirate' do
    set_related_oughta_contain 'pirate', 'cove', 'trove'
    set_related_oughta_contain 'pirate', 'handsome', 'ransom'
    set_related_oughta_contain 'pirate', 'french', 'wench'
    set_related_oughta_contain 'pirate', 'gang', 'hang'
    set_related_oughta_contain 'pirate', 'bold', 'gold'
    set_related_oughta_contain 'pirate', 'peg', 'leg'
    set_related_oughta_contain 'pirate', 'daring', 'swearing'
    set_related_oughta_contain 'pirate', 'hacker', 'cracker' # a different kind of pirate
    set_related_oughta_contain 'pirate', 'crew', 'tattoo'
    set_related_oughta_contain 'pirate', 'coast', 'ghost'
    set_related_oughta_contain 'pirate', 'loot', 'pursuit'
  end

  context 'music' do
    set_related_oughta_contain 'music', 'baroque', 'folk'
    set_related_oughta_contain 'music', 'enjoys', 'noise'
    set_related_oughta_contain 'music', 'funk', 'punk'
    set_related_oughta_contain 'music', 'sing', 'swing'
    set_related_oughta_contain 'music', 'composition', 'musician', NOT_WORKING # bump up $datamuse_max
    set_related_oughta_contain 'music', 'clarinet', 'minuet', NOT_WORKING # bump up $datamuse_max
    set_related_oughta_contain 'music', 'accidental', 'instrumental', NOT_WORKING # bump up $datamuse_max
    set_related_oughta_contain 'music', 'sings', 'strings', NOT_WORKING # bump up $datamuse_max
    set_related_oughta_contain 'music', 'glissando', 'ritardando', NOT_WORKING
    set_related_oughta_contain 'music', 'viola', 'hemiola', NOT_WORKING
    set_related_oughta_contain 'music', 'overtone', 'xylophone', NOT_WORKING
    set_related_oughta_contain 'music', 'wave', 'rave', NOT_WORKING
    set_related_oughta_contain 'music', 'beat', 'repeat', NOT_WORKING
    set_related_oughta_contain 'music', 'flow', 'bow', NOT_WORKING
    set_related_oughta_contain 'music', 'guitar', 'rock star', NOT_WORKING
    set_related_oughta_contain 'music', 'jingle', 'single', NOT_WORKING # as in a hit single
    set_related_oughta_contain 'music', 'bar', 'repertoire', NOT_WORKING
    set_related_oughta_contain 'music', 'harp', 'sharp', NOT_WORKING
    set_related_oughta_contain 'music', 'show', 'arpeggio', NOT_WORKING # if we squish the stress
    set_related_oughta_contain 'music', 'mix', 'drumsticks', NOT_WORKING # if we squish the stress
  end

end

#
# pair_related
#

def pair_related_contains?(input1, input2, output1, output2)
  # Generate pair_related rhymes for INPUT1 / INPUT2. Is one of them "OUTPUT1 / OUTPUT2"?
  target_pair = [output1, output2]
  find_rhyming_pairs(input1, input2).include? target_pair
end

def pair_related_oughta_contain(input1, input2, output1, output2, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "pair_related #{input1} / #{input2} -> #{output1} / #{output2}"
    it test_name do
      expect(pair_related_contains?(input1, input2, output1, output2)).to eql(true), "Pair-related rhymes for '#{input1}' / '#{input2}' oughta include '#{output1}' (pronounced #{pronunciations(output1)}) / '#{output2}' (pronounced #{pronunciations(output2)}), but instead we just get #{find_rhyming_pairs(input1, input2)}"
    end
  end
end

def pair_related_ought_not_contain(input1, input2, output1, output2, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "pair_related #{input1} / #{input2} !-> #{output1} / #{output2}"
    it test_name do
      expect(pair_related_contains?(input1, input2, output1, output2)).to eql(false), "Pair-related rhymes for '#{input1}' / '#{input2}' ought not include '#{output1}' / '#{output2}'"
    end
  end
end

describe 'pair_related' do
  
  context 'examples from the documentation' do
    pair_related_oughta_contain 'crime', 'heaven', 'confessed', 'blessed'
  end
  
  context 'interactive fiction' do
    pair_related_oughta_contain 'interactive', 'fiction', 'exciting', 'writing'
  end

  context 'food evil' do
    pair_related_oughta_contain 'food', 'evil', 'chewed', 'rude'
    pair_related_oughta_contain 'food', 'evil', 'cuisine', 'mean'
    pair_related_oughta_contain 'food', 'evil', 'feed', 'greed'
    pair_related_oughta_contain 'food', 'evil', 'grain', 'pain'
    pair_related_oughta_contain 'food', 'evil', 'grain', 'bane'
    pair_related_oughta_contain 'food', 'evil', 'rice', 'vice'
    pair_related_oughta_contain 'food', 'evil', 'vegetarian', 'totalitarian'
    pair_related_oughta_contain 'food', 'evil', 'dinner', 'sinner'
    pair_related_oughta_contain 'food', 'evil', 'cake', 'rake', NOT_WORKING
    pair_related_oughta_contain 'food', 'evil', 'mushroom', 'doom', NOT_WORKING
    pair_related_oughta_contain 'food', 'evil', 'chips', 'apocalypse', NOT_WORKING
    pair_related_oughta_contain 'food', 'evil', 'seder', 'darth vader', NOT_WORKING
    pair_related_oughta_contain 'food', 'evil', 'sachertort', 'voldemort', NOT_WORKING
  end
  
  context 'food dark' do
    pair_related_oughta_contain 'food', 'dark', 'turkey', 'murky', NOT_WORKING
  end

end

#
# related_rhymes
#

def related_rhymes?(input_rhyme, input_related, output)
  # Generate words that rhyme with input_related and are related to input_related.
  # Is OUTPUT one of them?
  # e.g. 'please', 'cats', 'siamese'
  find_related_rhymes(input_rhyme, input_related).include?(output)
end

def related_rhymes_oughta_contain(input_rhyme, input_related, output, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "related_rhymes #{input_rhyme} + #{input_related} -> #{output}"
    it test_name do
      expect(related_rhymes?(input_rhyme, input_related, output)).to eql(true), "'#{output}' (pronounced #{pronunciations(output)}) oughta be one of the words that rhyme with '#{input_rhyme}' (pronounced #{pronunciations(input_rhyme)}) and is related to '#{input_related}'"
    end
  end
end

def related_rhymes_ought_not_contain(input_rhyme, input_related, output, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "related_rhymes #{input_rhyme} + #{input_related} !-> #{output}"
    it test_name do
      expect(related_rhymes?(input_rhyme, input_related, output)).to eql(true), "'#{output}' (pronounced #{pronunciations(output)}) ought not one of the words that rhyme with '#{input_rhyme}' (pronounced #{pronunciations(input_rhyme)}) and is related to '#{input_related}'"
    end
  end
end

describe 'related_rhymes' do

  context 'examples from the documentation' do
    related_rhymes_oughta_contain 'please', 'cats', 'siamese'
  end

end
