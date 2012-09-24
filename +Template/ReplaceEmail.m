function out = ReplaceEmail(in,m)
    % default t = now.
    out = regexprep(in, '\$EMAIL\$', strcat('<',m,'>'), 'ignorecase');
end