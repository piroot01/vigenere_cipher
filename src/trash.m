%% optimised
clc; clear all;

% add neccessary path
addpath('src');
addpath('data');
addpath('misc');

sonnets = prep_sonnets();
%
[letters, letter_counts] = letter_histogram(sonnets);
%
% key = 'ABCD';
% 
% word = upper('cryptoisshortforcryptography');
% 
% tic;
% 
% ciphered = encrypt(encrypted_word, key, letters)
% 
% toc;
% 
% tic;
% 
% deciphered = decrypt(ciphered, key, letters)
% 
% toc

function ngrams = list_ngrams(text, n)
    % Preallocate output for performance
    len = numel(text) - n + 1;
    ngrams = cell(1, len);

    % Vectorized slicing using buffer
    text_mat = buffer(double(text), n, n-1, 'nodelay')'; 
    ngrams = mat2cell(text_mat, ones(1, len), n);
end

function ngram_stats = ngram_statistics(text, ngrams)
    ngram_stats = struct('indices', {}, 'distances', {}, 'divisors', {});
    num_ngrams = numel(ngrams);

    parfor k = 1:num_ngrams % Parallel loop for independent computations
        current_ngram = ngrams{k};
        if isnan(current_ngram), continue; end

        % Use strfind replacement with vectorized search
        indices = find(strncmp(text, current_ngram, numel(current_ngram)));

        if numel(indices) > 1
            diffs = diff(indices);
            divs = unique(cell2mat(arrayfun(@divisors, diffs, 'UniformOutput', false)));
            ngram_stats(k).indices = indices;
            ngram_stats(k).distances = diffs;
            ngram_stats(k).divisors = divs;
        end
    end
end

function result = filter_divisors(cell_divisors)
    % Flatten and count divisors efficiently
    all_elements = [cell_divisors{:}];
    [unique_divs, ~, ic] = unique(all_elements);
    counts = accumarray(ic, 1);
    
    % Sort by frequency descending
    [~, sort_idx] = sort(counts, 'descend');
    result = unique_divs(sort_idx);
end

% Example of using the optimized code
encrypted_word = fileread('romeoChorusCiphered.txt');

tic;

% Precompute ngrams for lengths 3 and 4
ngrams3 = list_ngrams(encrypted_word, 3);
ngrams4 = list_ngrams(encrypted_word, 4);

% Calculate statistics using parallelized `ngram_statistics`
stat3 = ngram_statistics(encrypted_word, ngrams3);
stat4 = ngram_statistics(encrypted_word, ngrams4);

% Combine results
stat = [stat3, stat4];

% Extract divisors and filter key sizes
divs = arrayfun(@(s) s.divisors, stat, 'UniformOutput', false);
key_sizes = filter_divisors(divs);

toc;

% Use key sizes for further processing
disp('Key sizes:');
disp(key_sizes);

function ngram_stats = ngram_statistics(text, ngrams)
    ngram_stats = struct();

    struct_idx = 1;

    for k = 1:numel(ngrams)
        current_ngram = ngrams{k};

        if (isnan(current_ngram))
            continue;
        end

        indices = strfind(text, current_ngram);

        if (numel(indices) > 1)
            % determine all differences
            diffs = diff(indices);
            % compute all divisors of all 
            divs = arrayfun(@(x) divisors(x), diffs, 'UniformOutput', false);
            ngram_stats(struct_idx).indices = indices;
            ngram_stats(struct_idx).distances = diffs;
            ngram_stats(struct_idx).divisors = unique([divs{:}]);
            struct_idx = struct_idx + 1;
        end

        for l = indices
            ngrams{l} = nan;
        end
    end
end