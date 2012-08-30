function out = ArchiveMedia(src,dest,type)
% Get all files that are in the source directory.
listing = FindAllFiles(src);
%find all the desired files.
files = FindFileType(listing,type);
end
