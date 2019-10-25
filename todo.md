## to-do list

* tests
* get rid of rare words
** get rid of most names (people names and place names)
* is_stupid_rhyme gets rid of e.g. pot / spot, which is a perfectly good rhyme.
** adapter / adaptor, base / bass, leader / lieder
** set_related friendship
** set_related pirate: figure out why the "-eer" words didn't all get grouped together
* set_related music 1000: blow / boe / bow + blow / boe / bow / low + boe / bow / low
** two copies of intone / trombone
* what happens if we turn all 0's into schwas?
* figure out the best $datamuse_max
* imperfect rhymes
** snapshot -> trap's wrought (if that were an actual phrase)
** sitter / admit her
* filter / rank by rarity
* filter out words containing numbers
* combine plurals using (s) - optional in text mode, auto in CGI mode. maybe possessives too?
* test phrases

## could-do list

* use wiktionary instead of cmudict
* make words links
* add a clickable "x" for "this is a dumb word that should be stricken from the list forever"
* guess at pronunciations of unknown words
* don't use json for the internal dictionaries - it would be nice to be able to grep them

## beta-testers

* https://www.reddit.com/user/wordgoeshere/
