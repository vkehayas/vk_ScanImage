%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  This function takes the data output to the pockels cell
%%  and corrects it for imaging shutter blanks and
%%  varying power levels.
%%  also applies any masks that are necessary for box selection.
%%
%% CHANGES
%    Handle unlimited power changes, and some changes to the GUIs and datastructures. -- Tim O'Connor 8/4/03
%    Behave differently during linescans, for use in uncaging experiments. -- Tim O'Connor 12/16/03
%    Import line pulse selection from physiology train profiles. -- Tim O'Connor 12/18/03
%    Ignore the custom timings, if the power array's first dimension is less than beam. -- Tim O'Connor 1/7/03 (TO1704a)
%    Do not implement powerboxes during focusing. -- Tim O'Connor 2/17/04 (TO21704a)
%    Make sure the powerbox coordinates exist. -- Timothy O'Connor 2/26/04 (TO22604b)
%    Add uncagingMapper. -- Tim O'Connor 2/27/04 (TO22704a)
%    Wrap around, so that each frame has a pixel, as per Alex's request. -- Tim O'Connor 5/19/04 (TO051904a)
%    Hardcoded a check against the 'Constrain To Line' checkbox. -- Tim O'Connor 6/2/04 (TO060204a)
%    Indexing problem with custom timings implementation. -- Tim O'Connor 6/22/04 (TO062204a)
%    Consider span of pulses, to include multiple lines. -- Tim O'Connor 7/20/04 (TO072004c)
%    VI082608A: Handle bidirectional scan case -- Vijay Iyer 8/26/08 
%% CREDITS
%  Copyright - Howard Hughes Medical Institute/Cold Spring Harbor Laboratories 2003
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = implementPockelsCellTiming(beam, data)
global state gh;

out = [];

%Are we using this feature?
if ~(state.init.eom.usePowerArray | state.init.eom.showBox | state.init.eom.uncagingPulseImporter.enabled | ...
        any(state.init.eom.uncagingMapper.enabled))
    out = data;
    return;
end

%See if multiple 'protocols' are in use, and load the appropriate one.
if state.init.syncToPhysiology & state.init.eom.powerTransitions.syncToPhysiology
    state.init.eom.powerTransitions.currentProtocol = state.physiology.mainPhysControls.patternNum1;
    updateGUIByGlobal('state.init.eom.powerTransitions.currentProtocol');
    powerTransitions('protocol_Callback', gh.powerTransitions.protocol, [], gh);%Execute callback.
end

%Pick out the fast scanning indices so we dont mess with these.....
%Same as in makePockelsDataOutput....
if state.acq.bidirectionalScan %VI082608A
    phaseShift=round(state.acq.cuspDelay*state.internal.samplesPerLine); 
    
    startGoodPockelsData = floor(state.internal.lengthOfXData * state.acq.cuspDelay)+ floor(state.internal.lengthOfXData*(1-state.acq.pockelsCellFillFraction)/2)+1;
    endGoodPockelsData = startGoodPockelsData + ceil(state.internal.lengthOfXData*state.acq.pockelsCellFillFraction);
    if state.acq.pockelsCellFillFraction == 1 %Handle case of fill frac=1 specially
        startGoodPockelsData = 1;
        endGoodPockelsData = state.internal.lengthOfXData;
    elseif state.acq.pockelsCellFillFraction >= (1-state.acq.cuspDelay) %Handle case of very high fill fraction (not including 1)
        overage = ceil((state.acq.pockelsCellFillFraction+state.acq.cuspDelay-1)*state.internal.lengthOfXData);
        startGoodPockelsData = max(startGoodPockelsData-ceil(overage/2),1);
        endGoodPockelsData = min(endGoodPockelsData+ceil(overage/2),state.internal.lengthOfXData);
    end               
else
    startGoodPockelsData = ceil(state.internal.lengthOfXData * .001 * state.acq.pockelsCellLineDelay / state.acq.msPerLine) + 1;
    endGoodPockelsData = startGoodPockelsData + floor(state.internal.lengthOfXData * state.acq.pockelsCellFillFraction);
    if endGoodPockelsData > state.internal.lengthOfXData
        endGoodPockelsData = state.internal.lengthOfXData;
    end
end

if size(data, 1) < state.internal.lengthOfXData * state.acq.linesPerFrame * state.acq.numberOfFrames
    warning('Failed to create enough Pockels cell data for the entire scan...');
end

