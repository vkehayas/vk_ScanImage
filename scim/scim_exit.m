function scim_exit(varargin)
%% function scim_exit(varargin)
%SCIM_EXIT Exits Scanimage (gracefully)
%% SYNTAX
%   scim_exit() --> exits ScanImage unconditionally
%   scim_exit('prompt') --> exits ScanImage only after user confirms intent
%% CHANGES
%   VI110708A: Clear out any other cached figure handles generated during program operation -- Vijay Iyer 11/07/08
%
%% *****************************************

if isempty(whos('global','state')) || isempty(whos('global','gh'))
    error('ScanImage is not running or not running correctly --> cannot exit from Scanimage');
end

global state gh

if ~isempty(varargin)
    if ~ischar(varargin{1}) || ~strcmpi(varargin{1},'prompt')
        error('Invalid argument provided to. Only valid argument is ''prompt''');
    end

    ans =questdlg('Are you sure you want to exit ScanImage?','Exit ScanImage Confirmation','Yes','No','No');

    if strcmpi(ans,'No')
        return; %Abort this exit function
    end
end

%Clear ScanImage's GUI figures...
guiHandles = fieldnames(gh);
for i=1:length(guiHandles)        
    delete(gh.(guiHandles{i}).figure1);
end

%Clear any other figures (VI110708A)
for i=1:length(state.internal.figHandles)
    if ishandle(state.internal.figHandles(i))
        close(state.internal.figHandles(i));
    end
end

%Clear the various acquisition/display figures
for i=1:state.init.maximumNumberOfInputChannels
    if ~isempty(state.internal.GraphFigure(i))
        delete(state.internal.GraphFigure(i));
    end
    
    if ~isempty(state.internal.MaxFigure(i))
        delete(state.internal.MaxFigure(i));
    end   
end
if ~isempty(state.internal.MergeFigure)
    delete(state.internal.MergeFigure);
end
if ~isempty(state.internal.roifigure)
    delete(state.internal.roifigure);
end

%Clear objects owned by Scanimage
stopAllChannels(state.acq.dm);
delete(state.acq.dm);
daqobjs = {'state.init.ai' 'state.init.aiPMTOffsets' 'state.init.ao1' 'state.init.ao2' ...
            'state.init.dio' 'state.init.aiF' 'state.init.ao1F' 'state.init.ao2F' 'state.init.aoPark' ...
            'state.init.aiZoom'};
        
for i=1:length(daqobjs)        
    if ~isempty(eval(daqobjs{i}))
        obj = eval(daqobjs{i});
        if isrunning(obj)
            stop(obj);
        end
        delete(obj);
    end
end
        

%Clear te global variables
clear global gh state;





