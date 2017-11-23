function varargout = uncagingMapper(varargin)
% UNCAGINGMAPPER M-file for uncagingMapper.fig
%      UNCAGINGMAPPER, by itself, creates a new UNCAGINGMAPPER or raises the existing
%      singleton*.
%
%      H = UNCAGINGMAPPER returns the handle to a new UNCAGINGMAPPER or the handle to
%      the existing singleton*.
%
%      UNCAGINGMAPPER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNCAGINGMAPPER.M with the given input arguments.
%
%      UNCAGINGMAPPER('Property','Value',...) creates a new UNCAGINGMAPPER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before uncagingMapper_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to uncagingMapper_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help uncagingMapper

% Last Modified by GUIDE v2.5 02-Mar-2004 17:03:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @uncagingMapper_OpeningFcn, ...
                   'gui_OutputFcn',  @uncagingMapper_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before uncagingMapper is made visible.
function uncagingMapper_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to uncagingMapper (see VARARGIN)

% Choose default command line output for uncagingMapper
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes uncagingMapper wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = uncagingMapper_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function xText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
function xText_Callback(hObject, eventdata, handles)
global state;

genericCallback(hObject);

if state.init.eom.uncagingMapper.x < 0
    state.init.eom.uncagingMapper.x = 0;
elseif state.init.eom.uncagingMapper.x > 1
    state.init.eom.uncagingMapper.x = 1;
end

state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, state.init.eom.uncagingMapper.pixel, 1) = ...
    state.init.eom.uncagingMapper.x;

return;

% --- Executes during object creation, after setting all properties.
function yText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
function yText_Callback(hObject, eventdata, handles)
global state;

genericCallback(hObject);

if state.init.eom.uncagingMapper.y < 0
    state.init.eom.uncagingMapper.y = 0;
elseif state.init.eom.uncagingMapper.y > 1
    state.init.eom.uncagingMapper.y = 1;
end

state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, state.init.eom.uncagingMapper.pixel, 2) = ...
    state.init.eom.uncagingMapper.y;

return;

% --- Executes during object creation, after setting all properties.
function durationText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to durationText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
function durationText_Callback(hObject, eventdata, handles)
global state;

genericCallback(hObject);

if state.init.eom.uncagingMapper.duration < 0
    updateGuiByGlobal('state.init.eom.uncagingMapper.duration', 'Value', 0);
elseif state.init.eom.uncagingMapper.duration
    updateGuiByGlobal('state.init.eom.uncagingMapper.duration', 'Value', 1);
end

state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, state.init.eom.uncagingMapper.pixel, 3) = ...
    state.init.eom.uncagingMapper.duration;

return;

% --- Executes during object creation, after setting all properties.
function autoPowerText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autoPowerText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
function autoPowerText_Callback(hObject, eventdata, handles)
global state;

genericCallback(hObject);

conversion = (getfield(state.init.eom, ['powerConversion' num2str(state.init.eom.uncagingMapper.beam)]) * ...
    state.init.eom.maxPhotodiodeVoltage(state.init.eom.uncagingMapper.beam) * .01);
    
if state.init.eom.powerInMw
    state.init.eom.uncagingMapper.autoPower = 1 / conversion * state.init.eom.uncagingMapper.autoPower;
end

if state.init.eom.uncagingMapper.autoPower > 100
    state.init.eom.uncagingMapper.autoPower = 100;
    
    if state.init.eom.powerInMw
        state.init.eom.uncagingMapper.autoPower = state.init.eom.uncagingMapper.autoPower * conversion;
    end
    
    updateGuiByGlobal('state.init.eom.uncagingMapper.autoPower');
elseif state.init.eom.uncagingMapper.autoPower < state.init.eom.min(state.init.eom.uncagingMapper.beam)
    state.init.eom.uncagingMapper.autoPower = state.init.eom.min(state.init.eom.uncagingMapper.beam);
    
    if state.init.eom.powerInMw
        state.init.eom.uncagingMapper.autoPower = state.init.eom.uncagingMapper.autoPower * conversion;
    end
    
    updateGuiByGlobal('state.init.eom.uncagingMapper.autoPower');
