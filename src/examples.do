/*
Example data from:
https://www.kaggle.com/datasets/carlosgdcj/genius-song-lyrics-with-language-information/data

// Quick snippet to deal with newline characters in the lyrics variable
python
import pandas as pd
import re

df = pd.read_csv('song_lyrics.csv')
df['lyrics'] = df['lyrics'].str.replace('\s', ' ', regex = True)
df.to_csv('clean_song_lyrics.csv', ignore_index = True)
end
*/

// Loads the data into memory
import delimited ../data/clean_song_lyrics.csv, case(l) clear bindquote(strict)

// Create a new variable for the lyric length
g long lyriclen = strlen(lyrics)

// Save as a Stata file for faster loading in the future:
save ../data/songLyrics.dta, replace

loc t $sevenwords

// Show difference between capture groups, non-capture groups, and 
// not using groups at all:
// Set timer for capture groups
#d ;
timer clear; version 18; timer on 1;
count if ustrregexm(lyrics, `"(`: subinstr loc t " " ")|(", all')"');
timer off 1; timer on 2;
count if regexmatch(lyrics, `"(`: subinstr loc t " " ")|(", all')"');
timer off 2; version 16; timer on 3;
count if regexm(lyrics, `"(`: subinstr loc t " " ")|(", all')"');
timer off 3; version 18; timer on 4;
count if ustrregexm(lyrics, `"(?:`: subinstr loc t " " ")|(?:", all')"');
timer off 4; timer on 5;
count if regexmatch(lyrics, `"(?:`: subinstr loc t " " ")|(?:", all')"');
timer off 5; version 16; timer on 6;
count if regexm(lyrics, `"(?:`: subinstr loc t " " ")|(?:", all')"');
timer off 6; version 18; timer on 7;
count if ustrregexm(lyrics, `"`: subinstr loc t " " "|", all'"');
timer off 7; timer on 8;
count if regexmatch(lyrics, `"`: subinstr loc t " " "|", all'"');
timer off 8; version 16; timer on 9;
count if regexm(lyrics, `"`: subinstr loc t " " "|", all'"');
timer off 9; version 18; timer list;
#d cr 

// Show how to find a specific consecutive duplicated words and any word that 
// is immediately followed by itself
#d ;
loc word `: word 5 of `t'';
timer clear; timer on 1;
count if ustrregexm(lyrics, "\b(`word')\s\1\b");
timer off 1; timer on 2;
count if regexmatch(lyrics, "\b(`word')\s\1\b");
timer off 2; timer on 3;
count if ustrregexm(lyrics, "\b(\w+)\s\1\b");
timer off 3; timer on 4;
count if regexmatch(lyrics, "\b(\w+)\s\1\b");
timer off 4; timer list;
#d cr

// An example of factorization
#d ;
timer clear; timer on 1;
count if ustrregexm(lyrics, "(?:losing|loving|looser|lost|lottery)");
timer off 1; timer on 2;
count if regexmatch(lyrics, "(?:losing|loving|looser|lost|lottery)");
timer off 2; timer on 3;
count if ustrregexm(lyrics, "lo(?:sing|ving|oser|st|ttery)");
timer off 3; timer on 4;
count if regexmatch(lyrics, "lo(?:sing|ving|oser|st|ttery)");
timer off 4; timer list;
#d cr

// Words within a bandwidth of one another
#d ;
loc w1 $bandwidthex ; loc w2 `: word 5 of `t'' ;
timer clear; timer on 1;
count if ustrregexm(lyrics, "\b(?:`w1'\W+(?:\w+\W+){0,10}`w2'|`w2'\W+(?:\w+\W+){0,10}`w1')\b");
timer off 1; timer on 2;
count if regexmatch(lyrics, "\b(?:`w1'\W+(?:\w+\W+){0,10}`w2'|`w2'\W+(?:\w+\W+){0,10}`w1')\b");
timer off 2; timer on 3;
count if ustrregexm(lyrics, "\b(?:`w1'\W+(?:\w+\W+){0,10}?`w2'|`w2'\W+(?:\w+\W+){0,10}?`w1')\b");
timer off 3; timer on 4;
count if regexmatch(lyrics, "\b(?:`w1'\W+(?:\w+\W+){0,10}?`w2'|`w2'\W+(?:\w+\W+){0,10}?`w1')\b");
timer off 4; timer list;
#d cr 



