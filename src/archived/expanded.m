%% main
clc; clearvars;

% add neccessary path
addpath('src');
addpath('data');
addpath('misc');

% first we need to prepare the alphabet statistics
% input parameters: text_for_frequency_analysis_path,
% text_for_decryption_path
function result = prepare_text(path)
    raw_text = upper(fileread(path));

    % remove newline hence they are not allowed
    result = strrep(raw_text, newline, '');
end

% save the sonnets
text_for_freqiency_analysis_path = 'data/sonnets.txt';
text_for_frequency_analysis = prepare_text(text_for_freqiency_analysis_path);

% create the alphabet and letter_counts from the text for frequency analysis
[alphabet, letter_counts] = crack.letter_histogram(text_for_frequency_analysis);

% load the input text
% text_for_decryption_path = 'misc/romeoChorusCiphered.txt';
% text_for_decryption = prepare_text(text_for_decryption_path);

text_for_decryption_path = 'data/test02.txt';
text_for_decryption = prepare_text(text_for_decryption_path);

% input_text_encrypted = text_for_decryption;
input_text_encrypted = crack.encrypt(text_for_decryption, 'FUCKYOU', alphabet);

% just for debugging
disp(input_text_encrypted);
disp(length(input_text_encrypted));

%%

% another input parameter
use_dictionary_attack = false;

tic;

if use_dictionary_attack
    map = dictionary_map();
end

% we proceed to the Kasiski analysis

% this parameter will specify the list of all ngrams which will be used in
% kasisky analysis
ngram_lengths = [4];
ngrams = list_ngrams(input_text_encrypted, ngram_lengths);

% calculate the distances between given ngrams and find its divisors
divisors = list_ngram_distance_divisors(input_text_encrypted, ngrams);

% the most common divisor is the most likely to be the key lenght
key_sizes = determine_key_sizes(divisors);

% when the decripted text matches with the statistics above this threshold
% the decryption is finished
fitness_threshold = 0.9;

% settings for dictionary attack
potential_substitution_fitness_top_value = 0.97;
potential_substitution_fitness_bottom_value = 0.7;

% settings for dictionary analysis
examine_length = 100;

rot_dist = 0.1;
rot_letter_count = 4;

% pick relevant key sizes
function result = choose_key_sizes(all_key_sizes, max_key_count, min_key_length, max_key_length)
    mask = (all_key_sizes >= min_key_length & all_key_sizes <= max_key_length);
    result = all_key_sizes(mask);
    result = result(1:max_key_count);
end

% input parameter
max_key_size = 256;
min_key_size = 2;
max_tested_key_count = 5;
chosen_key_sizes = choose_key_sizes(key_sizes, max_tested_key_count, min_key_size, max_key_size);

keys = cell(length(chosen_key_sizes), 2);

