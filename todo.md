## to-do list

* autofill word1 and word2 into the text boxes
* fix indention upon word wrap
* urlencode word links
* reduce dumb outputs
** adapter / adaptor
*** use preferred_form in find_rhyming_words. actually, create find_preferred_rhyming_words.
** American / British differences, e.g. synonym of agree -> harmonize, harmonise, rhymes related to ace: honor / honour
** get rid of plurals, possessives, etc. if they don't add anything new
* improve good outputs
** use all_forms
** what happens if we turn all 0's into schwas?
** relatedness isn't symmetric. For set_related, we don't have to go related1, related2, rhyme. We could also go related, rhyme, related to input. But to do that, we would need to make hundreds of Datamuse calls. So we'll need a faster metric of semantic relatedness.
* imperfect rhymes
** snapshot -> trap's wrought (if that were an actual phrase)
** sitter / admit her
* test input phrases
* mine Limerick Heist for more test cases

## could-do list

* try using wordnet for related words to eliminate dependence on datamuse. Or maybe NLTK wup_similarity or https://stackoverflow.com/questions/14148986/how-do-you-write-a-program-to-find-if-certain-words-are-similar/14638272#14638272
* try v=enwiki for datamuse API, see if it's better
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
