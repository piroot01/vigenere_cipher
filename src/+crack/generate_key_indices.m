function indices = generate_key_indices(substitution_lengths)
    % this function takes the substitution sizes and generate a matrix
    % where each column corresponds to a letter index in the key with
    % potential substitution

    substitution_lengths_count = numel(substitution_lengths);
    grids = cell(1, substitution_lengths_count);
    res = arrayfun(@(len) 1:len, substitution_lengths, 'UniformOutput', false);
    [grids{:}] = ndgrid(res{:});
    
    indices = zeros(prod(substitution_lengths), substitution_lengths_count);
    for i = 1:substitution_lengths_count
        indices(:, i) = grids{i}(:);
    end
end