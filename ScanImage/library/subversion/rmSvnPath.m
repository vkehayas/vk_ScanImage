% rmSvnPath - Remove the ridiculous Subversion nonsense from the path (Storing meta-data with the real data is a stupid scheme!!!).
%
% SYNTAX
%  rmSvnPath
%
% NOTES
%  Since the idiots who wrote Subversion decided to store the meta-data with the actual data, it tends
%  to get added to the Matlab path (using the 'Add with Subfolders...' button in the 'Set Path' GUI).
%  This function will scrub all the "hidden" Subversion (.svn) directories and their children from the path.
%
%  IMPORTANT: The cleaned path will be saved and rehashed. If you actually wanted those directories,
%             they will be sort of permanently be gone from the path. But you don't want them anyway.
%
%  Remember kids, do not store your meta-data with your actual data, that's just dumb.
%
% CHANGES
%
% Created 7/29/08 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function rmSvnPath

pathStr = path;
while ~isempty(pathStr)
    [currentPathItem, pathStr] = strtok(pathStr, ';');
    if ~isempty(strfind(lower(currentPathItem), '\.svn\'))
        fprintf(1, 'rmSvnPath - Removing ''%s'' from path...\n', currentPathItem);
        rmpath(currentPathItem);
    %else
    %    fprintf(1, 'rmSvnPath - Retaining ''%s'' in path...\n', currentPathItem);
    end
end

savepath
rehash path

return;