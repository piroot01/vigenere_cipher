function key_lengths = determine_key_lengths(cell_divisors)
    array_divisors = [cell_divisors{:}];
    [unique_divs, ~, indices] = unique(array_divisors);
    counts = accumarray(indices, 1);
    [~, sort_idx] = sort(counts, 'descend');
    key_lengths = unique_divs(sort_idx);
end