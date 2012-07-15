function sref = subsasgn(obj,s,val)
% ExcMI = ExceptionMessage('Internal');
ExcMU = ExceptionMessage('Unsupported');
assert(length(s)==1,ExcMU.id,ExcMU.message);

sref = obj;

switch s(1).type
    case '.'
        switch s(1).subs
            case 'type'
                sref = obj.type;
            case 'padding'
                sref = obj.padding;
            otherwise
                builtin('subsasgn',sref,s,val);
        end
    case '()'
        assert(isa(val,'double'),ExcMU.id,ExcMU.message);
        sf = double(obj);
        subsasgn(sf,s,val);
        sref = Image(sf);
        sref.padding = obj.padding;
    case '{}'
       error(ExcMU.id,ExcMU.message);
    otherwise
        ExcMO=ExceptionMessage('UnknownOp');
        error(ExcMO.id,ExcMO.message);
end
end