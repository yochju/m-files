function [str y m d] = GetPhotoDateTime(file)
data = imfinfo(file);
str = data.DateTime;
[y m d] = ExtractDate(str);
end

function [y m d] = ExtractDate(str)
  y = str2num(str(1:4));
  m = str2num(str(6:7));
  d = str2num(str(9:10));
end
