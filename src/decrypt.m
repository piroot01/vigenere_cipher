function deciphered_text = decrypt(input_text, key, alphabet)
    % dectrypt the input text using the vigener cipher
    input_text_idx = arrayfun(@(c) find(c == alphabet, 1), input_text);
    key_idx = arrayfun(@(c) find(c == alphabet, 1), ... 
        key(mod((0:numel(input_text) - 1), numel(key)) + 1));

    deciphered_text_idx = mod(input_text_idx - key_idx, ...
        numel(alphabet)) + 1;

    deciphered_text = alphabet(deciphered_text_idx);
end