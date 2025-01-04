%% 01: default values
clc; clearvars;

encrypted_text = crack.prepare_text("misc/romeoChorusCiphered.txt");

setings = crack.generate_crack_vigenere_cipher_settings(encrypted_text);

cracker = crack.crack_vigenere_cipher(setings);

tic;
decrypted_key = cracker.crack_key();
toc;

decrypted_text = cracker.crack_text(decrypted_key);

fprintf("decrypted key: %s\ndecrypted text: %s", decrypted_key, decrypted_text);

%% 02: custom text without dictionary
clc; clearvars;

input_text = crack.prepare_text('data/test03.txt');
encrypted_text = encrypt_text(input_text, 'KEY', 'data/sonnets.txt');

setings = crack.generate_crack_vigenere_cipher_settings(encrypted_text);

cracker = crack.crack_vigenere_cipher(setings);

tic;
decrypted_key = cracker.crack_key();
toc;

decrypted_text = cracker.crack_text(decrypted_key);

fprintf("decrypted key: %s\ndecrypted text: %s", decrypted_key, decrypted_text);

%% 03: custom text with dictionary
clc; clearvars;

input_text = crack.prepare_text('data/test03.txt');
encrypted_text = encrypt_text(input_text, 'SECRETKEY', 'data/sonnets.txt');

setings = crack.generate_crack_vigenere_cipher_settings(encrypted_text, ...
                'use_dictionary_attack', true, ...
                'min_key_length', 3, ...
                'max_key_length', 64, ...
                'fitness_threshold', 0.92, ...
                'fitness_threshold_for_substitution_top_value', 0.96, ...
                'fitness_threshold_for_substitution_bottom_value', 0.75);

cracker = crack.crack_vigenere_cipher(setings);

tic;
decrypted_key = cracker.crack_key();
toc;

decrypted_text = cracker.crack_text(decrypted_key);

fprintf("decrypted key: %s\ndecrypted text: %s", decrypted_key, decrypted_text);