# Vigenère Cipher Cracker

A MATLAB-based implementation of Vigenère cipher cracking using frequency analysis
and Kasiski examination. Includes optional dictionary-based refinement for
improved accuracy.

## Basic Usage

See the ```example.m```.

## Configuration Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text_to_crack | string | - | The encrypted text you want to decrypt |
| text_for_frequency_analysis_path | string | - | Path to reference text file (same language as original text) |
| use_dictionary_attack | boolean | false | Enables dictionary-based refinement for improved accuracy (English only) |
| ngram_lengths | array | [4] | Array of n-gram lengths for Kasiski examination |
| fitness_threshold | float | 0.9 | Threshold for accepting potential solution (0.0-1.0) |
| fitness_threshold_for_substitution_top_value | float | 0.95 | Upper bound for letter substitution |
| fitness_threshold_for_substitution_bottom_value | float | 0.7 | Lower bound for letter substitution |
| max_key_length | integer | 256 | Maximum key length to consider |
| min_key_length | integer | 3 | Minimum key length to consider |
| max_tested_key_count | integer | 5 | Number of most likely key lengths to test |
| examine_length | integer | 128 | Text length to examine during dictionary attack |
| max_key_count | integer | 1024 | Maximum number of keys to generate in dictionary attack |

## Limitations

- The dictionary attack works only on English texts and 
- When using only the frequency analysis the accuracy depends on reference text similarity to original text
- Encrypted text length must be significantly longer than the key length for reliable frequency analysis
  - Rule of thumb: text length should be at least 20-25 times the key length
  - Shorter texts may yield unreliable results or fail to crack

## Debugging Guide

If you encounter issues:

1. Dictionary Attack Optimization
   - If max_key_count error occurs, narrow the fitness threshold interval:
   - Decrease `fitness_threshold_for_substitution_top_value` (e.g., from 0.9 to 0.85)
   - Increase `fitness_threshold_for_substitution_bottom_value` (e.g., from 0.7 to 0.75)
   - This reduces potential letter substitutions and total key combinations

2. Frequency Analysis Issues
   - Ensure encrypted text is long enough relative to suspected key length
   - Use reference text from similar genre/time period as original text
   - Try adjusting ngram_lengths for different key length detection