end

return;

% --- Executes during object creation, after setting all properties.
function pixelSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixelSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on slider movement.
function pixelSlider_Callback(hObject, eventdata, handles)
global state;

genericCallback(hObject);

if state.init.eom.uncagingMapper.pixelSliderPosition > state.init.eom.uncagingMapper.pixelSliderLast | ...
        state.init.eom.uncagingMapper.pixelSliderPosition == 1
    
    if state.init.eom.uncagingMapper.pixel < size(state.init.eom.uncagingMapper.pixels, 2)
        %Increment.
        updateGuiByGlobal('state.init.eom.uncagingMapper.pixel', 'Callback', 0, 'Value', state.init.eom.uncagingMapper.pixel + 1);
    end
    
elseif state.init.eom.uncagingMapper.pixelSliderPosition < state.init.eom.uncagingMapper.pixelSliderLast | ...
        state.init.eom.uncagingMapper.pixelSliderPosition == 0
    
    if state.init.eom.uncagingMapper.pixel > 1
        %Decrement.
        updateGuiByGlobal('state.init.eom.uncagingMapper.pixel', 'Callback', 0, 'Value', state.init.eom.uncagingMapper.pixel - 1);
        
    end
end

state.init.eom.uncagingMapper.pixelSliderLast = state.init.eom.uncagingMapper.pixelSliderPosition;

updatePixelDisplay;

return;

% --- Executes during object creation, after setting all properties.
function pixelText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixelText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
function pixelText_Callback(hObject, eventdata, handles)

genericCallback(hObject);


updatePixelDisplay;

return;

% --- Executes during object creation, after setting all properties.
function pixelsText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixelsText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
function pixelsText_Callback(hObject, eventdata, handles)
global state;

genericCallback(hObject);

%Can not be less than 4.
if state.init.eom.uncagingMapper.numberOfPixels < 2
    state.init.eom.uncagingMapper.numberOfPixels = 2;
    updateGuiByGlobal('state.init.eom.uncagingMapper.numberOfPixels');
end

%Make sure it's divisible by 4.
r = rem(state.init.eom.uncagingMapper.numberOfPixels, 4);
if r ~= 0 & state.init.eom.uncagingMapper.numberOfPixels ~= 2
    %Always bump up to the next higest value.
    updateGuiByGlobal('state.init.eom.uncagingMapper.numberOfPixels', 'Value', state.init.eom.uncagingMapper.numberOfPixels - r + 4);
end

%Keep the slider clued in to what's going on.
if state.init.eom.uncagingMapper.numberOfPixels < state.init.eom.uncagingMapper.lastNum

    %We've just decremented.
    updateGuiByGlobal('state.init.eom.uncagingMapper.sliderPosition', 'Value', 0);
    state.init.eom.uncagingMapper.sliderLast = 0;

elseif state.init.eom.uncagingMapper.numberOfPixels > state.init.eom.uncagingMapper.lastNum

    %We've just incremented.
    updateGuiByGlobal('state.init.eom.uncagingMapper.sliderPosition', 'Value', 1);
    state.init.eom.uncagingMapper.sliderLast = 1;

end

%Hang on to this for the next time around, so we can tell if it's a decrement or increment.
state.init.eom.uncagingMapper.lastNum = state.init.eom.uncagingMapper.numberOfPixels;
        
return;

% --- Executes during object creation, after setting all properties.
function pixelsSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixelsSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on slider movement.
function pixelsSlider_Callback(hObject, eventdata, handles)
global state;

genericCallback(hObject);

