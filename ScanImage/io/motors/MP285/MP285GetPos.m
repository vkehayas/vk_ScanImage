
function xyz=MP285GetPos
% MP285GetPos retrieves the position information from the MP285 controller
% 
% MP285GetPos 
% 
% Class Support
%   -------------
%   
%	the output [x y z] is the position of the MP285 in microns
%% CHANGES
% 	Modified 2/5/1 by Bernardo Sabatini to support global state and preset serialPortHandle
%   VI092908A: Use resolutionX/Y/Z instead of calibrationFactorX/Y/Z -- Vijay Iyer 9/29/08
%   VI100608A: Use new MP285Error() function in case of an error -- Vijay Iyer 10/06/08
%   VI101008A: Short-circuit action if an error condition is present -- Vijay Iyer 10/10/08
%
%% CREDITS
%   Karel Svoboda 8/28/00 Matlab 6.0R
%	 svoboda@cshl.org
%% ************************

xyz=[];

global state
if state.motor.motorOn==0
	return
end

if state.motor.errorCond %VI101008A
    return;
end

if length(state.motor.serialPortHandle) == 0
	disp(['MP285GetPos: MP285 not configured.']);
	xyz=[];
	state.motor.lastPositionRead=[];
	return
end

%whos state.motor.serialPortHandle;
% get all the junk out
MP285Flush;
mp285Error=0;

% send command to read position
try
	fwrite(state.motor.serialPortHandle, [99 13]); 		%'c'CR
catch
    errStruct = lasterror;
    MP285Error(['Error sending request for MP-285 position: ' errStruct.message]);
    return;
end

%read the reply
%array = fread(state.motor.serialPortHandle, 3, 'long')% read position information (12bytes) including CR (1 byte)
temp = MP285ReadAnswer; %1
if isempty(temp)
    MP285Error('Sent request for MP-285 position, but did not receive reply.');
    return;
else
    replyErrorMsg = 'Received position info from MP-285, but failed to understand it.';
    try
        array = [readInteger(temp(1:4)); readInteger(temp(5:8)); readInteger(temp(9:12))];
        
        if length(array)<3 % | length(dummy)<1
            MP285Error(replyErrorMsg);
            return;
        end        
    catch 
        MP285Error(replyErrorMsg);
        return;
    end
end

% if ~mp285Error
% 	try
% 		%dummy = fread(state.motor.serialPortHandle, 1);		% read position information (12bytes) including CR (1 byte)
%         dummy = MP285ReadAnswer;
%         %dummy = hex2dec(temp(1:12));
% 	catch
% 		mp285Error=1;
% 	end
% end

% if mp285Error
%     %%%VI100608A: Removed this section
%     % 	disp('mp285GetPos: Error in MP285 Communication');
%     % 	disp(lasterr)
%     % 	setStatusString('MP285 Error. Reset?');
%     % 	state.motor.lastPositionRead=[];
%     %%%%%%%%%
%     MP285Error('Unable to read MP-285 position'); %VI100608A    
% 	return
% end


%xyz=reshape(array,1,3)./[state.motor.calibrationFactorX state.motor.calibrationFactorY state.motor.calibrationFactorZ]/10;
xyz=reshape(array,1,3).*[state.motor.resolutionX state.motor.resolutionY state.motor.resolutionZ];

state.motor.lastPositionRead=xyz;

%Functionn to convert MP285 returned chars into a signed integer value
function x = readInteger(readChars)

x = [dec2bin(readChars(4),8) dec2bin(readChars(3),8) dec2bin(readChars(2),8) dec2bin(readChars(1),8)];
x = bin2dec(x);
if x >= 2^31

    x=x-2^32;
end

return;


