function ArchiveMedia(src,dest,type)
if ~strcmp(dest(end),'/')
    dest = [ dest '/'];
end
if ~strcmp(src(end),'/')
    src = [ src '/'];
end
% Get all files that are in the source directory.
listing = FindAllFiles(src);
%find all the desired files.
files = FindFileType(listing,type);

for i = 1:length(files)
    
    [str y m d] = GetPhotoDateTime(files{i});
    
    if ~isdir(dest)
        mkdir(dest)
    end
    
    if ~isdir([dest num2str(y)])
        mkdir([dest num2str(y)]);
    end
    
    if ~isdir([dest num2str(y) '/' num2str(m)])
        mkdir([dest num2str(y) '/' num2str(m)]);
    end
    
    if ~isdir([dest num2str(y) '/' num2str(m) '/' num2str(d)])
        mkdir([dest num2str(y) '/' num2str(m) '/' num2str(d)]);
    end
    
    target = [ ...
        dest ...
        num2str(y) '/' num2str(m) '/' num2str(d) '/' ...
        regexprep(str,'(\d{4}):(\d{2}):(\d{2})','$1-$2-$3')];
    
    if isempty(dir([target '.' type]))
        copyfile(files{i},[target '.' type]);
    else
        num = 1;
        while exist([target '(' num2str(num) ')' '.' type],'file')
            num = num + 1;
        end
        copyfile(files{i},[target '(' num2str(num) ')' '.' type]);
    end
end
end
