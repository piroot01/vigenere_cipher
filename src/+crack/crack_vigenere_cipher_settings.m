classdef crack_vigenere_cipher_settings
    properties (Access = public)
        text_to_crack;

        text_for_frequency_analysis_path;

        use_dictionary_attack;

        ngram_lengths;

        fitness_threshold;
        fitness_threshold_for_substitution_top_value;
        fitness_threshold_for_substitution_bottom_value;

        max_key_length;
        min_key_length;
        max_tested_key_count;

        examine_length;

        max_key_count;
    end
end