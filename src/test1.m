function [crackedKey, crackedText] = crackVignereCipher(cipherText)
    % Read the reference text (sonnets)
    sonnet = fileread('data/sonnets.txt');

    % Define the alphabet and initialize frequency array
    alphabet = " !'(),-.:;?ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    alphabetCharArray = char(alphabet);
    alphabetLength = strlength(alphabet);
    frequency = zeros(1, strlength(alphabet));

    % Identify 4-symbol sequences and determine key length
    [sequences, distances] = findFourSymbolSequences(cipherText);
    keyLength = findMostUsedMultiplier(distances);

    % Convert sonnet text to uppercase for consistency
    sonnet = upper(sonnet);

    % Calculate frequency of each character in the text
    for i = 1:length(sonnet)
        charIndex = strfind(alphabet, sonnet(i));
        if ~isempty(charIndex)
            frequency(charIndex) = frequency(charIndex) + 1;
        end
    end
    frequency = frequency / sum(frequency); % Normalize

    % Initialize arrays for the key and keyword
    keyword = zeros(1, keyLength);
    key = '';

    % Process each position in the key
    for k = 1:keyLength
        % Extract every k-th character from the ciphertext
        subtext = cipherText(k:keyLength:end); 

        % Calculate frequency of each character in the subtext
        subtextFreq = zeros(1, alphabetLength);
        for i = 1:length(subtext)
            charIndex = strfind(alphabet, subtext(i));
            if ~isempty(charIndex)
                subtextFreq(charIndex) = subtextFreq(charIndex) + 1;
            end
        end
        subtextFreq = subtextFreq / sum(subtextFreq); % Normalize

        % Compare the shifted frequency with the original using chi-squared test
        chiSquared = zeros(1, alphabetLength);
        for shift = 0:alphabetLength-1
            % Shift the segment frequencies
            shiftedFreq = circshift(subtextFreq, -shift);

            % Compute chi-squared value
            chiSquared(shift + 1) = sum(((shiftedFreq - frequency) .^ 2) ./ frequency);
        end

        % Find the shift with the smallest chi-squared value
        [~, bestShift] = min(chiSquared);

        % Map the shift to the corresponding character in the custom alphabet
        keyword(k) = bestShift - 1;
        key(k) = alphabetCharArray(bestShift - 1);
    end

    % Decrypt the ciphertext using the determined key
    crackedText = vigenereDecryptSimple(cipherText, keyword, alphabetCharArray, alphabetLength);
    crackedKey = key;

    % Helper functions
    function [sequences, distances] = findFourSymbolSequences(text)
        text = char(text); % Convert to character array if necessary
        uniqueSequences = {};
        positions = {};
        sequences = {};
        distances = [];
        for i = 1:length(text) - 3
            sequence = text(i:i+3);
            idx = find(strcmp(uniqueSequences, sequence), 1);
            if isempty(idx)
                uniqueSequences{end+1} = sequence;
                positions{end+1} = i; 
            else
                positions{idx} = [positions{idx}, i];
            end
        end
        for j = 1:length(uniqueSequences)
            locs = positions{j};
            if length(locs) == 2
                sequences{end+1} = uniqueSequences{j};
                distances(end+1) = abs(diff(locs));
            end
        end
    end

    function mostUsedMultiplier = findMostUsedMultiplier(numbers)
        multipliers = [];
        for i = 1:length(numbers)
            num = numbers(i);
            for j = 3:num
                if mod(num, j) == 0
                    multipliers = [multipliers, j];
                end
            end
        end
        if isempty(multipliers)
            mostUsedMultiplier = [];
            return;
        end
        uniqueMultipliers = unique(multipliers);
        counts = histc(multipliers, uniqueMultipliers);
        [~, maxIndex] = max(counts);
        mostUsedMultiplier = uniqueMultipliers(maxIndex);
    end

    function plaintext = vigenereDecryptSimple(ciphertext, keyword, alphabet, alphabetLength)
        cipherIndices = arrayfun(@(c) find(alphabet == c, 1) - 1, ciphertext);
        keyword = mod(keyword, alphabetLength);
        keyLength = length(keyword);
        textLength = length(cipherIndices);
        extendedKeyIndices = repmat(keyword, 1, ceil(textLength / keyLength));
        extendedKeyIndices = extendedKeyIndices(1:textLength);
        plainIndices = mod(cipherIndices - extendedKeyIndices, alphabetLength);
        plaintext = arrayfun(@(idx) alphabet(idx + 1), plainIndices, 'UniformOutput', true);
        plaintext = char(plaintext);
    end
end

% Example usage
tic;
clc; clear; close all;
cipherText = fileread('misc/romeoChorusCiphered.txt');
[crackedKey, crackedText] = crackVignereCipher(cipherText);
disp(['Deduced Key: ', crackedKey]);
disp(crackedText);
toc;
