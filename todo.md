## to-do list

* eliminate dependence on datamuse
** wordnet?
** maybe NLTK wup_similarity or https://stackoverflow.com/questions/14148986/how-do-you-write-a-program-to-find-if-certain-words-are-similar/14638272#14638272
* fix indention upon word wrap
* urlencode word links
* reduce dumb outputs
** get rid of plurals, possessives, etc. if they don't add anything new
** get rid of prefixes
** respect rare_words.txt
** separate names out
** 'saddle' has a bunch of rare words
* improve good outputs
** what happens if we turn all 0's into schwas?
** relatedness isn't symmetric. For set_related, we don't have to go related1, related2, rhyme. We could also go related, rhyme, related to input. Blocked on semantic relatedness.
** look for all plurals that differ in vowels to find more phonemes to conflate, e.g. ORPHANAGE  [AO1 R F AH0 N AH0 JH] ORPHANAGES  [AO1 R F AH0 N IH0 JH IH0 Z]
* imperfect rhymes
** sitter / admit her
** snapshot -> trap's wrought (if that were an actual phrase)
** snapshot -> trap's wrought (even though that's not an actual phrase)
* test input phrases
* mine Limerick Heist for more test cases

## could-do list

* avoid having to ever scroll down
* add a clickable "x" for "this is a dumb word that should be stricken from the list forever"
* guess at pronunciations of unknown words
* don't use json for the internal dictionaries - it would be nice to be able to grep them. And git wouldn't be so slow and crashy
* drag and drop for two-word combos
* add another input form at the bottom
* add definition (i.e. singleton synsets)

## wishlist (feature requests from users)

* find Spanish data sets, unstub rimar.rb

## potential beta-testers

* https://www.reddit.com/user/wordgoeshere/
