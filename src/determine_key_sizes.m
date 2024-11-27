function key_sizes = determine_key_sizes(cell_divisors)
    array_divisors = [cell_divisors{:}];
    [unique_divs, ~, indices] = unique(array_divisors);
    counts = accumarray(indices, 1);
    [~, sort_idx] = sort(counts, 'descend');
    key_sizes = unique_divs(sort_idx);
end