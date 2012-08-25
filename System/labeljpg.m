function labeljpg()
  %% Script used store my photographs.
  % Define destination root.
  root = '/home/laurent/Archive/Photo/';
  % Work throgh all the subfolders.
  listing = dir('*');
  for i = 1:length(listing)
    if (listing(i).isdir == 1)
      if ~strcmp(listing(i).name,'.') && ~strcmp(listing(i).name,'..')
        cd(listing(i).name);
        labeljpg();
        cd ..;
      end
    end
  end
  % Work through all the files.
  filesl = dir('*.jpg');
  filesL = dir('*.JPG');
  files = cell(1,length(filesl)+length(filesL));
  for i = 1:length(filesl)
    files{i} = filesl(i).name;
  end
  for i = 1:length(filesL)
    files{length(filesl)+i} = filesL(i).name;
  end
  for i = 1:length(files)
      
    data = imfinfo(files{i});
    [y m d] = ExtractDate(data.DateTime);
    
    if ~isdir(root)
      mkdir(root)
    end
    
    if ~isdir([root num2str(y)])
      mkdir([root num2str(y)]);
    end
    
    if ~isdir([root num2str(y) '/' num2str(m)])
      mkdir([root num2str(y) '/' num2str(m)]);
    end
    
    if ~isdir([root num2str(y) '/' num2str(m) '/' num2str(d)])
      mkdir([root num2str(y) '/' num2str(m) '/' num2str(d)]);
    end
    
    target = [ ...
               root ...
               num2str(y) '/' num2str(m) '/' num2str(d) '/' ...
               regexprep(data.DateTime,'(\d{4}):(\d{2}):(\d{2})','$1-$2-$3')];
    
    if isempty(dir([target '.jpg']))
      copyfile(files{i},[target '.jpg']);
    else
      num = 1;
      while exist([target '(' num2str(num) ')' '.jpg'],'file')
        num = num + 1;
      end
      copyfile(files{i},[target '(' num2str(num) ')' '.jpg']);
    end
  end
end

function [y m d] = ExtractDate(str)
  y = str2num(str(1:4));
  m = str2num(str(6:7));
  d = str2num(str(9:10));
end
