function count = number_of_elements(words, dictionary_map)
    count = sum(isKey(dictionary_map, words));
end