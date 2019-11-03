## to-do list

* improve rare word filtering
* filter out some stop words as related words
* entirely forbid blacklisted words, not just from rhymes. see 'romanian' in spec
* use wordnet to show synonyms
* add definition
* autofill word1 and word2 into the text boxes
* fix indention upon word wrap
* urlencode word links
* adapter / adaptor
* dynamically blacklist words from datamuse
** set_related friendship
* what happens if we turn all 0's into schwas?
* parametrize $datamuse_max, set it to 1000 for behind-the-scenes
* imperfect rhymes
** snapshot -> trap's wrought (if that were an actual phrase)
** sitter / admit her
* filter out words containing numbers
* get rid of plurals, possessives, etc. if they don't add anything new
* test input phrases
* add another input form at the bottom
* mine Limerick Heist for more test cases

## could-do list

* try using wordnet for related words to eliminate dependence on datamuse
* try v=enwiki for datamuse API, see if it's better
* add a clickable "x" for "this is a dumb word that should be stricken from the list forever"
* guess at pronunciations of unknown words
* don't use json for the internal dictionaries - it would be nice to be able to grep them. And git wouldn't be so slow and crashy
* drag and drop for two-word combos

## wishlist (feature requests from users)

* find Spanish data sets, unstub rimar.rb

## potential beta-testers

* https://www.reddit.com/user/wordgoeshere/
