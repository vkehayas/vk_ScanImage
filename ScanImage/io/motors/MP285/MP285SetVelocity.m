%% function out=MP285SetVelocity(vel, res)
%   Sets velocity and, optionally, resolution of MP-285 for serial-port move commands
%% SYNTAX
%   out = MP285SetVelocity(vel)
%   out = MP285SetVelocity(vel,res)
%       out: 0 if successful, 1 if not
%       vel: velocity value, which is roughly in um/sec, when in LO resolution. See NOTES.
%       res: 'resolution' of velocity. 0 = LO, 1 = HI. If omitted, default=LO. See NOTES.
%% NOTES
%   Following experimentation and discussion with Yungui at Sutter: (Vijay Iyer 10/10/08)
%       Velocity values can be from 0-1310 for HI resolution, and from 0-6550 for LO resolution.
%       Velocity values in LO resolution roughly correspond to um/sec (at least with default firmware, w/ .04um resoluion), but appears to grow somewhat sublinearly. 
%       Identical velocity values in HI resolution appear to be roughly 2x slower than when in LO resolution, in  early testing 
%       
%% CHANGES
%   VI101008A: Short-circuit action if an error condition is present -- Vijay Iyer 10/10/08
%   VI101208A: Switch to convention where 1=error, 0= success; this matches other MP285 functions -- Vijay Iyer 10/12/08
%
%% ********************************************************
function out=MP285SetVelocity(vel, res)
	out=1;
	if nargin==0
		vel=80;
		res=0;
	elseif nargin==1
		res=0;
	elseif nargin>2
		disp('MP285SetVelocity: Expect only upto 2 arguments.');
		return
	end
	global state
	if state.motor.motorOn==0
		return
    end
    
    if state.motor.errorCond %VI101008A
        return;
    end

	if length(state.motor.serialPortHandle) == 0
		disp(['MP285SetVelocity: MP285 not configured']);
		state.motor.lastPositionRead=[];
		return;
	end

	state.motor.velocity=vel;
	if res==1
		vel=bitor(2^15,vel);
	end
	
	% flush all the junk out
    try 
        MP285Flush;
        fwrite(state.motor.serialPortHandle, 'V');
        fwrite(state.motor.serialPortHandle, vel, 'uint16');
        fwrite(state.motor.serialPortHandle, 13);
        if isempty(MP285ReadAnswer)
            error('dummy'); 
        end
        out = 0; %VI101208A
    catch
        MP285Error('Unable to set MP-285 motor velocity');
        %out = 0; %VI101208A
    end
% 	out=MP285ReadAnswer;
% 	if isempty(out)		% check if CR was returned
% 		disp(['MP285SetVelocity: Timeout in serial communication']); 
% 		out=1;
% 		return;
% 	elseif length(out)>1 | out(1)~=13
% 		disp(['MP285SetVelocity: MP285 returned an error:' num2str(out)]);
% 		out=1;
% 		return
% 	end
		
%	out=0;
	