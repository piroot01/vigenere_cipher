function fitness_value = fitness(input_text, input_text_letter_counts, alphabet, letter_counts)
    input_text_idx = mod(arrayfun(@(c) find(c == alphabet, 1), input_text) - 1, numel(alphabet)) + 1;
    
    letter_counts(input_text_idx);

    numerator = sum(letter_counts(input_text_idx) .* input_text_letter_counts, 2);
    len_x = sum(letter_counts(input_text_idx).^2, 2);
    len_y = sum(input_text_letter_counts.^2);

    fitness_value = numerator ./ sqrt(len_x .* len_y);
end