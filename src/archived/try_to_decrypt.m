function decrypted_key = try_to_decrypt(input_text_encrypted, key_size, alphabet, letter_counts)
    decrypted_indices = zeros([1, numel(key_size)]);
    
    % do the fitness
    for l = 1:key_size
        section = input_text_encrypted(l:key_size:end);
    
        [local_alphabet, counts] = alphabet_histogram(section);
    
        offsets = 0:(numel(alphabet) - 1);
        input_text_idx = mod(arrayfun(@(c) find(c == alphabet, 1), local_alphabet) - offsets' - 1, numel(alphabet)) + 1;
        
        % calculate the fitness
        numerator = sum(letter_counts(input_text_idx) .* counts, 2);
        len_x = sum(letter_counts(input_text_idx).^2, 2);
        len_y = sum(counts.^2);
    
        fitness = numerator ./ sqrt(len_x .* len_y);
    
        [~, max_elem_idx] = max(fitness);
        decrypted_indices(l) = max_elem_idx;
    end
    
    decrypted_key = alphabet(decrypted_indices);
end