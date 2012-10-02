function CheckNumInput(obj, numArgs)
MExc = ExceptionMessage( ...
    'NumArg', ...
    'The number of input parameters does not match the number of parsed args.');
assert( ...
    numArgs <= obj.numReq + obj.numOpt + 2*obj.numPar, ...
    MExc.id, MExc.message );
end