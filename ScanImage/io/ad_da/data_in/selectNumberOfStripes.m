function selectNumberOfStripes; % Function that selects the number of stripes appropriate for the given image size.
%% function selectNumberOfStripes; % Function that selects the number of stripes appropriate for the given image size.
% This function sets the state.acq.numberOfStripes parameter to the appropriate value,
% depending on whether the lines per frame is small or large.
%
%% NOTES
%   Current version
%% 
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% April 2, 2003
%% NOTES
%   This is currently done in a very ad hoc way, and should probably be tied to a standard.ini value for each rig specifying the max display update rate
%
%% MODIFICATIONS
%   VI041008A Vijay Iyer - Added additional rule to reduce number of stripes when using fast (small) ms/line values
%   VI042108A Vijay Iyer - Reduce number of stripes whenever merge channel is active
%   VI042808A Vijay Iyer - Reduce number of stripes also whenever saving to disk during acquisition
%   
%% ******************************
global state gh

% Figure out number of channels....
channels=state.acq.numberOfChannelsImage;
if channels<=2 && ~state.acq.channelMerge  && ~state.acq.saveDuringAcquisition %VI042108A VI042808A
    stripes=16;
else 
    stripes=8;
end

% Now base on lpf...
lpf=state.acq.linesPerFrame;
if lpf<=32
    stripes=1;
elseif lpf>32 & lpf <=64
    stripes=2;
elseif lpf > 64 & lpf<=128
    stripes=4;
end

%Now base on msPerLine (VI041008A)
if state.acq.msPerLine < 1.2e-3
    stripes = max(1,stripes/4);
elseif state.acq.msPerLine < 1.8e-3
    stripes = max(1,stripes/2);
end

state.internal.numberOfStripes=stripes;