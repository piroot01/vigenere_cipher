function [letters, letter_counts] = letter_histogram(input_text)
    letters = unique(input_text);
    letter_counts = accumarray(sort(double(input_text(:))) - min(input_text) + 1, 2);
    letter_counts(letter_counts == 0) = [];
    letter_counts = letter_counts';
end