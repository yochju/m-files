function sref = subsref(obj,s)
% ExcMI = ExceptionMessage('Internal');
ExcMU = ExceptionMessage('Unsupported');
assert(length(s)==1,ExcMU.id,ExcMU.message);

% FIXME: I(:) has meaningless padding data.

switch s(1).type
    case '.'
        sref = builtin('subsref',obj,s);
        %{
        switch s(1).subs
            case 'padding'
                sref = obj.padding;
            otherwise
                error(ExcMI.id,ExcMI.message);
        end
        %}
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