function ngrams = list_ngrams(input_text, ngram_lengths)
    ngrams = {};
    current_index = 1;
    
    for ngram_length = ngram_lengths
        len = numel(input_text) - ngram_length + 1;
        
        for i = 1:len
            ngrams{current_index} = input_text(i:i + ngram_length - 1);
            current_index = current_index + 1;
        end
    end
end