// Alternatives
timer clear
timer on 1
g ustralt1 = ustrregexs(1) if _n == 105519 &									 ///   
			 ustrregexm(lyrics, "(`: word 7 of `t''|`: word 4 of `t'')")
timer off 1
timer on 2
g ustralt2 = ustrregexs(1) if _n == 105519 &									 ///   
			 ustrregexm(lyrics, "(`: word 4 of `t''|`: word 7 of `t'')")
timer off 2
timer on 3
g bstalt1 = regexcapture(1) if _n == 105519 &									 ///   
			 regexmatch(lyrics, "(`: word 7 of `t''|`: word 4 of `t'')")
timer off 3
timer on 4
g bstalt2 = regexcapture(1) if _n == 105519 &									 ///   
			 regexmatch(lyrics, "(`: word 4 of `t''|`: word 7 of `t'')")
timer off 4

di strlen(lyrics[105519])
if ustralt1[105519] == "`: word 7 of `t''" di "Word 7 matched"
if ustralt1[105519] == "`: word 4 of `t''" di "Word 4 matched"
if ustralt2[105519] == "`: word 7 of `t''" di "Word 7 matched"
if ustralt2[105519] == "`: word 4 of `t''" di "Word 4 matched"
if bstalt1[105519] == "`: word 7 of `t''" di "Word 7 matched"
if bstalt1[105519] == "`: word 4 of `t''" di "Word 4 matched"
if bstalt2[105519] == "`: word 7 of `t''" di "Word 7 matched"
if bstalt2[105519] == "`: word 4 of `t''" di "Word 4 matched"
timer list

// Time for an email related example
python 
# import a library to generate random objects
from faker import Faker
# This will vary the number of levels of domains
import random
# Import the Stata API module
from sfi import Data
# Get the number of observations in the dataset
obs = Data.getObsTotal()
# Initialize the Faker class object
fake = Faker()
# Set the pseudorandom object generator seed 
fake.seed(7779311)
# Set the pseudorandom number generator seed
random.seed(8675309)
# Pre-allocate a list that will store the email addresses
emails = [None] * obs
# Loop over observation indices
for i in range(obs):
    # Select a random number of domain & subdomain levels to test
    levels = random.randint(1, 5)
    # Generate the email address and store it in the list object
    emails[i] = fake.user_name() + '@' + fake.domain_name(levels)

# Add a variable to store the email addresses
Data.addVarStrL('email')

# Store the email addresses
Data.store('email', None, emails)

# End the python interpreter
end

// Compress the email variable 
compress email 

// Add the random email addresses to the end of the lyrics
g strL elyrics = lyrics + " " + email

// Get the storage type for email
loc t : type email 

// Test using possessive quantifiers in this instance.
#d ;
timer clear; timer on 1;
g `t' etest1 = ustrregexs(0) if ustrregexm(elyrics, 
"\b[\w\p{P}]+?@[[:alnum:]][-[:alnum:]]{1,62}\.(?:[[:alnum:]][-[:alnum:]]{1,62}\.?){1,5}\b");
timer off 1; timer on 2;
g `t' etest2 = regexcapture(0) if regexmatch(elyrics, 
"\b[\w\p{P}]+?@[[:alnum:]][-[:alnum:]]{1,62}\.(?:[[:alnum:]][-[:alnum:]]{1,62}\.?){1,5}\b");
timer off 2; timer on 3;
g `t' etest3 = ustrregexs(0) if ustrregexm(elyrics, 
"\b[\w\p{P}]++@[[:alnum:]][-[:alnum:]]{1,62}\.(?:[[:alnum:]][-[:alnum:]]{1,62}\.?){1,5}+\b");
timer off 3; timer on 4;
g `t' etest4 = regexcapture(0) if regexmatch(elyrics, 
"\b[\w\p{P}]++@[[:alnum:]][-[:alnum:]]{1,62}\.(?:[[:alnum:]][-[:alnum:]]{1,62}\.?){1,5}+\b");
timer off 4; timer list; 
#d cr


cap noi assert etest1 == email
cap noi assert etest2 == email
cap noi assert etest3 == email
cap noi assert etest4 == email








