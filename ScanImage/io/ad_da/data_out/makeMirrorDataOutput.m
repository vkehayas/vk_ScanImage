% makeMirrorDataOutput.m*****
%% NOTES
% Function that assembles the data matrix sent to the DAQ Analog output Engine for controlling the laser scanning mirrors
% details of the subfunctions included here are available from the individual help menus.
%
% This function will also rotate the mirror scanning functions if necessary.
%% CHANGES
%   VI091208A: Don't pass offset to makeSawtoothX/Y functions, and use (renamed) rotateAndShiftMirrorData() function
%   
%% CREDITS
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% February 9, 2001
%% ***********************************

function finalMirrorDataOutput = makeMirrorDataOutput
global state 

ActualRateOutput2 = get(state.init.ao2, 'SampleRate');
timeincrement = (ActualRateOutput2*state.acq.msPerLine);  % Defining time incrememnt in linear stepping for function output;
rotate=state.acq.scanRotation;
zoom=state.acq.zoomFactor;

state.acq.scanRotation=0;
state.acq.zoomFactor=1;
updateGUIByGlobal('state.acq.scanRotation');
updateGUIByGlobal('state.acq.zoomFactor');

if state.acq.fastScanningX == 1 % state.acq.fastScanningY == 0; X is the high frequency mirror (Normal operation)
	
	[x1, x2] = makeSawtoothX(linspace(0,state.acq.msPerLine,timeincrement), 0, state.acq.scanAmplitudeX); %VI091208A
	x = makeMirrorDataX(x1,x2);

	[y1, y2] = makeSawtoothY(linspace(0,(state.acq.linesPerFrame*state.acq.msPerLine), ...
		(state.internal.lengthOfXData *state.acq.linesPerFrame)), 0, state.acq.scanAmplitudeY); %VI091208A
	y = makeMirrorDataY(y1,y2);
	
	finalMirrorDataOutput = [x y]; 										% Defines the data matrix sent to the mirrors

elseif state.acq.fastScanningY == 1 % % state.acq.fastScanningX == 0; Y is the high frequency mirror (Normal operation)
	
	[y1, y2] = makeSawtoothX(linspace(0,state.acq.msPerLine,timeincrement), 0, state.acq.scanAmplitudeY); %VI091208A
	y = makeMirrorDataX(y1,y2);
	
	[x1, x2] = makeSawtoothY(linspace(0,(state.acq.linesPerFrame*state.acq.msPerLine), ...
		(state.internal.lengthOfXData *state.acq.linesPerFrame)), 0, state.acq.scanAmplitudeX); %VI091208A
	x = makeMirrorDataY(x1,x2);
	
	finalMirrorDataOutput = [x y]; 										% Defines the data matrix sent to the mirrors
end

state.acq.mirrorDataOutputOrg = finalMirrorDataOutput; % original data for zooming purposes...

state.acq.scanRotation=rotate;
state.acq.zoomFactor=zoom;
updateGUIByGlobal('state.acq.scanRotation');
updateGUIByGlobal('state.acq.zoomFactor');

state.acq.mirrorDataOutput = rotateAndShiftMirrorData(1/state.acq.zoomFactor*state.acq.mirrorDataOutputOrg); %VI091208A
finalMirrorDataOutput=state.acq.mirrorDataOutput;