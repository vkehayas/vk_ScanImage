function parkLaserCloseShutter
global state

% parkLaserCloseShutter.m*******
%
% Function that first closes the shutter and then puts the laser at the designated place that is set
% by the user via state.acq.parkAmplitudeX & state.acq.parkAmplitudeY.
%
% Must run the setupDAQDevices.m function first.
%
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% February 1, 2001

closeShutter;
scim_parkLaser;
