function Aout = add2d(A, Bx)
%% function Aout = add2d(A, Bx)
% Function that adds over Bx columns in an image array. 
%
% Function that bins by averaging over Bx (columns) elements along the x-axis.  A is a 2D intensity matrix.
% Bx must be divisible into the array dimensions.
% 
% By is the Binning factor for rows (lines)
% Function Form: Aout = add2d(A,Bx)
%
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% January 26, 2001.
%
% Edited By: Bernardo Sabatini
% January 26, 2001
% Cold Spring Harbor Labs
%% NOTES
%   This function (via call to sum()) returns matrix Aout as a double, regardless of the format of the input A
% 

%% *************************************************


sizeA = size(A);			% Tells function which type of image is input
Ny = sizeA(1,1);
Nx = sizeA(1,2);			% Tells function the number of columns of A
dimA = ndims(A);			% Tells function the dimensions of A as a scalar

	
if Bx == 1
	Aout = A;
else
    Aout = sum(reshape(A', Bx, Ny*(Nx/Bx)));
	Aout = reshape(Aout, (Nx/Bx), Ny)';
end
	
	
	
	

	