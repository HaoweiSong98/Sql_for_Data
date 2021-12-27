SELECT id, misspelled_word
  FROM word 
 WHERE SOUNDEX(misspelled_word) = SOUNDEX(@word)
 AND
 (LENGTH(misspelled_word) = LENGTH(@word) + 1 
 OR LENGTH(misspelled_word) = LENGTH(@word) - 1 
 OR LENGTH(misspelled_word) = LENGTH(@word));