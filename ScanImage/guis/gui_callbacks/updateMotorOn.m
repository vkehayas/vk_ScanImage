function updateMotorOn(handle)
%% function updateMotorOn(handle)
% Callback function that handles update to the 'motor on?' checkbox

global state gh

if state.motor.motorOn       
    turnOnMotorButtons;
    MP285Config;
else
    %%%Clear any error condition
    state.motor.errorCond = 0;
    turnOnMotorButtons; 
        
    turnOffMotorButtons;
end

        
        