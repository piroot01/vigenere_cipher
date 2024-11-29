%% main
clc; clearvars;

% add neccessary path
addpath('src');
addpath('data');
addpath('misc');

sonnets = prep_sonnets();

[alphabet, letter_counts] = alphabet_histogram(sonnets);

input_text = strrep(upper(fileread('test06.txt')), newline, '');

orig_key = 'THISISMYKEY';

fprintf("ratio = %f\n", length(input_text) / length(orig_key));

if length(input_text) / length(orig_key) < 37
    disp("The key is too long for the text");
    return;
end

input_text_encrypted = encrypt(input_text, orig_key, alphabet);

disp(input_text_encrypted);

% load the encrypted message
% input_text_encrypted = fileread('data/test02_encrypted.txt');

tic;

map = dictionary_map();

% ngrams of length of 4
ngrams4 = list_ngrams(input_text_encrypted, 4);

divisors_list = list_ngram_distance_divisors(input_text_encrypted, ngrams4);

% key sizes from most relevant to least relevant2
key_sizes = determine_key_sizes(divisors_list);

max_key_size = 256;

% if the key decrypts to text with fitness greater then treshold we
% succeeded
% treshold = 0.96;

% for shakespeare
treshold = 0.95;

rot_treshold_up = 0.9;
rot_treshold_down = 0.7;
rot_dist = 0.1;
rot_letter_count = 4;

% preallocate keys array
num_valid_keys = sum(key_sizes > 1 & key_sizes <= max_key_size);
keys = cell(num_valid_keys, 2);

idx = 1;

potential_rot = cell(length(orig_key), 1);

for key_size = length(orig_key)
    if key_size == 1 || key_size > max_key_size
        continue;
    end

    % decrypted_key = try_to_decrypt(input_text_encrypted, key_size, alphabet, letter_counts)
    decrypted_indices = zeros([2, numel(key_size)]);

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

        [f, ic] = sort(fitness, 'descend');
        alp = alphabet(ic');
        % fprintf("%d - %s\n", l, alphabet(ic'));
        % disp(f(1:rot_letter_count)');
        if (f(1) < rot_treshold_up)
            % disp('sus');
            potential_rot{l, 1} = alp(f > rot_treshold_down);
        end
        %alphabet(idx)

        [~, max_elem_idx] = max(fitness);
        decrypted_indices(l) = max_elem_idx;
    end

    decrypted_key = alphabet(decrypted_indices);

    % decrypted_key = 'KJDSJFIJASOFJSA';
    % decrypted_key = 'KJJSJFIJASOFJSA';

    decrypted_text = decrypt(input_text_encrypted, decrypted_key, alphabet);

    % compute histogram and fitness value
    [decrypted_text_letters, decrypted_text_counts] = alphabet_histogram(decrypted_text);

    % fitness_value = fitness(decrypted_text_letters, decrypted_text_counts, alphabet, letter_counts);

    input_text_idx = mod(arrayfun(@(c) find(c == alphabet, 1), decrypted_text_letters) - 1, numel(alphabet)) + 1;

    numerator = sum(letter_counts(input_text_idx) .* decrypted_text_counts, 2);
    len_x = sum(letter_counts(input_text_idx).^2, 2);
    len_y = sum(decrypted_text_counts.^2);

    fitness_value = numerator ./ sqrt(len_x .* len_y);

    % store the result
    keys{idx, 1} = decrypted_key;
    keys{idx, 2} = fitness_value;
    idx = idx + 1;

    if fitness_value(1) > treshold
        break;
    end
end

continue_perc = 0.8;

examine_length = 100;

if examine_length > length(decrypted_text)
    examine_length = length(decrypted_text);
end

words_ = split(decrypted_text(1:examine_length));

fprintf("continue_perc = %f\n", number_of_elements(words_, map) / length(words_));

if number_of_elements(words_, map) / length(words_) > continue_perc
    toc;
    disp(decrypted_key);
    disp(decrypted_text);
    return;
end

function indices = createIndices(lengths)
    % Input: lengths - Array of lengths of individual arrays
    % Output: indices - Matrix with all combinations of indices
    
    M = numel(lengths);         % Number of arrays
    grids = cell(1, M);         % Prepare cell for grids
    res = arrayfun(@(len) 1:len, lengths, 'UniformOutput', false);
    % Create ranges for each array and compute Cartesian product
    [grids{:}] = ndgrid(res{:});
    
    % Combine grids into a matrix of indices
    indices = zeros(prod(lengths), M);
    for i = 1:M
        indices(:, i) = grids{i}(:);
    end
end

sizes = cellfun(@length, potential_rot);
sizes = sizes(sizes > 0);

key_gen_matrix = createIndices(sizes);

fprintf("key num = %d\n", length(key_gen_matrix));

potential_keys = cell(length(key_gen_matrix), 1);

for l = 1:size(key_gen_matrix, 1)
    test_idx = key_gen_matrix(l, :);

    w = 1;
    kk = decrypted_key;

    for k = 1:length(orig_key)
        if ~isempty(potential_rot{k})
            trim = potential_rot{k};
            s = trim(test_idx(w));
            kk(k) = s;
            potential_keys{l} = kk;
            w = w + 1;
        end
    end
end

sentc_len = length(potential_keys);

potential_results = cell(sentc_len, 1);

for k = 1:length(potential_keys)
    decr = decrypt(input_text_encrypted, potential_keys{k}, alphabet);
    potential_results{k} = decr(1:examine_length);
    % disp(decr(1:examine_length));
end

scores = cell(sentc_len, 2);

for i = 1:sentc_len
    cleanSentence = potential_results{i};
    words = split(cleanSentence);
    
    scores{i, 1} = number_of_elements(words, map);
    scores{i, 2} = potential_keys{i};
end

[~, ixx] = sort([scores{:, 1}], "descend");

kkt = potential_keys(ixx);

disp(orig_key);
disp(kkt{1});
disp(decrypt(input_text_encrypted, kkt{1}, alphabet));

toc;

% trim unused cells (if early break occurred)
keys = keys(1:(idx - 1), :);

% select the best key based on fitness
[~, max_fitness_idx] = max(cell2mat(keys(:, 2)));
chosen_key = keys{max_fitness_idx, 1};

% decipher and display results
deciphered_text = decrypt(input_text_encrypted, chosen_key, alphabet);
disp(chosen_key);
disp(deciphered_text);