function out = ReplaceDate(in,t)
    % default t = now.
    out = regexprep(in, '\$DATE\$', datestr(t,31), 'ignorecase');
end