if state.init.eom.uncagingMapper.sliderPosition > state.init.eom.uncagingMapper.sliderLast | ...
        state.init.eom.uncagingMapper.sliderPosition == 1
    
    updateGuiByGlobal('state.init.eom.uncagingMapper.numberOfPixels', 'Callback', 0, 'Value', state.init.eom.uncagingMapper.numberOfPixels * 2);
    
elseif state.init.eom.uncagingMapper.sliderPosition < state.init.eom.uncagingMapper.sliderLast | ...
        state.init.eom.uncagingMapper.sliderPosition == 0
    
    if state.init.eom.uncagingMapper.numberOfPixels > 2
    
        updateGuiByGlobal('state.init.eom.uncagingMapper.numberOfPixels', 'Callback', 0, 'Value', state.init.eom.uncagingMapper.numberOfPixels / 2);
        
    end
end

%Make sure it's divisible by 4.
r = rem(state.init.eom.uncagingMapper.numberOfPixels, 4);
if r ~= 0 & state.init.eom.uncagingMapper.numberOfPixels ~= 2
    %Always bump up to the next higest value.
    updateGuiByGlobal('state.init.eom.uncagingMapper.numberOfPixels', 'Value', state.init.eom.uncagingMapper.numberOfPixels - r + 4);
end

state.init.eom.uncagingMapper.sliderLast = state.init.eom.uncagingMapper.sliderPosition;
% fprintf(1, 'Max: %s\nMin: %s\nVal: %s\nPixels: %s\n\n', num2str(get(hObject, 'Max')), num2str(get(hObject, 'Min')), num2str(get(hObject, 'Value')), ...
%     num2str(state.init.eom.uncagingMapper.numberOfPixels));
return;

% --- Executes during object creation, after setting all properties.
function autoDurationText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autoDurationText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%-------------------------------------------------------------------
function autoDurationText_Callback(hObject, eventdata, handles)
global state;

genericCallback(hObject);

if state.init.eom.uncagingMapper.autoDuration < 0
    updateGuiByGlobal('state.init.eom.uncagingMapper.autoDuration', 'Value', 0);
elseif state.init.eom.uncagingMapper.autoDuration > 1
    updateGuiByGlobal('state.init.eom.uncagingMapper.autoDuration', 'Value', 1);
end

return;

% --- Executes during object creation, after setting all properties.
function orientationMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orientationMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in orientationMenu.
function orientationMenu_Callback(hObject, eventdata, handles)
genericCallback(hObject);

% --- Executes during object creation, after setting all properties.
function powerText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to powerText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%-------------------------------------------------------------------
function powerText_Callback(hObject, eventdata, handles)
global state;

genericCallback(hObject);

if state.init.eom.powerInMw
    conversion = (getfield(state.init.eom, ['powerConversion' num2str(state.init.eom.uncagingMapper.beam)]) * ...
        state.init.eom.maxPhotodiodeVoltage(state.init.eom.uncagingMapper.beam) * .01);
    
    state.init.eom.uncagingMapper.power = state.init.eom.uncagingMapper.power * conversion;
else
    conversion = 1;
end

if state.init.eom.uncagingMapper.power * conversion < state.init.eom.min(state.init.eom.uncagingMapper.beam)
    state.init.eom.uncagingMapper.power = state.init.eom.min(state.init.eom.uncagingMapper.beam) / conversion;
elseif state.init.eom.uncagingMapper.power * conversion > 1
    state.init.eom.uncagingMapper.power = 1 / conversion;
end

state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, state.init.eom.uncagingMapper.pixel, 4) = ...
    conversion * state.init.eom.uncagingMapper.power;

updateGuiByGlobal('state.init.eom.uncagingMapper.power');

return;

% --- Executes on button press in autoButton.
function autoButton_Callback(hObject, eventdata, handles)
global state gh;

xyCoords = [];

