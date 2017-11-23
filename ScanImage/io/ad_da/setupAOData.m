function setupAOData
global state

% setupAOData.m******
% Function that create and store the output data for the scanning mirrors and the
% pockel's cell.
%
% Written by Thomas Pologruto  
% Cold Spring Harbor Labs
% February 7, 2000

%******************************************************************************
% Mirror Data Output
% Uses the PCI 6110E Board
% Setting up analog output for the NI Board and adding 2 channels to it.  
% Setting up Mirror controls.
% Constructing appropriate output data.
%*******************************************************************************

% Data Queing and AO execution

state.acq.mirrorDataOutput = makeMirrorDataOutput; 			% Defines the data matrix sent to the mirrors
%TPMODPockels
if state.init.eom.pockelsOn == 1
	state.init.eom.changed(:) = 1;
end

