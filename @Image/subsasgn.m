function sref = subsasgn(obj,s,val)
% ExcMI = ExceptionMessage('Internal');
ExcMU = ExceptionMessage('Unsupported');
assert(length(s)==1,ExcMU.id,ExcMU.message);

sref = obj;

switch s(1).type
    case '.'
        builtin('subsasgn',sref,s,val);
        %switch s(1).subs
        %    case 'padding'
        %        sref = val.padding;            
        %end
    case '()'
        assert(isa(val,'double'),ExcMU.id,ExcMU.message);
        sf = double(obj);
        subsasgn(sf,s,val);
        sref = Image(sf);
        sref.padding = obj.padding;
        %{
        if length(s)<2
            if strcmp(class(val),'Image')
                error('Image:subsasgn',['Cannot subassign value of class ' class(val) '.']);
            elseif strcmp(class(val),'double')
                sf = double(obj);
                subsasgn(sf,S,val);
                sref = Image(sf);
                sref.type = obj.type;
                sref.padding = obj.padding;
            else
                error('Image:subsasgn',...
                    'Not supported.');
            end
        end
        %}
    case '{}'
       error(ExcMU.id,ExcMU.message);
    otherwise
        ExcMO=ExceptionMessage('UnknownOp');
        error(ExcMO.id,ExcMO.message);
end

end