function varargout = userFcnGUI(varargin)
% userFcnGUI Application M-file for userFcnGUI.fig
%    FIG = userFcnGUI launch userFcnGUI GUI.
%    userFcnGUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 23-Feb-2008 15:13:48

if nargin == 0  % LAUNCH GUI
    
    fig = openfig(mfilename,'reuse');
    
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    guidata(fig, handles);
    
    if nargout > 0
        varargout{1} = fig;
    end
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        disp(lasterr);
    end
    
end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.

% --------------------------------------------------------------------
function varargout = UserFcnBrowser_Callback(h, eventdata, handles, varargin)
global gh state
if strcmp(get(gcf,'SelectionType'),'open')
    val=get(h,'Value');
    str=get(h,'String');
    if iscell(str)
        str=str{val};
    end
    
    if length(str)>2
        if isempty(state.userFcnGUI.UserFcnSelected)
            state.userFcnGUI.UserFcnSelected={str};
        elseif iscellstr(state.userFcnGUI.UserFcnSelected)
            state.userFcnGUI.UserFcnSelected{length(state.userFcnGUI.UserFcnSelected)+1}=...
                str;
        end
        set(gh.userFcnGUI.UserFcnSelected,'String',state.userFcnGUI.UserFcnSelected);
    end
end



% --------------------------------------------------------------------
function varargout = UserFcnSelected_Callback(h, eventdata, handles, varargin)
global gh state
if strcmp(get(gcf,'SelectionType'),'open')
    val=get(h,'Value');
    str=get(h,'String');
    if iscell(str)
        str=str{val};
    end
    evalin('base',['edit ' str(1:end-2)]);
end





% --------------------------------------------------------------------
function varargout = UserFcnPath_Callback(h, eventdata, handles, varargin)
global state gh
genericCallback(h);
if isdir(state.userFcnGUI.UserFcnPath)
    files=dir([state.userFcnGUI.UserFcnPath '*.m']);
    state.userFcnGUI.UserFcnFiles = sortrows({files.name}'); % Sort names
    if ~isempty(state.userFcnGUI.UserFcnFiles)
        set(gh.userFcnGUI.UserFcnBrowser,'String',state.userFcnGUI.UserFcnFiles);
    else
        set(gh.userFcnGUI.UserFcnBrowser,'String',' ');
    end
end



% --------------------------------------------------------------------
function varargout = changePath_Callback(h, eventdata, handles, varargin)
global state gh
path='';
if isdir(state.userFcnGUI.UserFcnPath)
    path=state.userFcnGUI.UserFcnPath;
end

[fname,pname]=uiputfile([path 'Save.m'],'Select Path To User Functions');
if isnumeric(fname)
    return
else
    state.userFcnGUI.UserFcnPath=pname;
end
if isdir(state.userFcnGUI.UserFcnPath)
    files=dir([state.userFcnGUI.UserFcnPath '*.m']);
    state.userFcnGUI.UserFcnFiles = sortrows({files.name}'); % Sort names
    if ~isempty(state.userFcnGUI.UserFcnFiles)
        set(gh.userFcnGUI.UserFcnBrowser,'Value',1,'String',state.userFcnGUI.UserFcnFiles);
    else
        set(gh.userFcnGUI.UserFcnBrowser,'Value',1,'String',' ');
    end
end
updateGUIByGlobal('state.userFcnGUI.UserFcnPath');

% --------------------------------------------------------------------
function varargout = clearAll_Callback(h, eventdata, handles, varargin)
global state gh
state.userFcnGUI.UserFcnSelected=[];
set(gh.userFcnGUI.UserFcnSelected,'Value',1,'String',{''});



% --------------------------------------------------------------------
function varargout = clearSelected_Callback(h, eventdata, handles, varargin)
global gh state
val=get(gh.userFcnGUI.UserFcnSelected,'Value');
if ~isempty(state.userFcnGUI.UserFcnSelected)
    state.userFcnGUI.UserFcnSelected(val)=[];
    if val==1
        newval=1;
    else
        newval=val-1;
    end
    set(gh.userFcnGUI.UserFcnSelected,'Value',newval,'String',state.userFcnGUI.UserFcnSelected);
end

% --------------------------------------------------------------------
function varargout = addAll_Callback(h, eventdata, handles, varargin)
global state gh
state.userFcnGUI.UserFcnSelected=state.userFcnGUI.UserFcnFiles;
set(gh.userFcnGUI.UserFcnSelected,'String',state.userFcnGUI.UserFcnSelected);


% --------------------------------------------------------------------
function varargout = UserFcnOn_Callback(h, eventdata, handles, varargin)
genericCallback(h);