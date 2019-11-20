require_relative '../ninja'

# conditionalizes tests that we don't expect to work yet
OPTIMISTIC = false

NOT_WORKING = false; #don't edit this one

#
# rare?
# 

def oughta_be_common(word, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "'#{word}' oughta be common"
    it test_name do
      expect(rare?(word)).to eql(false), "'#{word}' oughta be common, but is rare, with frequency #{frequency(word)}"
    end
  end
end

def oughta_be_rare(word, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "'#{word}' oughta be rare"
    it test_name do
      expect(rare?(word)).to eql(true), "'#{word}' oughta be rare, but is common, with frequency #{frequency(word)}"
    end
  end
end

describe 'RARITY' do
  context 'stop words' do
    oughta_be_common 'a'
    oughta_be_common 'be'
    oughta_be_common 'in'
    oughta_be_common 'me'
    oughta_be_common 'i'
    oughta_be_common 'you'
    oughta_be_common 'to'
    oughta_be_common 'of'
    oughta_be_common 'at'
    oughta_be_common 'he'
    oughta_be_common 'she'
    oughta_be_common 'they'
    oughta_be_common 'their'
    oughta_be_common 'theirs'
    oughta_be_common 'his'
    oughta_be_common 'hers'
    oughta_be_common 'yours'
    oughta_be_common 'my'
    oughta_be_common 'about'
    oughta_be_common 'because'
    oughta_be_common 'and'
  end

  context 'obvious' do
    oughta_be_common 'up'
    oughta_be_common 'away'
    oughta_be_common 'cat'
    oughta_be_common 'alive'
    oughta_be_common "i've"
    oughta_be_common 'next'
    oughta_be_common 'around'
    oughta_be_common 'flight'
    oughta_be_common 'yeah'
    oughta_be_common 'whatever'
  end

  context 'timely' do
    oughta_be_common 'blog'
  end

  context 'rare' do
    oughta_be_rare 'alam'
    oughta_be_rare 'bahm'
    oughta_be_rare 'beacham'
    oughta_be_rare 'bram'
    oughta_be_rare 'burcham'
    oughta_be_rare 'camm'
    oughta_be_rare 'cham'
    oughta_be_rare 'dahm'
    oughta_be_rare 'damm'
    oughta_be_rare 'dirlam'
    oughta_be_rare 'flam'
    oughta_be_rare 'flamm'
    oughta_be_rare 'frahm'
    oughta_be_rare 'gahm'
    oughta_be_rare 'gamm'
    oughta_be_rare 'graeme'
    oughta_be_rare 'gramm'
    oughta_be_rare 'hahm'
    oughta_be_rare 'hamm'
    oughta_be_rare 'hamme'
    oughta_be_rare 'kam'
    oughta_be_rare 'kamm'
    oughta_be_rare 'klamm'
    oughta_be_rare 'kram'
    oughta_be_rare 'kramm'
    oughta_be_rare 'kramme'
    oughta_be_rare 'kvam'
    oughta_be_rare 'kvamme'
    oughta_be_rare 'laflam'
    oughta_be_rare 'laflamme'
    oughta_be_rare 'lahm'
    oughta_be_rare 'lambe'
    oughta_be_rare 'lamm'
    oughta_be_rare 'lamme'
    oughta_be_rare 'mcclam'
    oughta_be_rare 'mcham'
    oughta_be_rare 'mclamb'
    oughta_be_rare 'nahm'
    oughta_be_rare 'nam'
    oughta_be_rare 'pam'
    oughta_be_rare 'panam'
    oughta_be_rare 'pham'
    oughta_be_rare 'plam'
    oughta_be_rare 'quamme'
    oughta_be_rare 'rahm'
    oughta_be_rare 'ramm'
    oughta_be_rare 'sahm'
    oughta_be_rare 'schram'
    oughta_be_rare 'schramm'
    oughta_be_rare 'stam'
    oughta_be_rare 'stamm'
    oughta_be_rare 'stram'
    oughta_be_rare 't-lam'
    oughta_be_rare 'tham'
    oughta_be_rare 'vandam'
    oughta_be_rare 'vandamme'
    oughta_be_rare 'zahm'
    oughta_be_rare 'sadat', NOT_WORKING
    oughta_be_rare 'spratt', NOT_WORKING
    oughta_be_rare 'arnatt'
    oughta_be_rare 'balyeat'
    oughta_be_rare 'batte'
    oughta_be_rare 'bhatt'
    oughta_be_rare 'biernat'
    oughta_be_rare 'blatt'
    oughta_be_rare 'bratt'
    oughta_be_rare 'catt'
    oughta_be_rare 'delatte'
    oughta_be_rare 'deslatte'
    oughta_be_rare 'elat'
    oughta_be_rare 'flatt'
    oughta_be_rare 'glatt'
    oughta_be_rare 'hatt'
    oughta_be_rare 'hnat'
    oughta_be_rare 'inmarsat'
    oughta_be_rare 'jagt'
    oughta_be_rare 'katt'
    oughta_be_rare 'klatt'
    oughta_be_rare 'krat'
    oughta_be_rare 'kratt'
    oughta_be_rare 'labatt'
    oughta_be_rare 'landsat'
    oughta_be_rare 'mcnatt'
    oughta_be_rare 'patt'
    oughta_be_rare 'platt'
    oughta_be_rare 'pratte'
    oughta_be_rare 'prevatt'
    oughta_be_rare 'prevatte'
    oughta_be_rare 'ratte'
    oughta_be_rare 'sarratt'
    oughta_be_rare 'schadt'
    oughta_be_rare 'shatt'
    oughta_be_rare 'slaght'
    oughta_be_rare 'tvsat'
    oughta_be_rare 'junco', NOT_WORKING
    oughta_be_rare 'stylites', NOT_WORKING
  end

  context 'initialisms' do
    oughta_be_rare 'ni', NOT_WORKING
    oughta_be_rare 'cctv', NOT_WORKING
  end

  context 'names' do
    oughta_be_rare 'ciardi', NOT_WORKING
    oughta_be_rare 'tuscaloosa', NOT_WORKING
    oughta_be_rare 'bors', NOT_WORKING
    oughta_be_rare 'matias', NOT_WORKING
    oughta_be_rare 'soweto', NOT_WORKING
    oughta_be_rare 'steinman', NOT_WORKING
  end
  
  context 'uncommon but not rare' do
    oughta_be_common 'astray'
    oughta_be_common 'everyday'
    oughta_be_common 'faraway'
    oughta_be_common 'halfway'
    oughta_be_common 'risque'
    oughta_be_common 'underway'
    oughta_be_common 'renowned'
    oughta_be_common 'newfound'
    oughta_be_common 'shat', NOT_WORKING
    oughta_be_common 'bra'
    oughta_be_common 'daft'
    oughta_be_common 'evict'
    oughta_be_common 'flighty'
    oughta_be_common 'canned'
    oughta_be_common 'convex'
    oughta_be_common 'face-to-face'
    oughta_be_common 'gasoline'
    oughta_be_common 'holy'
    oughta_be_common 'paroled'
    oughta_be_common 'saffron'
    oughta_be_common 'slacker'
    oughta_be_common 'trillion'
    oughta_be_common 'vanes'
    oughta_be_common 'chicanery'
    oughta_be_common 'combatants'
    oughta_be_common 'noncombatants'
    oughta_be_common 'rapt'
    oughta_be_common 'sparkly'
    oughta_be_common 'splashy'
    oughta_be_common 'straightforward'
    oughta_be_common 'suicidal'
    oughta_be_common 'surgical'
    oughta_be_common 'tenuous'
    oughta_be_common 'tearful'
    oughta_be_common 'teary'
    oughta_be_common 'tasteless'
    oughta_be_common 'uncut'
    oughta_be_common 'viral'
    oughta_be_common 'wholehearted'
    oughta_be_common 'aground'
    oughta_be_common 'inbound'
  end

  # context 'filter rare words' do
  # 
  # end

end


#
# rhymes
#

def oughta_rhyme(lang, word1, word2, is_working=true)
  if(is_working or OPTIMISTIC)
    oughta_rhyme_one_way(lang, word1, word2, is_working)
    oughta_rhyme_one_way(lang, word2, word1, is_working)
  end
end

def oughta_rhyme_one_way(lang, word1, word2, is_working=true)
  test_name = "'#{word1}' in #{lang} oughta have '#{word2}' in its list of rhymes"
  it test_name do
    expect(find_preferred_rhyming_words(word1, lang).include?(word2)).to eql(true), "'#{word1}' (pronounced #{pronunciations(word1, lang)}) oughta include '#{word2}' ((pronounced #{pronunciations(word2, lang)}) in its list of rhymes, but instead it only rhymes with #{find_preferred_rhyming_words(word1, lang)}"
  end
end
                
def ought_not_rhyme(lang, word1, word2, is_working=true)
  if(is_working or OPTIMISTIC)
    ought_not_rhyme_one_way(lang, word1, word2, is_working)
    ought_not_rhyme_one_way(lang, word2, word1, is_working)
  end
end

def ought_not_rhyme_one_way(lang, word1, word2, is_working=true)
  test_name = "'#{word1}' in #{lang} ought not have '#{word2}' in its list of rhymes"
  it test_name do
    expect(find_preferred_rhyming_words(word1, lang).include?(word2)).to eql(false), "'#{word1}' (pronounced #{pronunciations(word1, lang)}) ought not include '#{word2}' (pronounced #{pronunciations(word2, lang)}) as a rhyme, but it does, and it also rhymes with #{find_preferred_rhyming_words(word1, lang)}"
  end
end

describe 'RHYMES' do

  context 'no self-rhymes' do
    ought_not_rhyme 'en', 'red', 'red'
  end
  
  context 'basic' do
    ought_not_rhyme 'en', 'beer', 'wine'
    oughta_rhyme 'en', 'yum', 'plum'
    oughta_rhyme 'en', 'space', 'place'
    oughta_rhyme 'en', 'rhyme', 'crime'
    oughta_rhyme 'en', 'gay', 'hooray'
  end
  
  context 'tricky' do
    oughta_rhyme 'en', 'ear', 'beer' # used to fail because ear is [IY1 R] and beer is [B IH1 R]
    oughta_rhyme 'en', "we're", 'queer'
    ought_not_rhyme 'en', 'crime', "yum"
    ought_not_rhyme 'en', 'crime', "'em"
    ought_not_rhyme 'en', 'rhyme', "'em"
    oughta_rhyme 'en', 'station', 'nation'
    oughta_rhyme 'en', 'station', 'education'
    ought_not_rhyme 'en', 'station', 'cation' # it's pronounced "CAT-EYE-ON"
    ought_not_rhyme 'en', 'education', 'cation'
    ought_not_rhyme 'en', 'anion', 'onion' # it's pronounced "ANN-EYE-ON"
  end
  
  context 'perfect rhymes must rhyme the last primary-stressed syllable, not just the last syllable' do
    ought_not_rhyme 'en', 'station', 'shun'
    ought_not_rhyme 'en', 'under', 'fur'
    ought_not_rhyme 'en', 'tea', 'bounty'
  end

  context "you can't just add a prefix and call it a rhyme" do
    oughta_rhyme 'en', 'grape', 'ape' # gr- is not a prefix
    oughta_rhyme 'en', 'pot', 'spot' # s- is not a prefix
    oughta_rhyme 'en', 'under', 'plunder' # pl- is not a prefix
    ought_not_rhyme 'en', 'bone', 'trombone', NOT_WORKING # trom- is not a prefix... but this one is arguable
    
    ought_not_rhyme 'en', 'promising', 'unpromising'
    ought_not_rhyme 'en', 'ion', 'cation'
    
    oughta_rhyme 'en', 'able', 'cable'
    oughta_rhyme 'en', 'unable', 'cable'
    ought_not_rhyme 'en', 'able', 'unable', NOT_WORKING

    ought_not_rhyme 'en', 'traction', 'attraction', NOT_WORKING # arguable
    oughta_rhyme 'en', 'action', 'traction'
    oughta_rhyme 'en', 'action', 'attraction'

    oughta_rhyme 'en', 'ice', 'dice'
    oughta_rhyme 'en', 'ice', 'deice', NOT_WORKING # deice (de-ice) is not in cmudict
    ought_not_rhyme 'en', 'ice', 'deice', NOT_WORKING

    oughta_rhyme 'en', 'stand', 'strand'
    oughta_rhyme 'en', 'understand', 'strand'
    ought_not_rhyme 'en', 'stand', 'understand', NOT_WORKING
  end

  context "spelling variants ought not count as rhymes" do
    ought_not_rhyme 'en', 'adapter', 'adaptor'
    ought_not_rhyme 'en', 'impostor', 'imposter'
    oughta_rhyme_one_way 'en', 'honour', 'goner' # input honour, you oughta get goner
    oughta_rhyme 'en', 'goner', 'honor' # but input goner, and you oughta get honor...
    ought_not_rhyme_one_way 'en', 'goner', 'honour' # ...but not honour
  end

  if(OPTIMISTIC)
  context "homophones ought not count as rhymes" do
    ought_not_rhyme 'en', 'blue', 'blew'
    ought_not_rhyme 'en', 'base', 'bass'
    ought_not_rhyme 'en', 'leader', 'lieder'
    ought_not_rhyme 'en', 'lindsay', 'lindsey'
    ought_not_rhyme 'en', 'hanukkah', 'chanukah' # what if the initial sounds are different, though? Then how do we know to eliminate this?
    ought_not_rhyme 'en', 'lay', 'lei'
  end
  end

  context "rhyming with homophones" do
    # 'lay' ought not rhyme with 'lei', but 'bay' oughta rhyme with both of 'em
    oughta_rhyme 'en', 'bay', 'lay'
    oughta_rhyme 'en', 'bay', 'lei'
  end
  
  context 'profanity is allowed' do
    oughta_rhyme 'en', 'truck', 'fuck'
    oughta_rhyme 'en', 'bunt', 'cunt'
  end
  
  context 'slurs are forbidden' do
    ought_not_rhyme 'en', 'tipsy', 'gypsy'
    ought_not_rhyme 'en', 'fop', 'wop'
    ought_not_rhyme 'en', 'fops', 'wops'
    ought_not_rhyme 'en', 'crannies', 'trannies'
  end

  context 'initialisms' do
    ought_not_rhyme 'en', 'eye', 'ni'
  end
  
  context 'Limerick Heist' do
    oughta_rhyme 'en', 'heist', 'sliced'
    oughta_rhyme 'en', 'heist', 'iced'
    oughta_rhyme 'en', 'tons', 'funds' # [T AH1 N Z] [F AH1 N D Z], N D Z gets collapsed to N Z
  end

  context 'imperfect rhymes' do
    oughta_rhyme 'en', 'foster', 'impostor' # foster [AA S T ER] imposter [AO S T ER]
    oughta_rhyme 'en', 'mushroom', 'doom', NOT_WORKING # no pronunciation for 'mushroom'
  end
end

#
# related
#

def oughta_be_related(lang, word1, word2, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "'#{word1}' in #{lang} oughta be related to '#{word2}'"
    it test_name do
      expect(related?(word1, word2, false, lang)).to eql(true), "Related words for '#{word1}' oughta include '#{word2}', but instead we just get #{find_related_words(word1, false, lang)}"
    end
  end
end
  
def ought_not_be_related(lang, word1, word2, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "'#{word1}' in #{lang} ought not be related to '#{word2}'"
    it test_name do
      expect(related?(word1, word2, false, lang)).to eql(false), "Related words in #{lang} for '#{word1}' ought not include '#{word2}'"
    end
  end
end
  
describe 'RELATED' do
  
  context 'basic' do
    oughta_be_related 'en', 'meow', 'cat'
    oughta_be_related 'en', 'grave', 'death'
  end

  context 'reflexivity' do
    ought_not_be_related 'en', 'death', 'death'
  end

  context 'examples from the documentation' do
    oughta_be_related 'en', 'death', 'bled'
    oughta_be_related 'en', 'death', 'dead'
    oughta_be_related 'en', 'death', 'dread'
  end

  context 'slurs are forbidden' do
    ought_not_be_related 'en', 'gypsy', 'romanian'
    ought_not_be_related 'en', 'romanian', 'gypsy'
    ought_not_be_related 'en', 'gypsies', 'romanian'
    ought_not_be_related 'en', 'romanian', 'gypsies'
  end

  context 'trivial stop words ought not show up as related to anything' do
    ought_not_be_related 'en', 'food', 'the'
  end
  
  if(OPTIMISTIC)
  context 'pirate' do
    ought_not_be_related 'en', 'pirate', 'pew', NOT_WORKING
  end
  end

  context 'halloween' do
    ought_not_be_related 'en', 'halloween', 'ira', NOT_WORKING
    ought_not_be_related 'en', 'halloween', 'lindsay', NOT_WORKING
    ought_not_be_related 'en', 'halloween', 'lindsey', NOT_WORKING
    ought_not_be_related 'en', 'halloween', 'nicki', NOT_WORKING
    ought_not_be_related 'en', 'halloween', 'nikki', NOT_WORKING
    ought_not_be_related 'en', 'halloween', 'pauline', NOT_WORKING
  end
  
end

#
# set_related
#

def set_related_contains?(input, output1, output2, lang)
  # Generate set_related rhymes for INPUT. Does one of them contain both OUTPUT1 and OUTPUT2?
  # e.g. 'pirate', 'handsome', 'ransom'
  for tuple in find_rhyming_tuples(input, lang) do
    if(tuple.include?(output1) and tuple.include?(output2))
      return true
    end
  end
  return false
end

def set_related_oughta_contain(lang, input, output1, output2, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "set_related #{lang}: #{input} -> #{output1} / #{output2}"
    it test_name do
      expect(set_related_contains?(input, output1, output2, lang)).to eql(true), "Set-related rhymes in #{lang} for '#{input}' oughta include '#{output1}' (pronounced #{pronunciations(output1, lang)}) / '#{output2}' (pronounced #{pronunciations(output2, lang)}) / ..., but instead we just get #{find_rhyming_tuples(input, lang)}"
    end
  end
end

def set_related_ought_not_contain(lang, input, output1, output2, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "set_related #{lang}: #{input} !-> #{output1} / #{output2}"
    it test_name do
      expect(set_related_contains?(input, output1, output2, lang)).to eql(false), "Set-related rhymes in #{lang} for '#{input}' ought not include '#{output1}' / '#{output2}' / ..."
    end
  end
end

describe 'SET_RELATED' do

  context 'examples from the documentation' do
    set_related_oughta_contain 'en', 'death', 'bled', 'dread'
    set_related_oughta_contain 'en', 'death', 'bled', 'dead'
    set_related_oughta_contain 'en', 'death', 'dead', 'dread'
  end
  
  context 'pirate' do
    set_related_oughta_contain 'en', 'pirate', 'cove', 'trove'
    set_related_oughta_contain 'en', 'pirate', 'handsome', 'ransom'
    set_related_oughta_contain 'en', 'pirate', 'french', 'wench'
    set_related_oughta_contain 'en', 'pirate', 'gang', 'hang'
    set_related_oughta_contain 'en', 'pirate', 'bold', 'gold'
    set_related_oughta_contain 'en', 'pirate', 'peg', 'leg'
    set_related_oughta_contain 'en', 'pirate', 'daring', 'swearing'
    set_related_oughta_contain 'en', 'pirate', 'hacker', 'cracker' # a different kind of pirate
    set_related_oughta_contain 'en', 'pirate', 'crew', 'tattoo'
    set_related_oughta_contain 'en', 'pirate', 'coast', 'ghost'
    set_related_oughta_contain 'en', 'pirate', 'loot', 'pursuit'
    set_related_oughta_contain 'en', 'pirate', 'buccaneer', 'commandeer'
    set_related_ought_not_contain 'en', 'pirate', 'eyes', 'seas' # via two pronunciations of 'reprise'
  end

  context 'halloween' do
    set_related_oughta_contain 'en', 'halloween', 'celebration', 'decoration'
    set_related_oughta_contain 'en', 'halloween', 'cider', 'spider'
    set_related_oughta_contain 'en', 'halloween', 'sheet', 'treat'
    set_related_oughta_contain 'en', 'halloween', 'bat', 'cat'
    set_related_oughta_contain 'en', 'halloween', 'fairy', 'scary'
    set_related_oughta_contain 'en', 'halloween', 'fright', 'night'
    set_related_ought_not_contain 'en', 'halloween', 'lindsay', 'lindsey', NOT_WORKING
    set_related_ought_not_contain 'en', 'halloween', 'cider', 'snyder', NOT_WORKING
    set_related_ought_not_contain 'en', 'halloween', 'day', 'ira', NOT_WORKING
  end

  context 'music' do
    set_related_oughta_contain 'en', 'music', 'baroque', 'folk'
    set_related_oughta_contain 'en', 'music', 'enjoys', 'noise'
    set_related_oughta_contain 'en', 'music', 'funk', 'punk'
    set_related_oughta_contain 'en', 'music', 'sing', 'swing'
    set_related_oughta_contain 'en', 'music', 'composition', 'musician'
    set_related_oughta_contain 'en', 'music', 'clarinet', 'minuet'
    set_related_oughta_contain 'en', 'music', 'accidental', 'instrumental'
    set_related_oughta_contain 'en', 'music', 'sings', 'strings'
    set_related_oughta_contain 'en', 'music', 'glissando', 'ritardando', NOT_WORKING
    set_related_oughta_contain 'en', 'music', 'viola', 'hemiola', NOT_WORKING
    set_related_oughta_contain 'en', 'music', 'overtone', 'xylophone', NOT_WORKING
    set_related_oughta_contain 'en', 'music', 'wave', 'rave', NOT_WORKING
    set_related_oughta_contain 'en', 'music', 'beat', 'repeat', NOT_WORKING
    set_related_oughta_contain 'en', 'music', 'flow', 'bow', NOT_WORKING
    set_related_oughta_contain 'en', 'music', 'guitar', 'rock star', NOT_WORKING
    set_related_oughta_contain 'en', 'music', 'jingle', 'single', NOT_WORKING # as in a hit single
    set_related_oughta_contain 'en', 'music', 'bar', 'repertoire', NOT_WORKING
    set_related_oughta_contain 'en', 'music', 'harp', 'sharp', NOT_WORKING
    set_related_oughta_contain 'en', 'music', 'show', 'arpeggio', NOT_WORKING # if we squish the stress
    set_related_oughta_contain 'en', 'music', 'mix', 'drumsticks', NOT_WORKING # if we squish the stress
    set_related_oughta_contain 'en', 'music', 'violin', 'mandolin', NOT_WORKING
    set_related_oughta_contain 'en', 'music', 'rest', 'expressed', NOT_WORKING
    set_related_oughta_contain 'en', 'music', 'lute', 'flute', NOT_WORKING
    set_related_oughta_contain 'en', 'music', 'fortissimo', 'pianissimo', NOT_WORKING
    set_related_ought_not_contain 'en', 'music', 'cello', 'solo'
    set_related_ought_not_contain 'en', 'music', 'cello', 'concerto'
    set_related_ought_not_contain 'en', 'music', 'solo', 'concerto'
    set_related_oughta_contain 'en', 'music', 'gong', 'song', NOT_WORKING # reverse relatedness would fix
    set_related_oughta_contain 'en', 'music', 'duet', 'quartet', NOT_WORKING
    set_related_oughta_contain 'en', 'music', 'duet', 'quintet', NOT_WORKING
    it 'no proper subsets: we should get bone / intone / trombone, and not also get bone / intone' do
      bone_intone = ['bone', 'intone']
      bone_intone_trombone = ['bone', 'intone', 'trombone']
      tuples = find_rhyming_tuples('music', 'en')
      expect(tuples.include?(bone_intone_trombone)).to eql(true)
      expect(tuples.include?(bone_intone)).to eql(false)
    end
  end

  if(OPTIMISTIC)
  context 'imperfect' do
    # relax the stress:
    set_related_oughta_contain 'en', 'halloween', 'broom', 'costume'
    set_related_oughta_contain 'en', 'music', 'oboe', 'piano'
    set_related_oughta_contain 'en', 'music', 'cello', 'solo'
    set_related_oughta_contain 'en', 'music', 'cello', 'concerto'
    set_related_oughta_contain 'en', 'music', 'solo', 'concerto'
    # dwim a non-final consonant
    set_related_oughta_contain 'en', 'music', 'symphony', 'timpani'
  end
  end

  context 'no spelling variants' do
    set_related_ought_not_contain 'en', 'agree', 'harmonize', 'harmonise'
    set_related_ought_not_contain 'en', 'ace', 'honor', 'honour'
  end

end

#
# pair_related
#

def pair_related_contains?(lang, input1, input2, output1, output2)
  # Generate pair_related rhymes for INPUT1 / INPUT2. Is one of them "OUTPUT1 / OUTPUT2"?
  target_pair = [output1, output2]
  find_rhyming_pairs(input1, input2, lang).include? target_pair
end

def pair_related_oughta_contain(lang, input1, input2, output1, output2, is_working=true)
  lang = "en"
  if(is_working or OPTIMISTIC)
    test_name = "pair_related #{lang}: #{input1} / #{input2} -> #{output1} / #{output2}"
    it test_name do
      expect(pair_related_contains?(lang, input1, input2, output1, output2)).to eql(true), "Pair-related rhymes in #{lang} for '#{input1}' / '#{input2}' oughta include '#{output1}' (pronounced #{pronunciations(output1, lang)}) / '#{output2}' (pronounced #{pronunciations(output2, lang)}), but instead we just get #{find_rhyming_pairs(input1, input2, lang)}"
    end
  end
end

def pair_related_ought_not_contain(lang, input1, input2, output1, output2, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "pair_related #{lang}: #{input1} / #{input2} !-> #{output1} / #{output2}"
    it test_name do
      expect(pair_related_contains?(lang, input1, input2, output1, output2)).to eql(false), "Pair-related rhymes for '#{input1}' / '#{input2}' ought not include '#{output1}' / '#{output2}'"
    end
  end
end

describe 'PAIR_RELATED' do
  
  context 'examples from the documentation' do
    pair_related_oughta_contain 'en', 'crime', 'heaven', 'confessed', 'blessed'
  end
  
  context 'interactive fiction' do
    pair_related_oughta_contain 'en', 'interactive', 'fiction', 'exciting', 'writing'
  end

  context 'food evil' do
    pair_related_oughta_contain 'en', 'food', 'evil', 'chewed', 'rude'
    pair_related_oughta_contain 'en', 'food', 'evil', 'cuisine', 'mean'
    pair_related_oughta_contain 'en', 'food', 'evil', 'feed', 'greed'
    pair_related_oughta_contain 'en', 'food', 'evil', 'grain', 'pain'
    pair_related_oughta_contain 'en', 'food', 'evil', 'grain', 'bane'
    pair_related_oughta_contain 'en', 'food', 'evil', 'rice', 'vice'
    pair_related_oughta_contain 'en', 'food', 'evil', 'vegetarian', 'totalitarian'
    pair_related_oughta_contain 'en', 'food', 'evil', 'dinner', 'sinner'
    pair_related_oughta_contain 'en', 'food', 'evil', 'cake', 'rake', NOT_WORKING
    pair_related_oughta_contain 'en', 'food', 'evil', 'mushroom', 'doom', NOT_WORKING
    pair_related_oughta_contain 'en', 'food', 'evil', 'chips', 'apocalypse', NOT_WORKING
    pair_related_oughta_contain 'en', 'food', 'evil', 'seder', 'darth vader', NOT_WORKING
    pair_related_oughta_contain 'en', 'food', 'evil', 'sachertort', 'voldemort', NOT_WORKING
    pair_related_oughta_contain 'en', 'food', 'evil', 'bread', 'undead', NOT_WORKING
  end
  
  context 'food dark' do
    pair_related_oughta_contain 'en', 'food', 'dark', 'turkey', 'murky', NOT_WORKING
  end

end

#
# related_rhymes
#

def related_rhymes?(input_rhyme, input_related, output, lang)
  # Generate words that rhyme with input_related and are related to input_related.
  # Is OUTPUT one of them?
  # e.g. 'please', 'cats', 'siamese'
  find_related_rhymes(input_rhyme, input_related, lang).include?(output)
end

def related_rhymes_oughta_contain(lang, input_rhyme, input_related, output, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "related_rhymes #{input_rhyme} + #{input_related} -> #{output}"
    it test_name do
      expect(related_rhymes?(input_rhyme, input_related, output, lang)).to eql(true), "'#{output}' (pronounced #{pronunciations(output, lang)}) oughta be one of the words that rhyme with '#{input_rhyme}' (pronounced #{pronunciations(input_rhyme, lang)}) and is related to '#{input_related}'"
    end
  end
end

def related_rhymes_ought_not_contain(lang, input_rhyme, input_related, output, is_working=true)
  if(is_working or OPTIMISTIC)
    test_name = "related_rhymes #{input_rhyme} + #{input_related} !-> #{output}"
    it test_name do
      expect(related_rhymes?(input_rhyme, input_related, output, lang)).to eql(true), "'#{output}' (pronounced #{pronunciations(output, lang)}) ought not one of the words that rhyme with '#{input_rhyme}' (pronounced #{pronunciations(input_rhyme, lang)}) and is related to '#{input_related}'"
    end
  end
end

describe 'RELATED_RHYMES' do

  context 'examples from the documentation' do
    related_rhymes_oughta_contain 'en', 'please', 'cats', 'siamese'
  end

end