%reshape data so that each line is a different column...
data = reshape(data, state.internal.lengthOfXData, state.acq.linesPerFrame * state.acq.numberOfFrames);

%I don't know why this is off by two, but it is, just uncomment the stuff
%below and feed the Pockels cell control signal into the image input to
%see. -- Tim O'Connor 5/14/04
startGoodPockelsData = startGoodPockelsData + 2;
% endGoodPockelsData = endGoodPockelsData - 2;
% data(startGoodPockelsData, :) = 10;
% startGoodPockelsData
% data(endGoodPockelsData, :) = 0;
% endGoodPockelsData

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Apply Power Array settings...
if state.init.eom.usePowerArray & ~isempty(state.init.eom.powerTransitions.power) & ...
        ~isempty(state.init.eom.powerTransitions.time) & ...
        size(state.init.eom.powerTransitions.power, 1) >= beam %TO1704a

    [events, indices] = sort(state.init.eom.powerTransitions.time(beam, :) ./ (1000 * state.acq.msPerLine)); %Sort the power transition events into ascending order.
    events(events < 0) = -1;
    events = ceil(events); %Convert milliseconds into lines of data.
    
    %Remove any 0 time indices (either by moving them to one, or deleting them.
    events(events == 0) = 1;
    
    %Ignore any events outside the scan time domain.
    events(events > state.acq.linesPerFrame * state.acq.numberOfFrames) = -1;
    
    events = [events state.acq.linesPerFrame * state.acq.numberOfFrames - 1];

    %Set the region of interest to the correct power, but dont touch the mins on flyback.
    binaryBit = 0;
    for arrayCounter = 1 : (length(events) - 1)
        if events(arrayCounter) < 1
            continue;   %Skip over a 0 or -1
        else
            %Go from the current event up to the next event (temporally).
            if state.init.eom.powerTransitions.useBinaryTransitions
                if binaryBit
                    currentpower = state.init.eom.lut(beam, max(state.init.eom.min(beam), state.init.eom.maxPower(beam)));
                    %fprintf(1, '\n binaryBit: %s\n currentPower: %s\n currentProtocol: %s\n\n', num2str(binaryBit), num2str(currentpower), num2str(state.init.eom.powerTransitions.currentProtocol));
                    binaryBit = 0;
                else
                    currentpower = state.init.eom.lut(beam, state.init.eom.min(beam));
                    %fprintf(1, '\n binaryBit: %s\n currentPower: %s\n currentProtocol: %s\n\n', num2str(binaryBit), num2str(currentpower), num2str(state.init.eom.powerTransitions.currentProtocol));
                    binaryBit = 1;
                end
            else
                currentpower = state.init.eom.lut(beam, max(state.init.eom.min(beam), round(state.init.eom.powerTransitions.power(beam, indices(arrayCounter)))));
            end
            %I don't know why the -2 and +1 are needed here, but without them, some points are missed, and it leaves the
            %power on near the transition into/out-of flyback. This was very hard to track down. -- Tim O'Connor 6/22/04
            %%TO062204a
            data(startGoodPockelsData - 2 : endGoodPockelsData + 1, events(arrayCounter) : (events(arrayCounter + 1) + 1)) = currentpower;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now apply any boxes to the mask for the pockels data.
%TO21704a - Check for focusing, and skip this part.
if length(state.init.eom.showBoxArray) < beam
    state.init.eom.showBoxArray(beam) = 0;
end
if state.init.eom.showBoxArray(beam) & ~isempty(state.init.eom.powerBoxNormCoords) & ~state.init.eom.uncagingPulseImporter.enabled ...
        & ~strcmpi(get(gh.mainControls.focusButton, 'String'), 'ABORT')
    %12/16/03 Tim O'Connor - Modified to behave differently during linescan.
    if state.acq.linescan == 1
        %The different behavior during linescans is intended for use during uncaging experiments.
        if state.init.eom.endFrameArray(beam) < state.init.eom.startFrameArray(beam)
            beep;
            fprintf(2, 'WARNING: ''Start Line'' must come before ''End Line'' in powerbox settings. The powerbox has not been applied to the scan.\n');
        elseif state.init.eom.endFrameArray(beam) > (state.acq.linesPerFrame * state.acq.numberOfFrames)
            beep;
            fprintf(2, 'WARNING: ''End Line'' must fall within the time bounds of the scan. The powerbox has not been applied to the scan.\n');
        else
            
            startPixel = ceil(startGoodPockelsData + (endGoodPockelsData - startGoodPockelsData) * (state.init.eom.powerBoxNormCoords(beam, 1))) + 30;
            if startPixel > endGoodPockelsData
                startPixel = endGoodPockelsData;
            end
            
            endPixel = ceil(startGoodPockelsData + (endGoodPockelsData - startGoodPockelsData) * sum(state.init.eom.powerBoxNormCoords(beam, [1 3])));
            if endPixel > endGoodPockelsData
                endPixel = endGoodPockelsData;
            end
            if state.init.eom.startFrameArray(beam)> 0 & state.init.eom.endFrameArray(beam) > 0 & round(state.init.eom.boxPowerArray(beam)) > 0
                data(startPixel : endPixel, state.init.eom.startFrameArray(beam) : state.init.eom.endFrameArray(beam)) = ...
                    state.init.eom.lut(beam,  round(state.init.eom.boxPowerArray(beam)));
            end
        end
    else
        startFrame = round(state.init.eom.startFrameArray(beam) - 1);
        endFrame = round(min(state.init.eom.endFrameArray(beam), state.acq.numberOfFrames) - 1);
        if startFrame < 0
            startFrame = 0;
        end
        if endFrame < 0
            endFrame = 0;
        end
        
        if endFrame < startFrame
            beep;
            fprintf(2, 'WARNING: ''Start Frame'' must come before ''End Frame'' in powerbox settings.\n');
        else
            lines = floor([state.init.eom.powerBoxNormCoords(beam, 2) sum(state.init.eom.powerBoxNormCoords(beam, [2 4]))] .* state.acq.linesPerFrame);
            %There's a serious rounding error here, which causes it to select 2 lines when it should be one.
            %So, I hardcoded a check against the 'Constrain To Line' checkbox. -- Tim O'Connor 6/2/04 TO060204a
            if state.init.eom.powerBoxUncagingConstraint
                lines(2) = lines(1);
                lines = lines(1:2);
            end
            
            %I took out this line about pixels because I have no idea why it's here. -- Tim O'Connor 12/16/03
            %             pixels = floor([state.init.eom.powerBoxNormCoords(beam, 1) sum(state.init.eom.powerBoxNormCoords(beam, [1 3]))] .* state.acq.pixelsPerLine);
            
            startPixel = ceil(startGoodPockelsData + (endGoodPockelsData - startGoodPockelsData) * (state.init.eom.powerBoxNormCoords(beam, 1)));
% startPixel
            endPixel = floor(startGoodPockelsData + (endGoodPockelsData - startGoodPockelsData) * sum(state.init.eom.powerBoxNormCoords(beam, [1 3])));
% endPixel
            if endFrame > -1 & startFrame > -1 & round(state.init.eom.boxPowerArray(beam)) > 0
                for frameCounter = startFrame : endFrame
                    data(startPixel : endPixel, ...
                        ((lines(1) : lines(2)) + frameCounter * state.acq.linesPerFrame)) = state.init.eom.lut(beam,  round(state.init.eom.boxPowerArray(beam)));
                end
            end
        end
    end
end

%Allow uncaging to turn the powerbox on and off for different lines. -- Tim O'Connor 12/18/03
%TO22604b: Make sure that the powerbox coordinates exist, for this beam. -- Tim O'Connor 2/26/04
if state.init.eom.uncagingPulseImporter.enabled & state.init.eom.showBoxArray(beam) & size(state.init.eom.powerBoxNormCoords, 1) >= beam & length(state.init.eom.powerBoxNormCoords(beam, :)) == 4

    %Figure out which pulseSet definition to use.
    if state.init.eom.uncagingPulseImporter.syncToPhysiology
        updateGUIByGlobal('state.init.eom.uncagingPulseImporter.position', 'Value', state.physiology.mainPhysControls.patternNum1, 'Callback', 1);
    end
    if state.init.eom.uncagingPulseImporter.position > size(state.init.eom.uncagingPulseImporter.cycleArray, 2)
        updateGUIByGlobal('state.init.eom.uncagingPulseImporter.position', 'Value', 1, 'Callback', 1);
    end
    
    %Find the portion of the line to "light up".
    startPixel = ceil(startGoodPockelsData + (endGoodPockelsData - startGoodPockelsData) * (state.init.eom.powerBoxNormCoords(beam, 1)));
    endPixel = ceil(startGoodPockelsData + (endGoodPockelsData - startGoodPockelsData) * sum(state.init.eom.powerBoxNormCoords(beam, [1 3])));
    
    %This will represent the uncaged lines and their powers. The horizontal extent is determined by the powerBox.
    lines = [];
    
    %Load the pulse (and any additive components) and calculate the lines and associated powers.
    pulse = loadPulseByNumber(beam, state.init.eom.uncagingPulseImporter.cycleArray(beam, state.init.eom.uncagingPulseImporter.position));
    loadedPulses(1) = state.init.eom.uncagingPulseImporter.cycleArray(beam, state.init.eom.uncagingPulseImporter.position);

    while ~isempty(pulse)
        %TO21704b - Allow a different pulse power for each beam.
        pulsePower = state.init.eom.boxPowerArray(beam) * pulse.amplitude * .01;
        
        %Find the rising edges.
        rising = ceil((pulse.delay : pulse.isi : (pulse.number - 1) * pulse.isi + pulse.delay) ...
            / state.init.eom.uncagingPulseImporter.lineConversionFactor)' + 1;
        rising(find(rising == 0)) = 1;%Should this be autocorrected or not?

        %Find the falling edges.
        falling = floor((pulse.delay + pulse.width : pulse.isi : (pulse.number - 1) * pulse.isi + pulse.width + pulse.delay) ...
            / state.init.eom.uncagingPulseImporter.lineConversionFactor)' + 1;
        falling(find(falling == 0)) = 1;%Should this be autocorrected or not?

        %Remove duplicates.
        edges = unique(cat(1, rising, falling));
        edges = sort(edges);

        if size(lines) > 0
            %Find the intersections and set those to additive values.
            [intersectionResult ilines iedges] = intersect(lines(:, 1), edges);
            lines(ilines, 2) = lines(ilines, 2) + pulsePower;
            
            %Throw away the intersecting edges, since they've been handled already.
            edges = edges(find(~ismember(edges, edges(iedges))));
            
            %TO072004c
            for i = 1 : length(rising)
                %Only treat rising-->falling regimes.
                if ismember(edges(i), falling)
                    continue;
                end
                
                %Find the next falling edge.
                finish = find(falling > edges(i));
                if isempty(finish)
                    finish = size(data, 2);
                else
                    finish = finish(1);
                end
                
                %Set all new lines and set them.
                lines(size(lines, 1) + 1 : size(lines, 1) + 1 + length(edges(i) : finish), 1) = (edges(i) : finish)';
                lines(size(lines, 1) + 1 : size(lines, 1) + 1 + length(edges(i) : finish), 2) = pulsePower;
            end
%             %Combine additive elements.
%             [intersectionResult ilines iedges] = intersect(lines(:, 1), edges);
%             lines(ilines, 2) = lines(ilines, 2) + pulsePower;
%             
%             %Trim out the unique lines.
%             [diffResult dedges] = setdiff(edges, lines(:, 1));
%             edges = edges(dedges);
%             
%             %Set the amplitude.
%             edges(:, 2) = pulsePower;
%             
%             %Insert any new lines.
%             lines = cat(1, lines, edges);
            %TO072004c
        else
            %TO072004c
            for i = 1 : length(rising)
                %Only treat rising-->falling regimes.
                if ismember(edges(i), falling)
                    if ~ismember(edges(i), edges)
                        continue;
                    end
                end

                %Find the next falling edge.
                finish = find(falling >= edges(i));
                if isempty(finish)
                    finish = size(data, 2);
                else
                    finish = falling(finish(1));
                end

                %Set all new lines and set them.
                lines = (edges(i) : finish)';
                lines(:, 2) = pulsePower;
            end
%             lines = edges;
%             lines(:, 2) = pulsePower;
        end
        
        %Quit out of the loop, if the next additive component has already been handled 
        %or there is no additive component.
        if pulse.addComp < 1 | ismember(pulse.addComp, loadedPulses)          
            break;
        end
        
        %Do the next pulse.
        if pulse.addComp > 0
            %Mark this one as loaded, to stop infinite recursion.
            loadedPulses(length(loadedPulses) + 1) = pulse.addComp;
            
            pulse = loadPulseByNumber(beam, pulse.addComp);
        end
    end

    if ~isempty(lines)
        %Enforce boundary conditions.
        overLimit = find(lines(:, 2) > 100);
        if ~isempty(overLimit)
            fprintf(2, 'WARNING: Found pulse amplitudes greater than 100%%, setting to 100%%.\n');
            lines(overLimit, 2) = 100;
        end
        underLimit = find(lines(:, 2) < state.init.eom.min(beam));
        if ~isempty(underLimit)
            fprintf(2, 'WARNING: Found pulse amplitudes less than minimum for beam %s (%s), setting to %s.\n', num2str(beam), ...
                num2str(state.init.eom.min(beam)), num2str(state.init.eom.min(beam)));
            
            lines(underLimit, 2) = state.init.eom.min(beam);
        end
        
        %Set the values for each line. I can't think of a good way to easily vectorize this...
        for i = 1 : size(lines, 1)
            if lines(i, 1) > 0 & lines(i, 1) <= size(data, 2)
                data(startPixel : endPixel, lines(i, 1)) = ...
                    state.init.eom.lut(beam,  round(lines(i, 2)));
                % state.init.eom.lut(beam,  round(lines(i, 2)))
                % d = reshape(data(1 : state.internal.lengthOfXData * state.acq.linesPerFrame * state.acq.numberOfFrames), ...
                %         state.internal.lengthOfXData * state.acq.linesPerFrame * state.acq.numberOfFrames, 1);
                % domain = 1000 .* (1:length(d)) ./ getAOProperty(state.acq.dm, 'PockelsCell-2', 'SampleRate');
                % figure;plot(domain, d);
            elseif lines(i, 1) < 1
                %Should this be corrected automatically (above) or just printed here?
                fprintf(2, 'WARNING: Found uncaging pulse specified for line 0, while line indexing starts at 1. The pulse has been ignored.\n');
            end
        end
    end
elseif state.init.eom.uncagingPulseImporter.enabled & state.init.eom.uncagingPulseImporter.cycleArray(beam, state.init.eom.uncagingPulseImporter.position) > 0
    %TO21804b More informative, in case someone forgets to turn on the powerbox.
    fprintf(2, 'WARNING: UncagingPulseImporter is enabled, but no powerbox is selected. Uncaging pulses are being ignored.\n');
end

%UncagingMapper support. Tim O'Connor 2/27/04 TO22704a
if length(state.init.eom.uncagingMapper.enabled) < beam
    state.init.eom.uncagingMapper.enabled(beam) = 0;
end

%TO051507A
lastFrame = state.acq.numberOfFrames;

if state.init.eom.uncagingMapper.enabled(beam) & ...
        size(state.init.eom.uncagingMapper.pixels, 3) == 4% & ...
    %         any(state.init.eom.uncagingMapper.pixels(beam, :, :))
    
    if state.init.eom.uncagingMapper.perGrab
        if state.init.eom.uncagingMapper.position <= size(state.init.eom.uncagingMapper.pixels, 2)
            %TO051507A - Uncage at frames other than 1.
            activeFrame = state.acq.numberOfFrames;
            if (activeFrame > 1) && (state.init.eom.startFrameArray(beam) > 1)
                activeFrame = state.init.eom.startFrameArray(beam);
            end
            
            %X
            xPos = ceil(startGoodPockelsData + (endGoodPockelsData - startGoodPockelsData) * state.init.eom.uncagingMapper.pixels(beam, ...
                state.init.eom.uncagingMapper.position, 1));
            %Y
            yPos = round(state.acq.linesPerFrame * state.init.eom.uncagingMapper.pixels(beam, state.init.eom.uncagingMapper.position, 2) + (activeFrame - 1) * state.acq.linesPerFrame);%TO051507A
            
            %Width in milliseconds.
            %             width = ceil((endGoodPockelsData - startGoodPockelsData) * ...
            width = round((endGoodPockelsData - startGoodPockelsData) * ...
                state.init.eom.uncagingMapper.pixels(beam, state.init.eom.uncagingMapper.position, 3) / (1000 * state.acq.msPerLine * state.acq.fillFraction));%state.init.eom.uncagingMapper.numberOfPixels);
            if width == 0
                width = 1;
            end
            % width            
            % fprintf(1, '%% of line: %s\n# of samples: %s\n\n', num2str(100 * state.init.eom.uncagingMapper.pixels(beam, state.init.eom.uncagingMapper.position, 3) / (1000 * state.acq.msPerLine * state.acq.fillFraction)), num2str(state.acq.pixelsPerLine * ...
            %                 state.init.eom.uncagingMapper.pixels(beam, state.init.eom.uncagingMapper.position, 3) / (1000 * state.acq.msPerLine * state.acq.fillFraction)));
            %Power
            power = round(state.init.eom.uncagingMapper.pixels(beam, state.init.eom.uncagingMapper.position, 4));
            for i = 1 : length(power)
                if power(i) < state.init.eom.min(beam)
                    power(i) = state.init.eom.min(beam);
                end
            end
            %         power(find(power < state.init.eom.min(beam)) = state.init.eom.min(beam);
            power(:) = state.init.eom.lut(beam, power(:));
        else
            fprintf(2, 'ERROR: UncagingMapper''s current pixel is out of the range of specified pixels.\n Current: %s\n Specified: %s', ...
                num2str(state.init.eom.uncagingMapper.position), num2str(size(state.init.eom.uncagingMapper.pixels, 2)));
        end
    elseif state.init.eom.uncagingMapper.perFrame
        pos = state.init.eom.uncagingMapper.position;
        %         if state.init.eom.uncagingMapper.position == size(state.init.eom.uncagingMapper.pixels, 2)
        %             state.init.eom.uncagingMapper.position = 1;
        %          end
        lastFrame = min(findLastValidPixel(beam), state.init.eom.uncagingMapper.position + state.acq.numberOfFrames);

        %Calculate the starting x-indices.
        xPos = ceil(startGoodPockelsData + (endGoodPockelsData - startGoodPockelsData) * state.init.eom.uncagingMapper.pixels(beam, ...
            state.init.eom.uncagingMapper.position : lastFrame, 1));
        if xPos > endGoodPockelsData
            xPos = endGoodPockelsData;
        end
        
        %Calculate the y-indices.
        yPos = round(state.acq.linesPerFrame * state.init.eom.uncagingMapper.pixels(beam, state.init.eom.uncagingMapper.position : lastFrame, 2)) - 1;

        %Space them out into frames.
        for i = 2 : length(yPos)
            yPos(i) = yPos(i) + (i - 1) * state.acq.linesPerFrame;
        end
        yPos = yPos(find(yPos < state.acq.linesPerFrame * state.acq.numberOfFrames));

        %Calulate the ending x-indices.
        width = floor((endGoodPockelsData - startGoodPockelsData) * ...
            state.init.eom.uncagingMapper.pixels(beam, state.init.eom.uncagingMapper.position : lastFrame, 3) / (1000 * state.acq.msPerLine * state.acq.fillFraction)) - 1;
        if width > endGoodPockelsData
            width = endGoodPockelsData;
        end
        width(find(width == 0)) = 1;
        
        %Retrieve the power.
        power = round(state.init.eom.uncagingMapper.pixels(beam, state.init.eom.uncagingMapper.position  : lastFrame, 4));
        for i = 1 : length(power)
            if power(i) < state.init.eom.min(beam)
                power(i) = state.init.eom.min(beam);
            end
        end
        %         power(find(power < state.init.eom.min(beam)) = state.init.eom.min(beam);
        power(:) = state.init.eom.lut(beam, power(:));

        %TO051904a - Wrap around, so that each frame has a pixel, as per Alex's request. -- Tim O'Connor 5/19/04
        normalLength = length(yPos);
        try
            if lastFrame < state.acq.numberOfFrames
                lastStart = 1;
                while length(xPos) < state.acq.numberOfFrames
                    nextLength = min(2 * length(xPos), state.acq.numberOfFrames);
                    
                    xPos(length(xPos) + 1 : nextLength) = xPos(lastStart : nextLength - length(xPos));
                    yPos(length(yPos) + 1 : nextLength) = yPos(lastStart : nextLength - length(yPos));
                    width(length(width) + 1 : nextLength) = width(lastStart : nextLength - length(width));
                    power(length(power) + 1 : nextLength) = power(lastStart : nextLength - length(power));
                    lastStart = nextLength - length(xPos) + 1;
                    %Don't forget to space these out into other frames.                    
                    yPos(normalLength + 1 : end) = yPos(normalLength + 1 : end) + normalLength * state.acq.linesPerFrame;
                end
                %Don't forget to space these out into other frames.
%                 yPos(normalLength + 1 : end) = yPos(normalLength + 1 : end) + normalLength * state.acq.linesPerFrame;
            end
        catch
            warning('Error reusing pixels (there are more frames than pixels): %s', lasterr);
        end
    elseif state.init.eom.uncagingMapper.singleFrame
        %TO052507A - Added singleFrame option. -- Tim O'Connor 5/15/07

        %Find the last valid pixel.
        lv_pixel = findLastValidPixel(beam);

        activeFrame = state.acq.numberOfFrames;
        if (activeFrame > 1) && (state.init.eom.startFrameArray(beam) > 1)
            activeFrame = state.init.eom.startFrameArray(beam);
        end

        xPos = zeros(lv_pixel, 1);
        yPos = xPos;
        width = xPos;
        power = xPos;
        for i = 1 : length(xPos)
            %X
            xPos(i) = ceil(startGoodPockelsData + (endGoodPockelsData - startGoodPockelsData) * state.init.eom.uncagingMapper.pixels(beam, i, 1));
            %Y
            yPos(i) = round(state.acq.linesPerFrame * state.init.eom.uncagingMapper.pixels(beam, i, 2) + (activeFrame - 1) * state.acq.linesPerFrame);
            
            %Width in milliseconds.
            %             width = ceil((endGoodPockelsData - startGoodPockelsData) * ...
            width(i) = round((endGoodPockelsData - startGoodPockelsData) * ...
                state.init.eom.uncagingMapper.pixels(beam, i, 3) / (1000 * state.acq.msPerLine * state.acq.fillFraction));%state.init.eom.uncagingMapper.numberOfPixels);
            if width == 0
                width = 1;
            end
            % width            
            % fprintf(1, '%% of line: %s\n# of samples: %s\n\n', num2str(100 * state.init.eom.uncagingMapper.pixels(beam, state.init.eom.uncagingMapper.position, 3) / (1000 * state.acq.msPerLine * state.acq.fillFraction)), num2str(state.acq.pixelsPerLine * ...
            %                 state.init.eom.uncagingMapper.pixels(beam, state.init.eom.uncagingMapper.position, 3) / (1000 * state.acq.msPerLine * state.acq.fillFraction)));
            %Power
            power(i) = round(state.init.eom.uncagingMapper.pixels(beam, i, 4));
            if power(i) < state.init.eom.min(beam)
                power(i) = state.init.eom.min(beam);
            end
        end

        power(:) = state.init.eom.lut(beam, power(:));
        state.init.eom.uncagingMapper.position = 1;
        updateGUIByGlobal('state.init.eom.uncagingMapper.pixel', 'Value', 1, 'Callback', 1);
    else
        fprintf(2, 'ERROR: UncagingMapper is enabled, but can not determine if pixels are perGrab, perFrame, or singleFrame.\n');
    end

    yPos = yPos + 1;
    yPos = yPos(find(yPos <= (state.acq.linesPerFrame * state.acq.numberOfFrames) - 1));
    yPos(find(yPos > (state.acq.linesPerFrame * state.acq.numberOfFrames))) = state.acq.linesPerFrame * state.acq.numberOfFrames;

    %Strip out -1s.
    ind = find(yPos > -1);
    ind = find(xPos(ind) > -1);
    ind = find(width(ind) > -1);
    ind = find(power(ind) > -1);
    xPos = xPos(ind);
    yPos = yPos(ind);
    width = width(ind);
    power = power(ind);

    if state.acq.numberOfFrames > lastFrame
        state.init.eom.uncagingMapper.pixelCount = mod(findLastValidPixel(beam), length(yPos));
    else
        state.init.eom.uncagingMapper.pixelCount = length(yPos);
    end

    overRuns = find(width(:) + xPos(:) > size(data, 1));
    width(overRuns) = size(data,  1) - xPos(overRuns);

    % fprintf(1, 'Data: %s -- startX: %s endX: %s y: %s\n',
    if ~isempty(yPos) & yPos ~= 0
        for i = 1 : length(xPos)
%             fprintf(1, '\nChanging (%s : %s, %s) to %s.\n\n', num2str(xPos(i)), num2str(xPos(i) + width(i)), num2str(yPos(i)), ...
%                 num2str(state.init.eom.lut(round(state.init.eom.uncagingMapper.pixels(beam, i, 4)))));
            
            %             if ((xPos(i) + width(i)) * yPos(i)) < state.internal.lengthOfXData * state.acq.linesPerFrame * state.acq.numberOfFrames &
            %                 (xPos(i) * yPos(i)) < state.internal.lengthOfXData * state.acq.linesPerFrame * state.acq.numberOfFrames
            if prod(size(data)) >= ((xPos(i) + width(i)) * yPos(i))
                % fprintf(1, 'Pixel %s: Setting indices [(%s) to (%s)] out of (%s) to %sV\n', num2str(i), num2str([xPos(i) xPos(i)]), num2str([(xPos(i) + width(i)) yPos(i)]), num2str(size(data)), num2str(power(i)));
                data(xPos(i) : xPos(i) + width(i), yPos(i)) = power(i);
            end
        end
    else
        %This message comes up erroneously.
%         fprintf(1, 'UncagingMapper found a pixel that is outside the current field of view in the y-coordinate.\n');
    end
    
    try
        updateHeaderString('state.init.eom.uncagingMapper.pixels');
        updateHeaderString('state.init.eom.uncagingMapper.pixel');
        updateHeaderString('state.init.eom.uncagingMapper.power');
        updateHeaderString('state.init.eom.uncagingMapper.x');
        updateHeaderString('state.init.eom.uncagingMapper.y');
    catch
        warning(lasterr);
    end
    % figure;plot(reshape(data(1 : state.internal.lengthOfXData * state.acq.linesPerFrame * state.acq.numberOfFrames), ...
    %         state.internal.lengthOfXData * state.acq.linesPerFrame * state.acq.numberOfFrames, 1));
end

try
    %reshape data and output it...
    out = reshape(data(1 : state.internal.lengthOfXData * state.acq.linesPerFrame * state.acq.numberOfFrames), ...
        state.internal.lengthOfXData * state.acq.linesPerFrame * state.acq.numberOfFrames, 1);
catch
    error(sprintf('implementPockelsCellTiming failed!\n%s\nsize(data) = %s\nreshapedTo: %s\n', lasterr, num2str(size(data)), num2str(state.internal.lengthOfXData * state.acq.linesPerFrame * state.acq.numberOfFrames)));
end

return;

%--------------------------------------------------------
function pulse = loadPulseByNumber(beam, pulseNumber)
global state;

pulse = [];

if pulseNumber == 0
    return;
elseif length(state.init.eom.uncagingPulseImporter.pathnameText) < 1
    return;
end

%Construct the filename.
slashes = find(state.init.eom.uncagingPulseImporter.pathnameText == '\');
fname = '';

if state.init.eom.uncagingPulseImporter.pathnameText(length(state.init.eom.uncagingPulseImporter.pathnameText)) == '\'
    fname = [state.init.eom.uncagingPulseImporter.pathnameText(slashes(length(slashes) - 1) + 1 : length(state.init.eom.uncagingPulseImporter.pathnameText) - 1) ...
            num2str(pulseNumber) '.mpf'];
else
    fname = ['\' state.init.eom.uncagingPulseImporter.pathnameText(slashes(length(slashes)) + 1 : length(state.init.eom.uncagingPulseImporter.pathnameText)) ...
            num2str(pulseNumber) '.mpf'];
end
pulse = load([state.init.eom.uncagingPulseImporter.pathnameText fname], '-mat');
pulse = pulse.p;

%Apply conversion factors.
pulse.amplitude = pulse.amplitude / state.init.eom.uncagingPulseImporter.powerConversionFactor;
% pulse.width = pulse.width * state.acq.msPerLine * 1000 / state.init.eom.uncagingPulseImporter.lineConversionFactor;
% if mod(pulse.width, 1000 * state.acq.msPerLine) == 0 & state.init.eom.uncagingPulseImporter.scalePulseWidth
%     pulse.width = 500 * state.acq.msPerLine;
% end
pulse.totalTime = pulse.totalTime * state.acq.msPerLine * 1000 / state.init.eom.uncagingPulseImporter.lineConversionFactor;
pulse.offset = pulse.offset * state.acq.msPerLine * 1000 / state.init.eom.uncagingPulseImporter.lineConversionFactor;
pulse.isi = pulse.isi * state.acq.msPerLine * 1000 / state.init.eom.uncagingPulseImporter.lineConversionFactor;
if pulse.isi == 0
    pulse.isi = 1;
end
pulse.delay = pulse.delay * state.acq.msPerLine * 1000 / state.init.eom.uncagingPulseImporter.lineConversionFactor;

return;

%--------------------------------------------
function pixel = findLastValidPixel(beam)
global state;

%Find the earliest pixel with a -1 value.
[beam2, pixel, field] = ind2sub(size(state.init.eom.uncagingMapper.pixels), find(state.init.eom.uncagingMapper.pixels(:, :, :) == -1));
pixel = min(pixel(find(beam == beam2)));

if ~any(find(state.init.eom.uncagingMapper.pixels(beam, :, :) == -1))
    pixel = size(state.init.eom.uncagingMapper.pixels, 2);
end

if isempty(pixel)
    pixel = 1;
end

pixel = pixel;

return;