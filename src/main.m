%% main
clc; clear all;

% add neccessary path
addpath('src');
addpath('data');

% sonnets = prep_sonnets();
% 
% [letters, letter_counts] = letter_histogram(sonnets);
% 
% key = 'ABCD';
% 
% word = upper('cryptoisshortforcryptography');
% 
% tic;
% 
% ciphered = encrypt(word, key, letters)
% 
% toc;
% 
% tic;
% 
% deciphered = decrypt(ciphered, key, letters)
% 
% toc

function ngrams = list_ngrams(text, n)
    % Ensure n is valid
    if n > numel(text)
        ngrams = {}; % Return empty if n is larger than the text
        return;
    end

    % Generate all n-grams using array slicing
    ngrams = arrayfun(@(i) text(i:i+n-1), 1:(numel(text)-n+1), 'UniformOutput', false);
end

function ngram_distances = list_ngram_distances(text, ngrams)
    ngram_distances = cell(numel(ngrams), 2);

    for i = 1:numel(ngrams)
        current_ngram = ngrams{i};
        indices = strfind(text, current_ngram);
    
        if numel(indices) > 1
            max_distance = max(diff(indices));
            ngram_distances{i, 1} = current_ngram;
            ngram_distances{i, 2} = max_distance;
            ngrams{indices(2)} = nan;
        else
            ngram_distances{i} = nan;
        end
    end
    
    ngram_distances = ngram_distances(~cellfun(@(x) isequaln(x, nan), ...
        ngram_distances(:, 1)), :);
end

word = upper('cryptoisshortforcryptography');

tic;

ngrams = [list_ngrams(word, 4), list_ngrams(word, 3)];

toc;

tic;

ngram_distances = list_ngram_distances(word, ngrams);

toc;
