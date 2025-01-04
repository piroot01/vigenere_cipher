% this is a function for matlab competition
function [crackedKey, crackedText] = crackVigenereCipher(cipherText)
    settings = crack.generate_crack_vigenere_cipher_settings(cipherText);
    cracker = crack.crack_vigenere_cipher(settings);
    crackedKey = cracker.crack_key();
    crackedText = cracker.crack_text(crackedKey);
end