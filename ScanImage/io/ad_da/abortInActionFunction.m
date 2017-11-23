function abortInActionFunction
% abort GRAB or LOOP from within an action function
	stopGrab;
	scim_parkLaser;
	closeShutter;	% BSMOD 
	putDataGrab;
	pause(.01);

	
