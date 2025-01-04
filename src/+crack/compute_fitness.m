function fitness_value = compute_fitness(input_text_letters, input_text_letter_counts, letter_index_lookup_table, letter_count, letter_counts)
    indices = mod(letter_index_lookup_table(input_text_letters) - 1, letter_count) + 1;

    numerator = sum(letter_counts(indices) .* input_text_letter_counts, 2);
    len_x = sum(letter_counts(indices).^2, 2);
    len_y = sum(input_text_letter_counts.^2);

    fitness_value = numerator ./ sqrt(len_x .* len_y);
end