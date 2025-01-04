clc; clearvars;

dict = upper(readlines('words_en.txt'));
sentence = '(HEREFORE REJOIJE? WHAT CONQUEZT BRINGS HE HOTE?WHAT TRIBUTAYIES FOLLOW HIM.TO ROMETO GRACL IN CAPTIVE BOUDS HIS CHARIOT.WHEELS?YOU BLOJKS, YOU STONESB YOU WORSE THAU SENSELESSTHINNS!O YOU HARD HLARTS';

words = split(sentence)

tic;
    sum(ismember(words, dict)')
toc;

function [indices] = batchBinarySearch(dict, words)
    % Vectorized binary search implementation using cellfun
    indices = cellfun(@(word) binarySearch(dict, length(dict), word) ~= -1, words);
end

function [index] = binarySearch(A, n, num)
    left = 1;
    right = n;
    
    while left <= right
        mid = ceil((left + right) / 2);
        if A(mid) == num
            index = mid;
            return;
        elseif A(mid) > num
            right = mid - 1;
        else
            left = mid + 1;
        end
    end
    index = -1;
end

% Example usage:
tic;
    indices = batchBinarySearch(dict, words);
    result = sum(indices);
    disp(result);
toc;

tic;
% Precompute hash table
dictMap = containers.Map(dict, true(1, length(dict)));

% Lookup words
    indices = isKey(dictMap, words);
    result = sum(indices)
toc;
