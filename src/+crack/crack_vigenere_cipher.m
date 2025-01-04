classdef crack_vigenere_cipher < handle
    % crack_vigenere_cipher Implements frequency analysis based Vigenère cipher cracking
    % Uses Kasiski examination and letter frequency analysis to decrypt Vigenère 
    % encrypted text. Optionally performs dictionary-based refinement.
    
    properties (Access = private)
        settings_ crack.crack_vigenere_cipher_settings;  % Configuration settings
        letters_;        % Array of valid cipher alphabet characters
        letter_counts_;  % Frequency distribution of letters in reference text
        dictionary_;     % Optional dictionary for refinement (word lookup table)
    end

    methods (Access = public)
        function obj = crack_vigenere_cipher(settings)
            % Constructor for the Vigenère cipher cracker
            % Args:
            %     settings: Instance of crack_vigenere_cipher_settings
            obj.settings_ = settings;
        end

        function decrypted_key = crack(obj)
            % Attempts to crack the Vigenère cipher using frequency analysis
            % Returns:
            %     decrypted_key: The most likely encryption key found
            
            obj.prepare_statistics_for_frequency_analysis();
            all_key_lengths = obj.do_kasisky_analysis();
            relevant_key_lengths = obj.pick_relevant_key_lengths(all_key_lengths);
            decrypted_key = obj.crack_with_key_lengths(relevant_key_lengths);
        end
    end

    methods (Access = protected)
        function prepare_statistics_for_frequency_analysis(obj)
            % Prepares letter frequency statistics from reference text
            text_for_frequency_analysis = crack.prepare_text(obj.settings_.text_for_frequency_analysis_path);
            [obj.letters_, obj.letter_counts_] = crack.letter_histogram(text_for_frequency_analysis);
        end
    
        function key_lengths = do_kasisky_analysis(obj)
            % Performs Kasiski examination to find potential key lengths
            % Returns:
            %     key_lengths: Array of possible key lengths sorted by likelihood
            
            ngrams = crack.list_ngrams(obj.settings_.text_to_crack, obj.settings_.ngram_lengths);
            divisors = crack.list_ngram_distance_divisors(obj.settings_.text_to_crack, ngrams);
            key_lengths = crack.determine_key_lengths(divisors);
        end

        function key_lengths = pick_relevant_key_lengths(obj, all_key_lengths)
            % Filters key lengths based on configured constraints
            % Args:
            %     all_key_lengths: Array of possible key lengths from Kasiski analysis
            % Returns:
            %     key_lengths: Filtered array of most likely key lengths
            
            mask = ((all_key_lengths >= obj.settings_.min_key_length) & ...
                   (all_key_lengths <= obj.settings_.max_key_length));
            key_lengths = all_key_lengths(mask);
            key_lengths = key_lengths(1:min(end, obj.settings_.max_tested_key_count));
        end

        function [decrypted_key, decrypted_text] = crack_with_key_lengths(obj, key_lengths)
            % Attempts to crack the cipher using frequency analysis for each key length
            % Args:
            %     key_lengths: Array of key lengths to try
            % Returns:
            %     decrypted_key: Most likely encryption key based on fitness scores
            %     decrypted_text: Decrypted text based on the decrypted key
            
            if obj.settings_.use_dictionary_attack
                obj.dictionary_ = crack.english_dictionary_map();
            end

            decrypted_keys = cell(length(key_lengths), 2);
            key_index = 1;
            letter_count = numel(obj.letters_);

            % Create lookup tables for efficient letter indexing
            letters_as_uint8 = uint8(obj.letters_);
            letter_index_lookup_table = zeros(1, max(letters_as_uint8));
            letter_index_lookup_table(letters_as_uint8) = 1:letter_count;

            letter_indices = containers.Map('KeyType', 'char', 'ValueType', 'uint64');
            for k = 1:letter_count
                letter_indices(obj.letters_(k)) = k;
            end

            % Try each potential key length
            for key_length = key_lengths
                decrypted_indices = zeros(1, numel(key_length));
                potential_rotations = cell(key_length, 1);
                
                % Analyze each position in the key
                for key_letter_index = 1:key_length
                    section = obj.settings_.text_to_crack(key_letter_index:key_length:end);            
                    [local_letters, local_letter_counts] = crack.letter_histogram(section);

                    % Calculate correlation with expected frequencies for each shift
                    offsets = 0:(letter_count - 1);
                    indices = mod(letter_index_lookup_table(local_letters) - offsets' - 1, letter_count) + 1;
                    
                    numerator = sum(obj.letter_counts_(indices) .* local_letter_counts, 2);
                    len_x = sum(obj.letter_counts_(indices).^2, 2);
                    len_y = sum(local_letter_counts.^2);
                    fitness = numerator ./ sqrt(len_x .* len_y);

                    if obj.settings_.use_dictionary_attack
                        [f, ic] = sort(fitness, 'descend');
                        alphabet_rotations = obj.letters_(ic');
                        
                        potential_rotations{key_letter_index, 1} = ...
                            alphabet_rotations((f < obj.settings_.fitness_threshold_for_substitution_top_value) ...
                            & (f > obj.settings_.fitness_threshold_for_substitution_bottom_value));
                    end
            
                    [~, max_idx] = max(fitness);
                    decrypted_indices(key_letter_index) = max_idx;
                end
            
                decrypted_key_candidate = obj.letters_(decrypted_indices);
                
                if obj.settings_.use_dictionary_attack
                    decrypted_key_candidate = obj.refine_key_candidate_with_dictionary(...
                        decrypted_key_candidate, potential_rotations);
                end
            
                % Evaluate fitness of the decrypted text
                decrypted_text = crack.decrypt(obj.settings_.text_to_crack, ...
                    decrypted_key_candidate, obj.letters_);
                [decrypted_text_letters, decrypted_text_letter_counts] = ...
                    crack.letter_histogram(decrypted_text);
                fitness_value = crack.compute_fitness(decrypted_text_letters, ...
                    decrypted_text_letter_counts, letter_index_lookup_table, ...
                    letter_count, obj.letter_counts_);
        
                decrypted_keys{key_index, 1} = decrypted_key_candidate;
                decrypted_keys{key_index, 2} = fitness_value;
                key_index = key_index + 1;
        
                if fitness_value > obj.settings_.fitness_threshold
                    break;
                end
            end

            [~, best_key_index] = max([decrypted_keys{:, 2}]);
            decrypted_key = decrypted_keys{best_key_index, 1};
            decrypted_text = crack.decrypt(obj.settings_.text_to_crack, decrypted_key, obj.letters_);
        end

        function decrypted_key_candidate = refine_key_candidate_with_dictionary(...
                obj, initial_key, potential_rotations)
            % Refines key candidates using dictionary-based validation
            % Args:
            %     initial_key: Best key candidate from frequency analysis
            %     potential_rotations: Cell array of alternative letter mappings
            % Returns:
            %     decrypted_key_candidate: Refined key with highest dictionary word count
            
            if all(cellfun(@isempty, potential_rotations))
                decrypted_key_candidate = initial_key;
                return;
            end

            decrypted_text_length = length(obj.settings_.text_to_crack);
            examine_length = min(obj.settings_.examine_length, decrypted_text_length);
            
            substitution_lengths = cellfun(@length, potential_rotations);
            substitution_lengths = substitution_lengths(substitution_lengths > 0);
            key_generation_indices = crack.generate_key_indices(substitution_lengths);
            
            potential_key_count = size(key_generation_indices, 1);
            if potential_key_count > obj.settings_.max_key_count
                error('Key count (%d) exceeds maximum. Adjust parameters.', potential_key_count);
            end

            % Generate and evaluate all potential keys
            decrypted_key_length = length(initial_key);
            potential_keys = cell(potential_key_count, 1);
            potential_results = cell(potential_key_count, 1);
            scores = cell(potential_key_count, 2);

            for key_index = 1:potential_key_count
                key = initial_key;
                substitution_index = 1;
                
                for k = 1:decrypted_key_length
                    if ~isempty(potential_rotations{k})
                        substitutions = potential_rotations{k};
                        key(k) = substitutions(key_generation_indices(key_index, substitution_index));
                        potential_keys{key_index} = key;
                        substitution_index = substitution_index + 1;
                    end
                end

                decrypted_text = crack.decrypt(obj.settings_.text_to_crack, ...
                    potential_keys{key_index}, obj.letters_);
                potential_results{key_index} = decrypted_text(1:examine_length);
                
                words = split(potential_results{key_index});
                scores{key_index, 1} = crack.number_of_elements(words, obj.dictionary_);
                scores{key_index, 2} = potential_keys{key_index};
            end
        
            [~, key_index] = sort([scores{:, 1}], "descend");
            sorted_keys = potential_keys(key_index);
            decrypted_key_candidate = sorted_keys{1};
        end
    end
end