function [x1,x2] = makeSawtoothExpX(t, scanOffsetX, scanAmplitudeX);
global state

% makeSawtoothX.m*******
% Function that defines the line scanning mirror output.
%
% Written by: Thomas Pologruto
% Cold Spring Harbor Labs
% February 9, 2001

	state.internal.lineDelay = .001*state.acq.lineDelay/state.acq.msPerLine;

	% Parameter that define the scan and flyback functions for the x channel(line scanning mirror).
	state.internal.scanAmplitudeX = scanAmplitudeX/state.acq.zoomFactor;

	flybackDecimal = (1-state.acq.fillFraction-state.internal.lineDelay);
	slopex1 = ((2*state.internal.scanAmplitudeX)/(state.acq.msPerLine*(1-flybackDecimal)));
	interceptx1 = (scanOffsetX - state.internal.scanAmplitudeX);

	slopex2 = (-(2*state.internal.scanAmplitudeX)/(state.acq.msPerLine*flybackDecimal));
	interceptx2 = ((1-flybackDecimal)/(flybackDecimal))*(2*state.internal.scanAmplitudeX) + (scanOffsetX + state.internal.scanAmplitudeX);


	x1 = slopex1*t + interceptx1;
	tau=state.acq.msPerLine*flybackDecimal/5;		
	x2 = 2*state.internal.scanAmplitudeX*exp(-(t-(state.acq.msPerLine*(1-flybackDecimal)))/tau) - ...
		state.internal.scanAmplitudeX + scanOffsetX;
	
%	slopex2*t + interceptx2;
