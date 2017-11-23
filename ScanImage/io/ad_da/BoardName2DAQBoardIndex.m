function Out = BoardName2DAQBoardIndex(name)
global state

% This function will take the name paraemeter as a string and return the number index for 
% the Board Name from the DAQ toolbox for the nidaq boards.
%
% Written by:  Thomas Pologruto 
% Cold Spring Harbor Labs
% February 7, 2001

a = daqhwinfo('nidaq');
totalNumberOfBoards = size(a.BoardNames,2);

for boardCounter = 1:totalNumberOfBoards
	if strcmp(name, a.BoardNames{boardCounter});
		Out = str2num(a.InstalledBoardIds{boardCounter});
		return;
	end
end

disp('Name Corresponding to Index Not Found.');
out=[];