k = 1;
n = state.init.eom.uncagingMapper.numberOfPixels / 2;
for i = 1 : n
    for j = 1 : n
        xyCoords(k, 1) = i;
        xyCoords(k, 2) = j;
        xyCoords(k + 1, 1) = i + n;
        xyCoords(k + 1, 2) = j + n;
        xyCoords(k + 2, 1) = i + n;
        xyCoords(k + 2, 2) = j;
        xyCoords(k + 3, 1) = i;
        xyCoords(k + 3, 2) = j + n;
        k = k + 4;
    end
end

xyCoords = xyCoords - 1;
% figure;plot(xyCoords(:, 1), xyCoords(:, 2), '.')
switch state.init.eom.uncagingMapper.orientation
    case 1
        %Default is top-left.
        
    case 2
        %Shift right.
        xyCoords(:, 1) = xyCoords(:, 1) + 1 - state.init.eom.uncagingMapper.autoDuration;
        
    case 3
        %Center.
        %Shift right by half a pixel.
        xyCoords(:, 1) = xyCoords(:, 1) + .5 - (state.init.eom.uncagingMapper.autoDuration / 2);
        %Shift down by half a pixel.
        xyCoords(:, 2) = xyCoords(:, 2) + .5;
        
    case 4
        %Shift down.
        xyCoords(:, 2) = xyCoords(:, 2) + 1;
        
    case 5
        %Shift down and right.
        xyCoords(:, 1) = xyCoords(:, 1) + 1 - state.init.eom.uncagingMapper.autoDuration;
        xyCoords(:, 2) = xyCoords(:, 2) + 1;
        
    otherwise
        error('UncagingMapper: Unknown orientation for auto-generating uncaging map.');
end
xyCoords = xyCoords ./ state.init.eom.uncagingMapper.numberOfPixels;
%Alex, comment this line out, to not display a plot.
% figure;plot(xyCoords(:, 1), -1 * xyCoords(:, 2), xyCoords(:, 1) + state.init.eom.uncagingMapper.duration, -1 * xyCoords(:, 2), '.'), xlim([0 1]), ylim([-1 0])
% hold on;
% plot(xyCoords(:, 1) + state.init.eom.uncagingMapper.duration, -1 * xyCoords(:, 2), '.')

state.init.eom.uncagingMapper.pixels = [];
state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, :, [1 2]) = xyCoords;
state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, :, 3) = state.init.eom.uncagingMapper.autoDuration;

%Don't forget to store power in %.
if state.init.eom.powerInMw
    conversion = (getfield(state.init.eom, ['powerConversion' num2str(state.init.eom.uncagingMapper.beam)]) * ...
        state.init.eom.maxPhotodiodeVoltage(state.init.eom.uncagingMapper.beam) * .01);
else
    conversion = 1;
end
state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, :, 4) = conversion * state.init.eom.uncagingMapper.autoPower;

enablePixelEditor(1);
state.init.eom.changed(state.init.eom.uncagingMapper.beam);

state.init.eom.uncagingMapper.position = 1;
updateGuiByGlobal('state.init.eom.uncagingMapper.pixel', 'Value', 1, 'Callback', 1);

return;

% --- Executes on button press in perGrabRadioButton.
function perGrabRadioButton_Callback(hObject, eventdata, handles)
global gh;

genericCallback(hObject);
set(hObject, 'Enable', 'Inactive');
set(gh.uncagingMapper.perFrameRadioButton, 'Enable', 'On');
updateGuiByGlobal('state.init.eom.uncagingMapper.perFrame', 'Value', 0);
set(gh.uncagingMapper.perFrameRadioButton, 'Value', 0);

return;

% --- Executes on button press in perFrameRadioButton.
function perFrameRadioButton_Callback(hObject, eventdata, handles)
global gh;

genericCallback(hObject);
set(hObject, 'Enable', 'Inactive');
set(gh.uncagingMapper.perGrabRadioButton, 'Enable', 'On');
updateGuiByGlobal('state.init.eom.uncagingMapper.perGrab', 'Value', 0);
set(gh.uncagingMapper.perGrabRadioButton, 'Value', 0);

