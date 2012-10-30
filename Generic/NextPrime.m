function out = NextPrime(in)
out = in;
if out == 1
    out = 2;
elseif (mod(out,2) == 0)
    out = out + 1;
end

while ~isprime(out)||(out==in)
    out = out + 2;
end
end
