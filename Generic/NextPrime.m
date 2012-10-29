function out = NextPrime(in)
out = in;
while ~isprime(out)
    out = out + 1;
end
end
