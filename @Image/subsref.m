function sref = subsref(obj, s)

% Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
%
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
% Street, Fifth Floor, Boston, MA 02110-1301, USA.

% Last revision on: 18.07.2012 07:01

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