function setAcquisitionParameters
%% function setAcquisitionParameters
%   Parses/adjusts the acquisition parameters set in the Configuration gui(s)
%
%%   NOTES
%       This function, as of ScanImage 3.0, hard-coded the input and output rates and hard-coded the fillFraction and msPerLine true values
%           for each nominal msPerLine setting
%
%       The logic of the original version seems to be the following (as seen by Vijay Iyer):
%           1. Establish hard-coded AO and AI rates of 40kHz and 1.25MHz, respectively
%           2. Establish that there are 1K/2K/4K/8K samples/line for the 1,2,4,8ms/line cases -- this allows clean divisibility for the 2^x pixels/line (e.g. 128,256,512)
%           3. Compute the fixed "active" line period (# of samples*80ns AI period) to use for each scan speed: .8192/1.6384/3.2768/6.5536 ms/line, respectively
%           4. Observe that periods that are multiples of 100us allow both clock periods (80ns and 25us) to be integer submultiples
%           5. For the 2ms/line case, increment/decrement the "full" line period by increments of 100us (e.g. to 1.9,2.1ms). With fixed "useful" line period, the fill fraction is recomputed.
%           6. For the 1/4/8 ms/line cases, do the same, but increment/decrement the line period by incremetns of 50/200/400us, so that the same fill fraction options are presented to user.
%           7. Disallow any high fill fractions that cause the "true" line period to be longer than the "useful" period by < 100us, which is the default line delay parameter
%           
%           One problem with original version--the 50us increments in line period for the 1ms/line case do not allow for synced AI/AO with the existing clock rate.
%
%
%% MODIFICATIONS
%   VI022508A Vijay Iyer 2/25/08 -- Complete rewrite which encodes the logic of the original function (with some correction), rather than hard-coding each of the cases
%   VI031208A Vijay Iyer 3/12/08 -- Add in case of 0.5ms/line and exclude fast scans when not bidirectional scanning
%   VI031308A Vijay Iyer 3/13/08 -- Handle fill fraction checking differently between bidirectional and unidirectional scanning cases
%   VI031308B Vijay Iyer 3/14/08 -- Switch to 50kHz output rate, and adjust/add fill frac values
%   VI031708A Vijay Iyer 3/17/08 -- Adjust linePeriod increment in a scan-speed-dependent fashion, so actual fillFrac values are near to those indicated by GUI values
%   VI102909A Vijay Iyer 10/29/09 -- Don't display fill fraction as a status string
%
%% 
global state gh

%Hard-code the AI/AO rates
state.acq.inputRate = 1250000;
updateGUIByGlobal('state.acq.inputRate');

state.acq.outputRate = 50000;
updateGUIByGlobal('state.acq.outputRate')

minLinePeriodIncrement = 1/gcd(state.acq.inputRate,state.acq.outputRate); %Can increment/decrement line period by 100us and still have integer # of AI/AO samples

%Exclude fast scans if not bidirectional scanning (VI031208A)
if ~state.acq.bidirectionalScan && state.acq.msPerLineGUI < state.init.minUnidirectionalLinePeriodGUI
    state.acq.msPerLineGUI = state.init.minUnidirectionalLinePeriodGUI;
    updateGUIByGlobal('state.acq.msPerLineGUI');
end
    
%Determine samplesAcquiredPerLine
switch state.acq.msPerLineGUI % 1 = 1 ms, 2 = 2ms, 3 = 4 ms, 4 = 8 ms
    case 1
        state.acq.samplesAcquiredPerLine = 512;
        nominalLinePeriod = .5e-3;
        linePeriodIncrement = 2*minLinePeriodIncrement; %Don't use linePeriodIncrement/2 as in the original version!
    case 2
        state.acq.samplesAcquiredPerLine = 1024;
        nominalLinePeriod = 1e-3;
        linePeriodIncrement = 2 * minLinePeriodIncrement; %VI031708A
    case 3
        state.acq.samplesAcquiredPerLine = 2048;
        nominalLinePeriod = 2e-3;
        linePeriodIncrement = 5 * minLinePeriodIncrement; %VI031708A
    case 4
        state.acq.samplesAcquiredPerLine = 4096;
        nominalLinePeriod = 4e-3;
        linePeriodIncrement = 10 * minLinePeriodIncrement; %VI031708A
    case 5
        state.acq.samplesAcquiredPerLine = 8192;
        nominalLinePeriod = 8e-3;
        linePeriodIncrement = 20 * minLinePeriodIncrement; %VI031708A
end
updateGUIByGlobal('state.acq.samplesAcquiredPerLine');

activeLinePeriod = state.acq.samplesAcquiredPerLine/state.acq.inputRate;
defaultFillFraction = activeLinePeriod / nominalLinePeriod;

%Determine number of increments to adjust line period by, away from nominalMSPerLine, based on Fill Fraction parameter 
switch state.acq.fillFractionGUI
	case 1 % fillFraction = 0.71234782608696        
        incrementMultiplier = 3;
	case 2 % fillFraction =  0.74472727272727
        incrementMultiplier = 2;
	case 3 % fillFraction = 0.78019047619048
        incrementMultiplier = 1;
	case 4 % fillFraction = 0.81920000000000
        incrementMultiplier = 0;
	case 5 % fillFraction = 0.86231578947368
        incrementMultiplier = -1;
	case 6 % fillFraction = 0.91022222222222
        incrementMultiplier = -2;
	case 7 % fillFraction = 0.96376470588235
        incrementMultiplier = -3;
end

%Compute actual line period value implied by selected fill fraction, after validating that choice is valid (and adjusting if not)
totalIncrement = incrementMultiplier*linePeriodIncrement;
%Ensure total increment is an integer number of the minimum increment (practically--this fixes the 1ms/line problem with original logic)
while abs(round(totalIncrement/minLinePeriodIncrement) - (totalIncrement/minLinePeriodIncrement)) > 1e-10 %Don't know any other way to test for clean divisibility
    totalIncrement = totalIncrement-sign(totalIncrement)*linePeriodIncrement;
    done = adjustFillFracGUI(5); %adjust towards the "default" fill fraction (.8192)
    if done
        break;
    end
end

computeFillFrac = @(activeLinePeriod,nominalLinePeriod,totalIncrement) activeLinePeriod/(nominalLinePeriod+totalIncrement);
fillFraction = computeFillFrac(activeLinePeriod,nominalLinePeriod,totalIncrement);

%Ensure that fractional line delay is smaller than (1-fillFraction)
while ~isValidFillFrac(fillFraction) %VI031308A
    totalIncrement = totalIncrement + linePeriodIncrement; 
    fillFraction = computeFillFrac(activeLinePeriod,nominalLinePeriod,totalIncrement);
    done = adjustFillFracGUI(1); %adjust towards the smallest fill fraction
    if done
        break;
    end
end

%Update GUI/state parameters
updateGUIByGlobal('state.acq.fillFractionGUI');

state.acq.fillFraction = fillFraction;
updateGUIByGlobal('state.acq.fillFraction');
state.acq.msPerLine = nominalLinePeriod+totalIncrement;
updateGUIByGlobal('state.acq.msPerLine');
%setStatusString(['Fill frac = ' num2str(fillFraction,'%0.4f')]); %VI102909A
state.internal.lineDelay = state.acq.lineDelay; %VI031708B

%Function adjusts state.acq.fillFractionGUI value towards a specified "target" value , incrementing or decrementing by one
function done = adjustFillFracGUI(target)

global state

if state.acq.fillFractionGUI > target
    state.acq.fillFractionGUI = state.acq.fillFractionGUI - 1;
    done = false;
elseif state.acq.fillFractionGUI < target
    state.acq.fillFractionGUI = state.acq.fillFractionGUI + 1;
    done = false;
else
    fprintf(2,'None of the available fill fraction values can be reconciled with the current line/cusp delay values. Adjust those values.\n');
    done = true;
end

%Function checks whether fill fraction is consistent with other parameters
function logval = isValidFillFrac(fillFraction)
global state

if (1-fillFraction) < state.acq.lineDelay && ~state.acq.bidirectionalScan
    logval=false;
else
    logval=true;
end
    
% function minIncrement = getMinLinePeriodIncrement()
% global state
% 
% commonRate = gcd(state.acq.inputRate,state.acq.outputRate);
% 
% if commonRate > 1
%     minIncrement = 1/commonRate;
% else %could either be a perfect match...or hopeless
%     minIncrement = 0
% end
%     
    
   




%% ORIGINAL VERSION
% global state gh
% 
% % setAcquisitionParameter.m****
% % Function that sets the samplesAcquiredPerLine and inputRate when the user sets the 
% % Fillfractiona dn the msPerLine.
% 
% state.acq.inputRate = 1250000;
% updateGUIByGlobal('state.acq.inputRate');
% 		
% switch state.acq.msPerLineGUI % 1 = 1 ms, 2 = 2ms, 3 = 4 ms, 4 = 8 ms
% case 1
% 	state.acq.samplesAcquiredPerLine = 1024;
% 	updateGUIByGlobal('state.acq.samplesAcquiredPerLine');
% 	state.acq.outputRate = 40000;
% 	updateGUIByGlobal('state.acq.outputRate');
% 		
% 	switch state.acq.fillFractionGUI
% 	case 1 % fillFraction = 0.71234782608696
% 		state.acq.fillFraction =0.71234782608696;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .0011500;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		setStatusString('');
% 	case 2 % fillFraction =  0.74472727272727
% 		state.acq.fillFraction = 0.7447272727272720000;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00110;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		setStatusString('');
% 	case 3 % fillFraction = 0.78019047619048
% 		state.acq.fillFraction = 0.7801904761904800000;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .0010500;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		setStatusString('');
% 	case 4 % fillFraction = 0.81920000000000
% 		state.acq.fillFraction = 0.8192000000000000000;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .0010;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		setStatusString('');
% 	case 5 % fillFraction = 0.81920000000000
% 		state.acq.fillFraction = 0.8192000000000000000;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.fillFractionGUI = 4;
% 		updateGUIByGlobal('state.acq.fillFractionGUI');
% 		state.acq.msPerLine = .0010;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		setStatusString('Fill Fraction = .8192');
% 	case 6 % fillFraction = 0.81920000000000
% 		state.acq.fillFraction = 0.8192000000000000000;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.fillFractionGUI = 4;
% 		updateGUIByGlobal('state.acq.fillFractionGUI');
% 		state.acq.msPerLine = .0010;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		setStatusString('Fill Fraction = .8192');
% 	case 7 % fillFraction = 0.81920000000000
% 		state.acq.fillFraction = 0.8192000000000000000;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.fillFractionGUI = 4;
% 		updateGUIByGlobal('state.acq.fillFractionGUI');
% 		state.acq.msPerLine = .0010;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		setStatusString('Fill Fraction = .8192');
% 		
% 	otherwise 
% 	end
% 	
% case 2
% 	state.acq.samplesAcquiredPerLine = 2048;
% 	updateGUIByGlobal('state.acq.samplesAcquiredPerLine');
% 	state.acq.outputRate = 40000;
% 	updateGUIByGlobal('state.acq.outputRate');
% 	
% 	switch state.acq.fillFractionGUI
% 	case 1 % fillFraction = 0.71234782608696
% 		state.acq.fillFraction = 0.71234782608696;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00230;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		setStatusString('');
% 	case 2 % fillFraction =  0.74472727272727
% 		state.acq.fillFraction = 0.74472727272727;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00220;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		setStatusString('');
% 	case 3 % fillFraction = 0.78019047619048
% 		state.acq.fillFraction = 0.78019047619048;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00210;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		setStatusString('');
% 	case 4 % fillFraction = 0.81920000000000
% 		state.acq.fillFraction = 0.81920000000000;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .0020;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		setStatusString('');
% 	case 5 % fillFraction = 0.86231578947368
% 		state.acq.fillFraction = 0.86231578947368;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00190;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		setStatusString('');
% 	case 6 % fillFraction = 0.91022222222222
% 		state.acq.fillFraction = 0.91022222222222;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00180;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		setStatusString('');
% 	case 7  % fillFraction = 0.91022222222222
% 		state.acq.fillFraction = 0.91022222222222;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.fillFractionGUI = 6;
% 		updateGUIByGlobal('state.acq.fillFractionGUI');
% 		state.acq.msPerLine = .00180;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		setStatusString('Fill Fraction = .9102');
% 		
% 	otherwise 
% 	end
% 	
% case 3
% 	
% 	setStatusString('');
% 	state.acq.samplesAcquiredPerLine = 4096;
% 	updateGUIByGlobal('state.acq.samplesAcquiredPerLine');
% 	state.acq.outputRate = 40000;
% 	updateGUIByGlobal('state.acq.outputRate');
% 		
% 	switch state.acq.fillFractionGUI
% 	case 1 % fillFraction = 0.71234782608696
% 		state.acq.fillFraction = 0.71234782608696;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00460;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 	case 2 % fillFraction =  0.74472727272727
% 		state.acq.fillFraction = 0.74472727272727;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00440;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 	case 3 % fillFraction = 0.78019047619048
% 		state.acq.fillFraction = 0.78019047619048;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00420;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 	case 4 % fillFraction = 0.81920000000000
% 		state.acq.fillFraction = 0.81920000000000;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00400;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 	case 5 % fillFraction = 0.86231578947368
% 		state.acq.fillFraction = 0.86231578947368;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00380;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 	case 6 % fillFraction = 0.91022222222222
% 		state.acq.fillFraction = 0.91022222222222;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00360;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 	case 7  % fillFraction = 0.96376470588235
% 		state.acq.fillFraction = 0.96376470588235;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .003400;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 		
% 	otherwise 
% 	end
% 	
% case 4
% 	setStatusString('');
% 	state.acq.samplesAcquiredPerLine = 8192;
% 	updateGUIByGlobal('state.acq.samplesAcquiredPerLine');
% 	state.acq.outputRate = 40000;
% 	updateGUIByGlobal('state.acq.outputRate');
% 	
% 	switch state.acq.fillFractionGUI
% 	case 1 % fillFraction = 0.71234782608696
% 		state.acq.fillFraction = 0.71234782608696;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00920;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 	case 2 % fillFraction =  0.74472727272727
% 		state.acq.fillFraction = 0.74472727272727;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00880;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 	case 3 % fillFraction = 0.78019047619048
% 		state.acq.fillFraction = 0.78019047619048;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00840;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 	case 4 % fillFraction = 0.81920000000000
% 		state.acq.fillFraction = 0.81920000000000;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .0080;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 	case 5 % fillFraction = 0.86231578947368
% 		state.acq.fillFraction = 0.86231578947368;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00760;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 	case 6 % fillFraction = 0.91022222222222
% 		state.acq.fillFraction = 0.91022222222222;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .00720;
% 		updateGUIByGlobal('state.acq.msPerLine');
% 	case 7  % fillFraction = 0.96376470588235
% 		state.acq.fillFraction = 0.96376470588235;
% 		updateGUIByGlobal('state.acq.fillFraction');
% 		state.acq.msPerLine = .006800;
% 		updateGUIByGlobal('state.acq.msPerLine');
%     end
% end

    

