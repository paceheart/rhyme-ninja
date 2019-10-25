require_relative '../ninja'

# conditionalizes tests that we don't expect to work yet
OPTIMISTIC = false;

#
# rhymes
#

describe 'rhymes' do

  def oughta_rhyme(word1, word2)
    expect(rhymes?(word1, word2)).to eql(true), "'#{word1}' oughta rhyme with '#{word2}', but instead it only rhymes with #{find_rhyming_words(word1)}, and #{word2} only rhymes with #{find_rhyming_words(word2)}"
    expect(rhymes?(word2, word1)).to eql(true), "'#{word2}' oughta rhyme with '#{word1}', but instead it only rhymes with #{find_rhyming_words(word2)}, and #{word1} only rhymes with #{find_rhyming_words(word1)}"
  end
                
  def ought_not_rhyme(word1, word2)
    expect(rhymes?(word1, word2)).to eql(false), "'#{word1}' ought not rhyme with '#{word2}', but it does, and it also rhymes with #{find_rhyming_words(word1)}"
    expect(rhymes?(word2, word1)).to eql(false), "'#{word2}' ought not rhyme with '#{word1}', but it does, and it also rhymes with #{find_rhyming_words(word2)}"
  end

  it 'no self-rhymes' do
    ought_not_rhyme 'red', 'red'
  end
  it 'basic' do
    oughta_rhyme 'rhyme', 'crime'
    ought_not_rhyme 'beer', 'wine'
    oughta_rhyme 'gay', 'hooray'
    oughta_rhyme 'space', 'place'
  end
  it 'tricky' do
    oughta_rhyme "we're", 'queer'
    oughta_rhyme 'station', 'nation'
    oughta_rhyme 'station', 'education'
    ought_not_rhyme 'station', 'cation' # it's pronounced "CAT-EYE-ON"
    ought_not_rhyme 'education', 'cation'
  end
  it 'perfect rhymes must rhyme the last primary-stressed syllable, not just the last syllable' do
    ought_not_rhyme 'station', 'shun'
    ought_not_rhyme 'under', 'fur'
    ought_not_rhyme 'tea', 'bounty'
  end
  if(OPTIMISTIC)
  it "you can't just add a prefix and call it a rhyme" do
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
  it 'profanity is allowed' do
    oughta_rhyme 'truck', 'fuck'
  end
  it 'slurs are forbidden' do
    ought_not_rhyme 'tipsy', 'gypsy'
    ought_not_rhyme 'fop', 'wop'
  end
  it 'Limerick Heist' do
    oughta_rhyme 'heist', 'sliced'
    oughta_rhyme 'heist', 'iced'
    if(OPTIMISTIC)
      oughta_rhyme 'tons', 'funds'
    end
  end
  # it 'filter rare words' do
  # 'saddle' has a bunch of rare words
  # end
end

#
# related
#

# @todo




#
# set_related
#

describe 'set_related' do

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

  def set_related_oughta_contain(input, output1, output2)
    expect(set_related_contains?(input, output1, output2)).to eql(true), "Set-related rhymes for '#{input}' oughta include '#{output1}' / '#{output2}' / ..., but instead we just get #{find_rhyming_tuples(input)}"
  end

  def set_related_ought_not_contain(input, output1, output2)
    expect(set_related_contains?(input, output1, output2)).to eql(false), "Set-related rhymes for '#{input}' ought not include '#{output1}' / '#{output2}' / ..."
  end

  it 'examples from the documentation' do
    set_related_oughta_contain 'death', 'bled', 'dread'
    set_related_oughta_contain 'death', 'bled', 'dead'
    set_related_oughta_contain 'death', 'dead', 'dread'
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

def pair_related_oughta_contain(input1, input2, output1, output2)
  expect(pair_related_contains?(input1, input2, output1, output2)).to eql(true), "Pair-related rhymes for '#{input1}' / '#{input2}' oughta include '#{output1}' / '#{output2}', but instead we just get #{find_rhyming_pairs(input1, input2)}"
end

def pair_related_ought_not_contain(input1, input2, output1, output2)
  expect(pair_related_contains?(input1, input2, output1, output2)).to eql(false), "Pair-related rhymes for '#{input1}' / '#{input2}' ought not include '#{output1}' / '#{output2}'"
end

describe 'pair_related' do
  it 'examples from the documentation' do
    pair_related_oughta_contain 'crime', 'heaven', 'confessed', 'blessed'
  end
  if(OPTIMISTIC)
  it 'Danni' do
    pair_related_oughta_contain 'food', 'evil', 'chips', 'apocalypse'
  end
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

def related_rhymes_oughta_contain(input_rhyme, input_related, output)
  expect(related_rhymes?(input_rhyme, input_related, output)).to eql(true), "'#{output}' oughta be one of the words that rhyme with '#{input_rhyme}' and is related to '#{input_related}'"
end

def related_rhymes_ought_not_contain(input_rhyme, input_related, output)
  expect(related_rhymes?(input_rhyme, input_related, output)).to eql(false), "'#{output}' ought not be one of the words that rhyme with '#{input_rhyme}' and is related to '#{input_related}'"
end

describe 'set_related' do
  it 'examples from the documentation' do
    related_rhymes_oughta_contain 'please', 'cats', 'siamese'
  end
end
