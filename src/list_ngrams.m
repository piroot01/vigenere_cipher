function ngrams = list_ngrams(input_text, n)
    len = numel(input_text) - n + 1;
    ngrams = cell(1, len);

    for i = 1:len
        ngrams{i} = input_text(i:i + n - 1);
    end
end