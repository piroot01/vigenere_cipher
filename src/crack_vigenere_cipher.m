function [decrypted_key, decrypted_text] = crack_vigenere_cipher(text_to_crack, varargin)
    % description will be placed here

    % parse the input parameters
    parser = inputParser;
    addRequired(parser, 'text_to_crack');
    addParameter(parser, 'text_for_frequency_analysis_path', 'data/sonnets.txt');
    addParameter(parser, 'use_dictionary_attack', false, @islogical);
    addParameter(parser, 'ngram_lengths', 4);
    addParameter(parser, 'fitness_threshold', 0.9);
    addParameter(parser, 'fitness_threshold_for_substitution_top_value', 0.99);
    addParameter(parser, 'fitness_threshold_for_substitution_bottom_value', 0.7);
    addParameter(parser, 'max_key_length', 256);
    addParameter(parser, 'min_key_length', 2);
    addParameter(parser, 'max_tested_key_count', 5);
    addParameter(parser, 'max_key_count', 1024);
    addParameter(parser, 'examine_length', 128);

    parse(parser, text_to_crack, varargin{:});

    % save the parameters to settings
    settings = crack.crack_vigenere_cipher_settings;
    settings.text_to_crack = parser.Results.text_to_crack;
    settings.text_for_frequency_analysis_path = parser.Results.text_for_frequency_analysis_path;
    settings.use_dictionary_attack = parser.Results.use_dictionary_attack;
    settings.ngram_lengths = parser.Results.ngram_lengths;
    settings.fitness_threshold = parser.Results.fitness_threshold;
    settings.fitness_threshold_for_substitution_top_value = parser.Results.fitness_threshold_for_substitution_top_value;
    settings.fitness_threshold_for_substitution_bottom_value = parser.Results.fitness_threshold_for_substitution_bottom_value;
    settings.max_key_length = parser.Results.max_key_length;
    settings.min_key_length = parser.Results.min_key_length;
    settings.max_tested_key_count = parser.Results.max_tested_key_count;
    settings.max_key_count = parser.Results.max_key_count;
    settings.examine_length = parser.Results.examine_length;

    cracker = crack.crack_vigenere_cipher(settings);

    [decrypted_key, decrypted_text] = cracker.crack();
end