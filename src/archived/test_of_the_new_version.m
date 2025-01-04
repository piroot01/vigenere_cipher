%% test of the new version
clc; clearvars;

% ciphered_text = crack.prepare_text("misc/romeoChorusCiphered.txt");
input_text = crack.prepare_text('data/test03.txt');
ciphered_text = encrypt_text(input_text, 'SECRETKEY', 'data/sonnets.txt');

tic;

decrypted_key = crack_vigenere_cipher(ciphered_text, ...
                'use_dictionary_attack', true, ...
                'min_key_length', 3, ...
                'max_key_length', 64, ...
                'fitness_threshold', 0.92, ...
                'fitness_threshold_for_substitution_top_value', 0.96, ...
                'fitness_threshold_for_substitution_bottom_value', 0.75);

toc;

disp(decrypted_key);