return;

% --- Executes on button press in syncToPhysiologyCheckbox.
function syncToPhysiologyCheckbox_Callback(hObject, eventdata, handles)
genericCallback(hObject);

return;

% --- Executes during object creation, after setting all properties.
function beamMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beamMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in beamMenu.
function beamMenu_Callback(hObject, eventdata, handles)

genericCallback(hObject);

updatePixelDisplay;

return;

% --- Executes on button press in enableButton.
function enableButton_Callback(hObject, eventdata, handles)
global state gh;

genericCallback(hObject);
state.init.eom.uncagingMapper.enabled(state.init.eom.uncagingMapper.beam) = ...
    state.init.eom.uncagingMapper.enable;

if state.init.eom.uncagingMapper.enable
    set(gh.uncagingMapper.enableButton, 'String', 'Disable');
    set(gh.uncagingMapper.enableButton, 'ForeGround', [1 0 0]);
else
    set(gh.uncagingMapper.enableButton, 'String', 'Enable');
    set(gh.uncagingMapper.enableButton, 'ForeGround', [0 .6 0]);
end

return;

% --- Executes during object creation, after setting all properties.
function beamSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beamSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function beamSlider_Callback(hObject, eventdata, handles)
global state;

genericCallback(hObject);

if state.init.eom.uncagingMapper.beamSliderPosition > state.init.eom.uncagingMapper.beamSliderLast | ...
        state.init.eom.uncagingMapper.beamSliderPosition == 1
    
    if state.init.eom.uncagingMapper.beam > 1
        %Increment here, since the popup menu is reverse ordered.
        updateGuiByGlobal('state.init.eom.uncagingMapper.beam', 'Callback', 0, 'Value', state.init.eom.uncagingMapper.beam - 1);
    end
    
elseif state.init.eom.uncagingMapper.beamSliderPosition < state.init.eom.uncagingMapper.beamSliderLast | ...
        state.init.eom.uncagingMapper.beamSliderPosition == 0

    if state.init.eom.uncagingMapper.beam < state.init.eom.numberOfBeams
        %Decrement here, since the popup menu is reverse ordered.
        updateGuiByGlobal('state.init.eom.uncagingMapper.beam', 'Callback', 0, 'Value', state.init.eom.uncagingMapper.beam + 1);
    end
end

state.init.eom.uncagingMapper.beamSliderLast = state.init.eom.uncagingMapper.beamSliderPosition;

% updateGuiByGlobal('state.init.eom.uncagingMapper.pixelText', 'Value', 1, 'Callback', 1);
updatePixelDisplay;

return;

% --- Executes on button press in addPixel.
function addPixel_Callback(hObject, eventdata, handles)
% hObject    handle to addPixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in deletePixel.
function deletePixel_Callback(hObject, eventdata, handles)
% hObject    handle to deletePixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in drawButton.
function drawButton_Callback(hObject, eventdata, handles)
% hObject    handle to drawButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%-------------------------------------------------------------------
function updatePixelDisplay
global state gh;

if isempty(state.init.eom.uncagingMapper.pixels)
    updateGuiByGlobal('state.init.eom.uncagingMapper.pixel', 'Value', 1);
    updateGuiByGlobal('state.init.eom.uncagingMapper.x', 'Value', 0);
    updateGuiByGlobal('state.init.eom.uncagingMapper.y', 'Value', 0);
    updateGuiByGlobal('state.init.eom.uncagingMapper.duration', 'Value', 0.5);
    updateGuiByGlobal('state.init.eom.uncagingMapper.power', 'Value', 0);
    
    enablePixelEditor(0);

    return;
end

if state.init.eom.uncagingMapper.pixel < 1
    fprintf(2, 'ERROR (UncagingMapper): Attempting to display invalid pixel - %s\n', ...
        num2str(state.init.eom.uncagingMapper.pixel));

    return;
