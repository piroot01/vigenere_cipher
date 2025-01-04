function divisors_list = list_ngram_distance_divisors(input_text, ngrams)
    % this is possible issue
    preallocated_size = 10000;

    ngrams_count = numel(ngrams);
    founded_distances = zeros([1, preallocated_size]);

    idx = 1;
    diff_num = 0;
    
    for k = 1:ngrams_count
        current_ngram = ngrams{k};

        if (isnan(current_ngram))
            continue;
        end

        indices = strfind(input_text, current_ngram);

        if (numel(indices) > 1)
            diffs = diff(indices);
            diff_num = numel(diffs);
            founded_distances(idx:(idx + diff_num - 1)) = diffs;
            idx = idx + diff_num;
        end

        for l = indices
            ngrams{l} = nan;
        end
    end

    founded_distances = unique(founded_distances(1:(idx - diff_num)));

    divisors_list = arrayfun(@(x) optimised_divisors(x), founded_distances, 'UniformOutput', false);
end

% much faster boi
function divisors = optimised_divisors(n)
    divisors = find(mod(n, 1:n) == 0);
end