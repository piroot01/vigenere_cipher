function result = prepare_text(path)
    raw_text = fileread(path);
    raw_text = upper(raw_text);

    % remove newline hence they are not allowed
    result = strrep(raw_text, newline, '');
end