% this is the main loop responsible for decrypting the key
key_index = 1;
for key_size = chosen_key_sizes
    decrypted_indices = zeros([2, numel(key_size)]);

    if use_dictionary_attack
        potential_alphabet_rotations = cell(key_size, 1);
    end

    for key_letter_index = 1:key_size
        section = input_text_encrypted(key_letter_index:key_size:end);

        [local_alphabet, counts] = alphabet_histogram(section);

        offsets = 0:(numel(alphabet) - 1);
        input_text_idx = mod(arrayfun(@(c) find(c == alphabet, 1), local_alphabet) - offsets' - 1, numel(alphabet)) + 1;

        % calculate the fitness values
        numerator = sum(letter_counts(input_text_idx) .* counts, 2);
        len_x = sum(letter_counts(input_text_idx).^2, 2);
        len_y = sum(counts.^2);

        fitness = numerator ./ sqrt(len_x .* len_y);

        % if we choose to use the dictionary attack we save the other
        % potential rotations of the alphabet which could lead to correct
        % key
        if use_dictionary_attack
            % sort the alphabet rotations based on its fitness values
            [f, ic] = sort(fitness, 'descend');
            alphabet_rotations = alphabet(ic');

            % just for debuggiong
            % fprintf("%d - %s\n", key_letter_index, alphabet(ic'));
            % disp(f(1:rot_letter_count)');

            % save all relevant substitutions
            potential_alphabet_rotations{key_letter_index, 1} = ...
                alphabet_rotations((f < potential_substitution_fitness_top_value) & (f > potential_substitution_fitness_bottom_value));
        end

        [~, max_elem_idx] = max(fitness);
        decrypted_indices(key_letter_index) = max_elem_idx;
    end

    decrypted_key = alphabet(decrypted_indices);

    %#ok<*UNRCH>
    if use_dictionary_attack
        % we examine all the relevant rotations and determine their
        % keys, then we test each key against the given dictionary

        decrypted_key = determine_key_with_dictionary(input_text_encrypted, decrypted_key, potential_alphabet_rotations, examine_length, alphabet, map);
    end

    % compute histogram and fitness value
    decrypted_text = decrypt(input_text_encrypted, decrypted_key, alphabet);
    [decrypted_text_letters, decrypted_text_letter_counts] = alphabet_histogram(decrypted_text);
    fitness_value = compute_fitness(decrypted_text_letters, decrypted_text_letter_counts, alphabet, letter_counts);

    % store the result
    keys{key_index, 1} = decrypted_key;
    keys{key_index, 2} = fitness_value;
    key_index = key_index + 1;
    
    % if the fitness of the decrypted text is above fitness_theshold we
    % break the decryption phase and consider the key as valid
    if fitness_value > fitness_threshold
        break;
    end
end

[~, key_index] = max([keys{:, 2}]);
chosen_decrypted_key = keys{key_index, 1};
fprintf("The decrypted key is: %s\n", chosen_decrypted_key);

toc;

function decrypted_key = determine_key_with_dictionary(encrypted_text, decrypted_key, potential_alphabet_rotations, examine_length, alphabet, map)
    decrypted_text_length = length(encrypted_text);
    if examine_length > decrypted_text_length
        examine_length = decrypted_text_length;
    end

    substitution_sizes = cellfun(@length, potential_alphabet_rotations);
    substitution_sizes = substitution_sizes(substitution_sizes > 0);

    key_generation_indices = generate_key_indices(substitution_sizes);

    potential_key_count = size(key_generation_indices, 1);
    % just for debuging
    fprintf("number of keys to test: %d\n", potential_key_count);

    decrypted_key_length = length(decrypted_key);
    potential_keys = cell(potential_key_count, 1);

    % we generate all potential keys
    for key_index = 1:potential_key_count
        test_indices = key_generation_indices(key_index, :);
    
        substitution_index = 1;

        % create a copy of the decrypted key
        key = decrypted_key;
    
        % perform the substitutions according to the potential rotations
        for k = 1:decrypted_key_length
            if ~isempty(potential_alphabet_rotations{k})
                % pick the relevant substitutions
                substitutions = potential_alphabet_rotations{k};

                % based on the key generation indices we pick the relevant
                % substitution
                substitution = substitutions(test_indices(substitution_index));
                key(k) = substitution;
                potential_keys{key_index} = key;
                substitution_index = substitution_index + 1;
            end
        end
    end

    % debug
    % celldisp(potential_keys);

    % for each potential key we generate its variant of decrypted text
    potential_results = cell(potential_key_count, 1);
    for k = 1:potential_key_count
        decrypted_text = decrypt(encrypted_text, potential_keys{k}, alphabet);
        potential_results{k} = decrypted_text(1:examine_length);
    end

    % debug
    % celldisp(potential_results);

    % we asociate a number of words which occurs in the dictionary as a
    % score
    scores = cell(potential_key_count, 2);
    for i = 1:potential_key_count
        relevant_text = potential_results{i};
        words = split(relevant_text);
    
        scores{i, 1} = number_of_elements(words, map);
        scores{i, 2} = potential_keys{i};
    end

    [~, key_index] = sort([scores{:, 1}], "descend");

    sorted_keys = potential_keys(key_index);

    % choose the one with the highest score
    decrypted_key = sorted_keys{1};
end

function indices = generate_key_indices(substitution_sizes)
    % this function takes the substitution sizes and generate a matrix
    % where each column corresponds to a letter index in the key with
    % potential substitution

    substitution_sizes_count = numel(substitution_sizes);
    grids = cell(1, substitution_sizes_count);
    res = arrayfun(@(len) 1:len, substitution_sizes, 'UniformOutput', false);
    [grids{:}] = ndgrid(res{:});
    
    indices = zeros(prod(substitution_sizes), substitution_sizes_count);
    for i = 1:substitution_sizes_count
        indices(:, i) = grids{i}(:);
    end
end