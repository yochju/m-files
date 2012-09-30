function out = ReplaceDate(in,t)
    % default t = now. (should not remove the \$. makes updating easier.
    out = regexprep(in, '\$DATE\$', datestr(t,31), 'ignorecase');
end