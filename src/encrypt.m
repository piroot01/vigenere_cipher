function ciphered_text = encrypt(input_text, key, alphabet)
    % encrypt the input text using the vigenere cipher
    input_text_idx = arrayfun(@(c) find(c == alphabet, 1), input_text);
    key_idx = arrayfun(@(c) find(c == alphabet, 1), ... 
        key(mod((0:numel(input_text) - 1), numel(key)) + 1));

    ciphered_text_idx = mod(input_text_idx + key_idx - 2, ...
        numel(alphabet)) + 1;

    ciphered_text = alphabet(ciphered_text_idx);
end