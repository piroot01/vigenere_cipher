function deciphered_text = decrypt(input_text, key, alphabet)
    % decrypt the input text using the vigener cipher
    input_text_idx = sum((input_text(:)' == alphabet') .* (1:numel(alphabet))', 1);

    key_mod = mod((0:numel(input_text) - 1), numel(key)) + 1;
    key_idx = sum((key(key_mod) == alphabet') .* (1:numel(alphabet))', 1);

    deciphered_text_idx = mod(input_text_idx - key_idx, ...
        numel(alphabet)) + 1;

    deciphered_text = alphabet(deciphered_text_idx);
end