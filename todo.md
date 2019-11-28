## to-do list

* eliminate dependence on datamuse
** wordnet?
** maybe NLTK wup_similarity or https://stackoverflow.com/questions/14148986/how-do-you-write-a-program-to-find-if-certain-words-are-similar/14638272#14638272
* urlencode word links
* reduce dumb outputs
** WordNet contains saffron and paroled. Why do we need lemma_en? We count a word as common if it has a frequency of 2 or more (@todo try upping this) according to lemma_en, or if it exists in WordNet at all. If we upped this to 2, 2/3 of the newly-rare words would be crap, but we would also lose 1/3 good words like chicanery, noncombatants, propagandize, and psilocybin. That's probably okay.
** get rid of plurals, possessives, etc. if they don't add anything new. We could use the actual lemmas in lemma_en! and/or WordNet
** get rid of prefixes
** separate names out
** respect rare_words.txt
** 'saddle' has a bunch of rare words
** put tuples in dregs unless they contain at least two common words
** standardize "i r a" vs. "ira" and "san-jose" oughta be "san_jose" but "so-so" oughta stay "so-so"
** filter out spelling variants from rhyme signature dict, e.g.
*** AH_NG_S_T_AH_R_Z  youngster's youngsters youngsters'
*** UW_S_EH_F  yousef youssef yusef
* improve good outputs
** relatedness isn't symmetric. For set_related, we don't have to go related1, related2, rhyme. We could also go related, rhyme, related to input. Blocked on semantic relatedness.
** look for all plurals that differ in vowels to find more phonemes to conflate, e.g. ORPHANAGE  [AO1 R F AH0 N AH0 JH] ORPHANAGES  [AO1 R F AH0 N IH0 JH IH0 Z]
* imperfect rhymes
** sitter / admit her
** mansion / stanchion
** snapshot -> trap's wrought (if that were an actual phrase)
** snapshot -> trap's wrought (even though that's not an actual phrase)
* test input phrases
* mine Limerick Heist for more test cases

## could-do list

* make better use of vertical space, to reduce the need to scroll down
* add a clickable "x" for "this is a dumb word that should be stricken from the list forever"
** in the dregs, add a clickable up-arrow for "this is a good word that does not deserve to be down here"
* guess at pronunciations of unknown words
* don't use json for the internal dictionaries - it would be nice to be able to grep them. And git wouldn't be so slow and crashy
