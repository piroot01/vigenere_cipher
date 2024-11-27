function [alphabet, letter_counts] = alphabet_histogram(input_text)
    alphabet = unique(input_text);
    letter_counts = accumarray(sort(double(input_text(:))) - min(input_text) + 1, 2);
    letter_counts(letter_counts == 0) = [];
    letter_counts = letter_counts';
end