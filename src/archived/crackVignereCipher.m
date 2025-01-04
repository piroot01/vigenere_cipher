function [crackedKey, crackedText] = crackVignereCipher(cipherText)
    sonnets = prep_sonnets();
    
    [alphabet, letter_counts] = alphabet_histogram(sonnets);
    
    % load the encrypted message
    input_text_encrypted = cipherText;
    
    % tic;
    
    % ngrams of length of 4
    ngrams4 = list_ngrams(input_text_encrypted, 4);
    
    divisors_list = list_ngram_distance_divisors(input_text_encrypted, ngrams4);
    
    % key sizes from most relevant to least relevant
    key_sizes = determine_key_sizes(divisors_list);
    
    max_key_size = 32;
    
    % if the key decrypts to text with fitness greater then treshold we
    % succeeded
    treshold = 0.96;
    
    % preallocate keys array
    num_valid_keys = sum(key_sizes > 1 & key_sizes <= max_key_size);
    keys = cell(num_valid_keys, 2);
    
    idx = 1;
    
    for key_size = key_sizes
        if key_size == 1 || key_size > max_key_size
            continue;
        end
    
        decrypted_key = try_to_decrypt(input_text_encrypted, key_size, alphabet, letter_counts);
        decrypted_text = decrypt(input_text_encrypted, decrypted_key, alphabet);
    
        % compute histogram and fitness value
        [decrypted_text_letters, decrypted_text_counts] = alphabet_histogram(decrypted_text);
        fitness_value = fitness(decrypted_text_letters, decrypted_text_counts, alphabet, letter_counts);
    
        % store the result
        keys{idx, 1} = decrypted_key;
        keys{idx, 2} = fitness_value;
        idx = idx + 1;
    
        if fitness_value > treshold
            break;
        end
    end
    
    % toc;
    
    % trim unused cells (if early break occurred)
    keys = keys(1:(idx - 1), :);
    
    % select the best key based on fitness
    [~, max_fitness_idx] = max(cell2mat(keys(:, 2)));
    chosen_key = keys{max_fitness_idx, 1};
    
    % decipher and display results
    deciphered_text = decrypt(input_text_encrypted, chosen_key, alphabet);

    crackedKey = chosen_key;
    crackedText = deciphered_text;
end