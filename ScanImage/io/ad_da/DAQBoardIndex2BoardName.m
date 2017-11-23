function Out = DAQBoardIndex2BoardName(index)
global state

% This function will take the index paraemter as a string and return the string for 
% the Board Name from the DAQ toolbox for the nidaq boards.
%
% Written by:  Thomas Pologruto 
% Cold Spring Harbor Labs
% February 7, 2001

a = daqhwinfo('nidaq');
totalNumberOfBoards = size(a.BoardNames,2);

if str2num(index) <= totalNumberOfBoards
	
	for boardCounter = 1:totalNumberOfBoards
		if strcmp(index, a.InstalledBoardIds{boardCounter});
			Out = a.BoardNames{boardCounter};
		end
	end

else
	disp('Board Corresponding to index not Found: Index exceeds Board IDs');
end