elseif state.init.eom.uncagingMapper.pixel > size(state.init.eom.uncagingMapper.pixels, 2)
    state.init.eom.uncagingMapper.pixel = size(state.init.eom.uncagingMapper.pixels, 2)
elseif state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, state.init.eom.uncagingMapper.pixel, :) == -1
    %Find the highest valid pixel.
    state.init.eom.uncagingMapper.pixel = min(...
        [ find(state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, :, 1) ~= -1), ...
        find(state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, :, 2) ~= -1), ...
        find(state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, :, 3) ~= -1), ...
        find(state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, :, 4) ~= -1) ]);
    
    if isempty(state.init.eom.uncagingMapper.pixel)
        state.init.eom.uncagingMapper.pixel = 1;
    end
end

updateGuiByGlobal('state.init.eom.uncagingMapper.pixel');

updateGuiByGlobal('state.init.eom.uncagingMapper.x', 'Value', ...
    state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, state.init.eom.uncagingMapper.pixel, 1));

updateGuiByGlobal('state.init.eom.uncagingMapper.y', 'Value', ...
    state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, state.init.eom.uncagingMapper.pixel, 2));

updateGuiByGlobal('state.init.eom.uncagingMapper.duration', 'Value', ...
    state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, state.init.eom.uncagingMapper.pixel, 3));

% updateGuiByGlobal('state.init.eom.uncagingMapper.power', 'Value', ...
%     state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, state.init.eom.uncagingMapper.pixel, 4));
% state.init.eom.uncagingMapper.power
% state.init.eom.uncagingMapper.autoPower
state.init.eom.uncagingMapper.power = state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, state.init.eom.uncagingMapper.pixel, 4);
if state.init.eom.powerInMw
    conversion = 1 / (getfield(state.init.eom, ['powerConversion' num2str(state.init.eom.uncagingMapper.beam)]) * ...
        state.init.eom.maxPhotodiodeVoltage(state.init.eom.uncagingMapper.beam) * .01);
else
    conversion = 1;
end

set(gh.uncagingMapper.powerText, 'String', num2str(conversion * ...
    state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, state.init.eom.uncagingMapper.pixel, 4)));

return;

%-------------------------------------------------------------------
function enablePixelEditor(yesOrNo)
global gh;

val = 'Off';
if yesOrNo
    val = 'On';
end
    
% set(gh.uncagingMapper.enableButton, 'Enable', val);
% set(gh.uncagingMapper.xText, 'Enable', val);
% set(gh.uncagingMapper.yText, 'Enable', val);
% set(gh.uncagingMapper.durationText, 'Enable', val);
% set(gh.uncagingMapper.powerText, 'Enable', val);
% set(gh.uncagingMapper.pixelSlider, 'Enable', val);
set(gh.uncagingMapper.deletePixel, 'Enable', val);
set(gh.uncagingMapper.deleteAllPixels, 'Enable', val);
set(gh.uncagingMapper.enableButton, 'Enable', val);
set(gh.uncagingMapper.loop, 'Enable', val);

return;


% --- Executes on button press in resetPosition.
function resetPosition_Callback(hObject, eventdata, handles)
% hObject    handle to resetPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state;

state.init.eom.uncagingMapper.position = 1;
updateGuiByGlobal('state.init.eom.uncagingMapper.pixel', 'Value', 1, 'Callback', 1);


% --- Executes on button press in deleteAllPixels.
function deleteAllPixels_Callback(hObject, eventdata, handles)
% hObject    handle to deleteAllPixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state gh;
state.init.eom.uncagingMapper.pixels = [];

updatePixelDisplay;
enablePixelEditor(0);

return;


% --- Executes on button press in plotPixels.
function plotPixels_Callback(hObject, eventdata, handles)
global state;

x = state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, :, 1);
y = -1 * state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, :, 2) + 1;
w = state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, :, 3) / sqrt(length(x));

f = figure('Color', 'White');

