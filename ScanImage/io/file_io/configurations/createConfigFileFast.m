function createConfigFile(bitFlags, fid, outputFlag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Changed: 
%%      12/15/03 by Tim O'Connor - Bug fix (see below).
%%       TPMOD_1: Modified 12/31/03 Tom Pologruto - Handles defFile Input correctly now       
%%
%%  Copyright - Howard Hughes Medical Institute/Cold Spring Harbor Laboratories 2003
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global configGlobals
if isstruct(configGlobals)
    fNames=fieldnames(configGlobals);
    for i=1:length(fNames)
        recurseCreateConfigFile(fNames{i}, bitFlags, '', fid, outputFlag);
    end
end
recurseCreateConfigFile('state', bitFlags, '', fid, outputFlag);


function recurseCreateConfigFile(startingName, bitFlags, pad, fid, outputFlag)
if length(startingName)==0
    return
end

[topName, structName, fieldName]=structNameParts(startingName);
eval(['global ' topName]);

if eval(['iscell(' startingName ');'])
    return
end			
if length(fieldName)==0
    fieldName=topName;
end
if eval(['~isstruct(' startingName ');'])
    if any(bitand(getGlobalConfigStatus(startingName),bitFlags)) | bitFlags==0			% if 0, output everything for ini file
        val=[];
        eval(['val=' startingName ';']);
        if isnumeric(val)
            if length(val)>1
                %val=['[' num2str(val) ']'];
                % This statement was changed because it generated an error when
                % trying to process the state.init.eom.powerTransitions.protocols 4D array.
                % The error message was: Error using ==> horzcat 
                %                        All matrices on a row in the bracketed expression must have the same number of rows.
                %
                % Ideally, that array does not need saving, since the same information is packed into a string.
                %
                % Tim O'Connor - 12/15/03
                % val = strcat('[', num2str(val), ']');
                %Changed again - Tim O'Connor 3/30/04 TO33004a
                val = ndArray2Str(val);
            else
                val=num2str(val);
            end
        else
            val=['''' val ''''];
        end
        if outputFlag==0
            fprintf(fid, '%s\n', [pad fieldName]);
        else
            fprintf(fid, '%s=%s\n', [pad fieldName], val);
        end				
    end
else
    if ~exist(topName, 'var')
        return 
    end
    if length(fieldName)==0
        fieldName=topName;
    end
    fprintf(fid, [pad 'structure ' fieldName '\n']);
    fNames=[];
    eval(['fNames=fieldnames(' startingName ');']);
    for i=1:length(fNames)
        if ~any(strcmp(fNames{i}, {'configGlobals', 'globalGUIPairs'}))
            recurseCreateConfigFile([startingName '.' fNames{i}], bitFlags, [pad '   '], fid, outputFlag);
        end
    end
    fprintf(fid, [pad 'endstructure\n']);
end
