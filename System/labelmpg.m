function labelmpg()
  %% Script used store my videos.
  % Define destination root.
  root = '/home/laurent/Archive/Video/';
  % Work throgh all the subfolders.
  listing = dir('*');
  for i = 1:length(listing)
    if (listing(i).isdir == 1)
      if ~strcmp(listing(i).name,'.') && ~strcmp(listing(i).name,'..')
        cd(listing(i).name);
        labelmpg();
        cd ..;
      end
    end
  end
  % Work through all the files.
  filesl = dir('*.mpg');
  filesL = dir('*.MPG');
  files = cell(1,length(filesl)+length(filesL));
  for i = 1:length(filesl)
    files{i} = filesl(i).name;
  end
  for i = 1:length(filesL)
    files{length(filesl)+i} = filesL(i).name;
  end
  for i = 1:length(files)
      
    data = dir(files{i});
    [y m d] = datevec(data.datenum);
    
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
               datestr(data.datenum,'yyyy-mm-dd HH:MM:SS')];
    
    if isempty(dir([target '.mpg']))
      copyfile(files{i},[target '.mpg']);
    else
      num = 1;
      while exist([target '(' num2str(num) ')' '.mpg'],'file')
        num = num + 1;
      end
      copyfile(files{i},[target '(' num2str(num) ')' '.mpg']);
    end
  end
end
