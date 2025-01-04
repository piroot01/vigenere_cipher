function output = prep_sonnets()
    sonnets = fileread('data/sonnets.txt');
    sonnets = upper(sonnets);
    output = strrep(sonnets, newline, '');
end