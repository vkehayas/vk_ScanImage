%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% This function takes a N x 2 array, typically the X and Y mirror data outputs where N depends on the D-to-A rate,
%% and applies row wise rotation functions to it.
%%
%%  Created - Tim O'Connor 5/13/03
%%
%%  Changed:
%%    TPMOD_1: By Thomas Pologruto 1/21/04 - Changed order of operations, so
%%             that now the image swil be shifted before being rotated.  This enables
%%             the rotation to be centered better.  Also reduced number of lines of
%%             code substantially.
%%    TO12104a: Tim O'Connor 1/21/04 - Take into account the fact that the center of the image
%%              is not always the same as the center of the scan. There is a "normally small" offset, 
%%              which may be the cause of errors in zooming and single pixel identification.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [output] = rotateMirrorData(input)
global state

%start TPMOD_1 1/21/04
inputSize=size(input);
output=zeros(inputSize);

c = cos(state.acq.scanRotation * pi / 180);
s = sin(state.acq.scanRotation * pi / 180);

%TO12104a Tim O'Connor 1/21/04
% The center of the scan is 1/2 (defined in units of lambda).
% The center of the image is defined as the midpoint in between (lineDelay + cuspDelay) and
% (lineDelay + cuspDelay + fillFraction), which are the beginning of acqusition and the end 
% of acqusition, respectively.
% This must be normalized into units of wavelength and considered as a perturbation to the scan
% center, thus the subtraction of 1/2.
%
% Call X the center of the scan, in the 'X' dimension. This is defined as 1/2.
% Call X' the center of the image, in the 'X' dimension. 
% Call dx the difference between X' and X.
% This is calculated as follows -
%  Definitions:
%   L := lineDelay
%   C := cuspDelay
%   F := fillFraction
%   leftEdgeOfImage := L + C
%   rightEdgeOfImage := L + C + F
%
%   X' = (leftEdgeOfImage + rightEdgeOfImage) / 2
%   = [ (L + C) + (L + C + F) ] / 2 = L + C + (F / 2)
%
%   dx = X' - X = L + C + (F / 2) - (1 / 2) = L + C + (1/2) * (F - 1)
realmsperline = state.acq.msPerLine * 1000;
dt_x = (state.acq.lineDelay + state.acq.cuspDelay + (.5 * (state.acq.fillFraction - 1)));

% Convert the timings into voltages for this scan...
totalXAmplitude = 2. * state.internal.scanAmplitudeX;
totalRiseTime = state.acq.lineDelay + state.acq.cuspDelay + state.acq.fillFraction;

if dt_x < (state.acq.fillFraction + state.acq.lineDelay)
    dx = (totalXAmplitude .* dt_x) ./ totalRiseTime - totalXAmplitude ./ 2;
else
    dx = (-totalXAmplitude .* dt_x) ./ (1 - totalRiseTime) + totalXAmplitude ./ 2;
end

% The same offset propogates into Y, diluted by the number of lines.
% Proof of this is left as an exercise for the reader...
dy = dx ./ state.acq.linesPerFrame;

%TO12104a Tim O'Connor 1/21/04 - Apply dx and dy perturbations.
output(:, :) = [(input(:, 1) + state.acq.scaleXShift + dx) (input(:, 2) + state.acq.scaleYShift + dy)];
output(:, :) = [(c * output(:, 1) + s * output(:, 2)) (c * output(:, 2) - s * output(:, 1))];
%end TPMOD_1 1/21/04

return;