for i = 1 : length(x)
    line([x(i) (x(i) + w(i))], [y(i) y(i)], 'Color', 'Black');
    text(x(i), y(i), num2str(i), 'FontWeight', 'Normal');
end

line([0 0], [0 1], 'LineStyle', '--', 'Color', 'Black');
line([1 1], [0 1], 'LineStyle', '--', 'Color', 'Black');
line([0 1], [0 0], 'LineStyle', '--', 'Color', 'Black');
line([0 1], [1 1], 'LineStyle', '--', 'Color', 'Black');

title('Uncaging Map Excitation Points', 'FontWeight', 'Bold', 'FontSize', 12);
xlim([-0.05 1.05]);
ylim([-0.05 1.05]);
xlabel('X Coordinate [normalized]', 'FontSize', 10);
ylabel('Y Coordinate [normalized]', 'FontSize', 10);

% text(1, 1, 'Image Boundary');

return;

% --- Executes on button press in loop.
function loop_Callback(hObject, eventdata, handles)
global state gh;

if strcmpi(get(gh.uncagingMapper.loop, 'String'), 'loop')
    %Force auto-generation.
    autoButton_Callback(gh.uncagingMapper.autoButton);

    updateGuiByGlobal('state.init.eom.uncagingMapper.enabled', 'Value', 0);
    set(gh.uncagingMapper.enableButton, 'Enable', 'Off');
    state.init.eom.uncagingMapper.quitLoop = 0;

    set(gh.uncagingMapper.loop, 'String', 'Abort');
    set(gh.uncagingMapper.loop, 'ForegroundColor', [1 0 0]);

    if state.init.eom.uncagingMapper.position > size(state.init.eom.uncagingMapper.pixels, 2)
        updateGuiByGlobal('state.init.eom.uncagingMapper.position', 'Value', 1);
    end

    state.init.eom.uncagingMapper.tempFrames = state.acq.numberOfFrames;
    set(gh.mainControls.grabOneButton, 'Enable', 'Off');    
    if state.init.eom.uncagingMapper.perGrab
        updateGuiByGlobal('state.acq.numberOfFrames', 'Value', 1);
        state.init.eom.changed(:) = 1;

        i = state.init.eom.uncagingMapper.position;
        while ~state.init.eom.uncagingMapper.quitLoop & ...
           state.init.eom.uncagingMapper.position < size(state.init.eom.uncagingMapper.pixels, 2)
            executeGrabOneCallback(gh.mainControls.grabOneButton);

            state.init.eom.uncagingMapper.position = state.init.eom.uncagingMapper.position + 1;

            %Check before the pause, just in case.
            if state.init.eom.uncagingMapper.quitLoop | ...
               state.init.eom.uncagingMapper.position >= size(state.init.eom.uncagingMapper.pixels, 2)
                break;
            end

            pause(state.standardMode.repeatPeriod);
        end
    else
        updateGuiByGlobal('state.acq.numberOfFrames', 'Value', size(state.init.eom.uncagingMapper.pixels, 2));
        executeGrabOneCallback(gh.mainControls.grabOneButton);
    end

    updateGuiByGlobal('state.acq.numberOfFrames', 'Value', state.init.eom.uncagingMapper.tempFrames);
else
    state.init.eom.uncagingMapper.quitLoop = 1;
    if strcmpi(get(gh.mainControls.grabOneButton, 'String'), 'Abort')
        executeGrabOneCallback(gh.mainControls.grabOneButton);
    end
    updateGuiByGlobal('state.acq.numberOfFrames', 'Value', state.init.eom.uncagingMapper.tempFrames);
end

set(gh.uncagingMapper.enableButton, 'Enable', 'On');
set(gh.mainControls.grabOneButton, 'Enable', 'On');
state.init.eom.changed(:) = 1;

set(gh.uncagingMapper.loop, 'String', 'Loop');
set(gh.uncagingMapper.loop, 'ForegroundColor', [0 0 1]);

return;