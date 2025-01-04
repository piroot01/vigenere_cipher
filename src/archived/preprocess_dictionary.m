% Read, preprocess, and create the dictionary map
dict = upper(readlines('words_en.txt'));
dict = sort(dict); % Ensure sorted order
dictionary_map = containers.Map(dict, true(1, length(dict))); % Create map with boolean values

% Write the map into a function file
fileID = fopen('data/dictionary_map.m', 'w');
fprintf(fileID, 'function map = dictionary_map()\n');
fprintf(fileID, 'map = containers.Map({');

% Add all dictionary words as keys
for i = 1:length(dict)
    fprintf(fileID, '''%s''', dict{i});
    if i < length(dict)
        fprintf(fileID, ', ');
    end
end

% Add boolean values (true for all keys)
fprintf(fileID, '}, true(1, %d));\n', length(dict));
fprintf(fileID, 'end\n');
fclose(fileID);