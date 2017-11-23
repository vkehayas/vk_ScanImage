function flushAODataFocus
% Function that removes data from the engine of the AO objects used for focusing.
% The AO objects will then have their SamplesAvailable property set to 0.
% It also removes data from the Focus AI objects.
%
%% CHANGES
%   VI102008A: Clear data for all the beams, and eliminate code repetition -- Vijay Iyer 10/20/08
%
%% CREDITS
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% February 7, 2001
%% ********************************************

global state gh

flushdata(state.init.aiF);

A = rand(2000,2);
if state.init.eom.pockelsOn == 1
    %clearAOData(state.acq.dm, state.init.eom.scanLaserName); %VI102008A
    for i=1:length(state.init.eom.numberOfBeams)
        clearAOData(state.acq.dm, state.init.eom.pockelsCellNames{i});
    end
end 
% 	putdata(state.init.ao1F, A(:,1));
putdata(state.init.ao2F, A);
start(state.init.ao2F);
stopFocus;
A = 0;

%%%VI102008A%%%%%
% else
% 	putdata(state.init.ao2F, A);
% 	start(state.init.ao2F);
% 	stopFocus;
% 	A = 0;	
% end
%%%%%%%%%%%%%%%%%

