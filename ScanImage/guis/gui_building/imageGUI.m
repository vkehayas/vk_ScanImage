function varargout = imageGUI(varargin)
% IMAGEGUI Application M-file for imageGUI.fig
%    FIG = IMAGEGUI launch imageGUI GUI.
%    IMAGEGUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 12-Feb-2001 16:09:31

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
    end
    
    %%%VI120108A%%%%%%%%%%%%%%%%%%%%%%
    set(fig,'KeyPressFcn',@genericKeyPressFunction);
    %Ensure all children respond to key presses, when they have the focus (for whatever reason)
    kidControls = findall(fig,'Type','uicontrol');
    for i=1:length(kidControls)
        if ~strcmpi(get(kidControls(i),'Style'),'edit')
            set(kidControls(i),'KeyPressFcn',@genericKeyPressFunction');
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
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
function varargout = genericLUT_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.slider1.
global state gh
genericCallback(h);
setImagesToWhole;
updateClim;
tagButton=get(h,'tag');

% --------------------------------------------------------------------
function varargout = imstats_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.currentPosX.
global state
tag=get(h,'tag');
channel=str2num(tag(end));
handle=state.internal.GraphFigure(channel);
ax=findobj(handle,'type','axes');
xlim=ceil(get(ax,'XLim'));
ylim=ceil(get(ax,'YLim'));
data=state.acq.acquiredData{channel}(ylim(1):ylim(2),xlim(1):xlim(2),1);
Image_Stats.mean=mean2(data);
Image_Stats.std=std2(data);
Image_Stats.max=max(max(data));
Image_Stats.min=min(min(data));
Image_Stats.pixels=numel(data)
assignin('base','Image_Stats',Image_Stats);

% --------------------------------------------------------------------
function varargout = histogram_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.currentPosY.
global gh state
tag=get(h,'tag');
channel=str2num(tag(end));
handle=state.internal.GraphFigure(channel);
ax=findobj(handle,'type','axes');
xlim=ceil(get(ax,'XLim'));
ylim=ceil(get(ax,'YLim'));
data=state.acq.acquiredData{channel}(ylim(1):ylim(2),xlim(1):xlim(2),1);
f=figure('DoubleBuffer','on','color','w','NumberTitle','off','Name','Pixel Histogram',...
    'PaperPositionMode','auto','PaperOrientation','landscape'); 
hist(double(reshape(data,numel(data),1)),256);
set(get(gca,'XLabel'),'String','Pixel Intensity','FontWeight','bold','FontSize',12);
set(get(gca,'YLabel'),'String','Number of Pixels','FontWeight','bold','FontSize',12); 

state.internal.figHandles = [f state.internal.figHandles]; %VI110708A



% --------------------------------------------------------------------
function varargout = zoom_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.intensity.
global state gh
setImagesToWhole; 
tag=get(h,'tag');
channel=str2num(tag(end));
string=get(h,'String');
if strcmpi(string,'Zoom')
    handle=state.internal.GraphFigure(channel);
    zoom(handle,'on');
    set(h,'String','Out');
    set(h,'UserData',handle);
else
    zoom(get(h,'UserData'),'off');
    ax=findobj(get(h,'UserData'),'type','axes');
    xlim=get(ax,'XLim');
    ylim=get(ax,'YLim');
    change=0;
    if xlim(1)==0
        xlim(1)=1;
        change=1;
    end
    if ylim(1)==0
        ylim(1)=1;
        change=1;
    end
    set(h,'String','ZOOM');
    set(h,'UserData',[]);
    if change
        set(ax,'YLim',ylim,'XLim',xlim);
    end
end

% --------------------------------------------------------------------
function varargout = currentPosX_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.currentPosX.


% --------------------------------------------------------------------
function varargout = currentPosY_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.currentPosY.


% --------------------------------------------------------------------
function varargout = intensity_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.intensity.
