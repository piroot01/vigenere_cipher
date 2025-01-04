function ciphered_text = encrypt_text(text, key, text_for_letters_path)
    text_for_letters = crack.prepare_text(text_for_letters_path);
    [letters, ~] = crack.letter_histogram(text_for_letters);
    ciphered_text = crack.encrypt(text, key, letters);
end