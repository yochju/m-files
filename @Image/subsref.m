function sref = subsref(obj,s)
% ExcMI = ExceptionMessage('Internal');
ExcMU = ExceptionMessage('Unsupported');
assert(length(s)==1,ExcMU.id,ExcMU.message);

switch s(1).type
    case '.'
        switch s(1).subs
            case 'type'
                sref = obj.type;
            case 'padding'
                sref = obj.padding;
            otherwise
                sref = builtin('subsref',obj,s);
        end
    case '()'
        sf = double(obj);
        if ~isempty(s(1).subs)
            sf = subsref(sf,s);
        else
            sf = obj;
        end
        sref = Image(sf);
        sref.padding = obj.padding;
    case '{}'
        error(ExcMU.id,ExcMU.message);
    otherwise
        ExcMO=ExceptionMessage('UnknownOp');
        error(ExcMO.id,ExcMO.message);
end
end