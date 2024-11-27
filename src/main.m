%% main
clc; clearvars;

% add neccessary path
addpath('src');
addpath('data');
addpath('misc');

sonnets = prep_sonnets();

[alphabet, letter_counts] = alphabet_histogram(sonnets);

input_text = strrep(upper(fileread('test03.txt')), newline, '');

input_text_encrypted = encrypt(input_text, 'FUCKYOU', alphabet);

% load the encrypted message
% input_text_encrypted = fileread('data/test02_encrypted.txt');

tic;

% ngrams of length of 4
ngrams4 = list_ngrams(input_text_encrypted, 4);

divisors_list = list_ngram_distance_divisors(input_text_encrypted, ngrams4);

% key sizes from most relevant to least relevant
key_sizes = determine_key_sizes(divisors_list);

max_key_size = 50;

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

    % if fitness_value > treshold
    %     break;
    % end
end

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

%% encryption part
clc;

sonnets = prep_sonnets();

[alphabet, letter_counts] = alphabet_histogram(sonnets);

input_text = strrep(upper(fileread('test02.txt')), newline, '');

input_text_encrypted = encrypt(input_text, 'FUCKYOU', alphabet);

fid = fopen('data/test02_encrypted.txt', 'wt');
fprintf(fid, input_text_encrypted);
fclose(fid);

%% full auto
clc; clearvars;

file_content = fileread('words_en.txt');

keywords = splitlines(file_content);

sonnets = prep_sonnets();

[alphabet, letter_counts] = alphabet_histogram(sonnets);

input_text = strrep(upper(fileread('test03.txt')), newline, '');

ciphered_text = encrypt(input_text, 'FUCKYOU', alphabet);

[key_, text] = crackVignereCipher(ciphered_text);

fprintf("The decrypted key: %s\n", key_);
disp(text);


% for k = 1:numel(keywords)
%     key = char(upper(keywords(k)));
% 
%     if numel(key) < 3
%         continue;
%     end
% 
%     ciphered_text = encrypt(input_text, key, alphabet);
% 
%     [key_, text] = crackVignereCipher(ciphered_text);
% 
%     if ~strcmp(key, key_)
%         fprintf("The orig key: %s\n", key);
%         fprintf("The decrypted key: %s\n", key_);
%         disp(text);
%     end
% end