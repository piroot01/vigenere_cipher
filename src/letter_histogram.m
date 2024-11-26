function [letters, letter_counts] = letter_histogram(input_text)
    % plot the histogram
   figure('Name', 'histogram');
    letters = unique(input_text);
    letter_counts = histcounts(double(input_text), max(letters) - min(letters) + 1, 'Normalization', 'percentage');
    letter_counts(letter_counts == 0) = [];
    bar(1:numel(letters), letter_counts);
    set(gca, 'XTick', 1:numel(letters));
    set(gca, 'XTickLabels', num2cell(letters));
    xlabel('alphabet');
    ylabel('relative frequency [%]');
    grid on;
end
    