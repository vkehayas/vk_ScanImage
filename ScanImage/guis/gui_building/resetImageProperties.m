function resetImageProperties(scale)
global state gh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% Function that creates or reformats the images to comply with current mode of operation.
%
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% April 3, 2003
%
% Changes:
%   TPMOD_1: Modified 12/31/03 Tom Pologruto - Corrects max figure positions as well
%       as remembering the correct locations of acq. figures
%   TPMOD_2: Modified 12/31/03 Tom Pologruto - Since we cannot compute the proper ratio of X:Y
%       in a linescan mode, we need to tell peopel their figures will not
%       go where they are supposed to...
%   VI022108A: Modified 2/21/08 Vijay Iyer - Added merge figure to list of images reset
%   VI042208A: Modified 4/22/08 Vijay Iyer - Don't beep at the user when unable to reset the Image properties; switch from warning to red fprintf() 
%   VI071709B: Fix bug where update of merge figure has transposed dimensions -- Vijay Iyer 7/17/09
%   VI103009A: Don't display 'Making image windows' to status string -- Vijay Iyer 10/30/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin~=1
    scale=1;
end
% Define the figure and its properties.  USe uint8 since they are al zeros and to save memory.
%status=state.internal.statusString; %VI103009A
%setStatusString('Making image windows...'); %VI103009A
axisPosition = [0 0 1 1];
% This loop sets up the aspect ratios for the figures
if state.acq.scanAmplitudeY ~= 0 & state.acq.scanAmplitudeX ~= 0
    aspectRatioF = abs(state.internal.imageAspectRatioBias*state.acq.scanAmplitudeY/state.acq.scanAmplitudeX); 
    aspectRatio = (state.acq.pixelsPerLine/state.acq.linesPerFrame)*aspectRatioF;
else % Line scan so make the image accordingly....
    
    aspectRatioF=-1;
    aspectRatio=-1;
    % start TPMOD_2 12/31/03
    % beep,warning('resetImageProperties: cannot change figure positions in a linescan mode.');
    fprintf(2,'resetImageProperties: cannot change figure positions in a linescan mode.\n'); %VI052208A
    % end TPMOD_2 12/31/03
end

%Set the figure positions....
figurePosition=ones(state.init.maximumNumberOfInputChannels,4); %initialize the array...
maxfigurePosition=ones(state.init.maximumNumberOfInputChannels,4); %initialize the array...
for i = 1:state.init.maximumNumberOfInputChannels
    if state.acq.imagingChannel(i) | state.acq.maxImage(i)
        if aspectRatioF <= 1 & aspectRatioF > 0
            eval(['figurePosition(i,:) = [state.internal.figurePositionX' num2str(i) ' state.internal.figurePositionY' ...
                    num2str(i) ' state.internal.figureWidth' num2str(i) ' aspectRatioF*state.internal.figureHeight' num2str(i) '];']);
            eval(['maxfigurePosition(i,:) = [state.internal.maxfigurePositionX' num2str(i) ' state.internal.maxfigurePositionY' ...
                    num2str(i) ' state.internal.maxfigureWidth' num2str(i) ' aspectRatioF*state.internal.maxfigureHeight' num2str(i) '];']);
        elseif aspectRatioF > 1                
            eval(['figurePosition(i,:) = [state.internal.figurePositionX' num2str(i) ' state.internal.figurePositionY' ...
                    num2str(i) ' state.internal.figureWidth' num2str(i) '/aspectRatioF state.internal.figureHeight' num2str(i) '];']);
            eval(['maxfigurePosition(i,:)  = [state.internal.maxfigurePositionX' num2str(i) ' state.internal.maxfigurePositionY' ...
                    num2str(i) ' state.internal.maxfigureWidth' num2str(i) '/aspectRatioF state.internal.maxfigureHeight' num2str(i) '];']);
        else    %lINESCAN.....
            figurePosition(i,:)=get(state.internal.GraphFigure(i),'position');
            maxfigurePosition(i,:)=get(state.internal.MaxFigure(i),'position');
        end
    end
end

%Handle merge figure similarly (VI022108A)
if aspectRatioF <= 1 && aspectRatioF > 0
    mergePosition = [state.internal.mergefigurePositionX state.internal.mergefigurePositionY ...
        state.internal.mergefigureWidth aspectRatioF*state.internal.mergefigureHeight];
  elseif aspectRatioF > 1
      mergePosition = [state.internal.mergefigurePositionX state.internal.mergefigurePositionY ...
          state.internal.mergefigureWidth/aspectRatioF state.internal.mergefigureHeight];
  else    %lINESCAN.....
      mergePosition = get(state.internal.MergeFigure,'position'); %Not clear how this could work
end

%Set the figure properties....
for i = 1:state.init.maximumNumberOfInputChannels % Count through all the channels
    if state.acq.imagingChannel(i)	% is thsi one to be imaged?
        set(state.internal.axis(i),'XLim',  [1 state.acq.pixelsPerLine], 'YLim', [1 state.acq.linesPerFrame], 'CLim', [state.internal.lowPixelValue(i) ...
                state.internal.highPixelValue(i)], 'Position', axisPosition);
        set(state.internal.GraphFigure(i),'Visible', 'on');
        if aspectRatio > 0
            set(state.internal.axis(i),'DataAspectRatio', [aspectRatio 1 1])
        end
        if scale
            if aspectRatioF > 0
                set(state.internal.GraphFigure(i),'Position', figurePosition(i,:));
            end
        end
    else
        set(state.internal.GraphFigure(i), 'Visible', 'off');
    end
    if state.acq.maxImage(i)	% is thsi one to be imaged?
        set(state.internal.maxaxis(i),'XLim',  [1 state.acq.pixelsPerLine], 'YLim', [1 state.acq.linesPerFrame], 'CLim', [state.internal.lowPixelValue(i) ...
                state.internal.highPixelValue(i)], 'Position', axisPosition);
        set(state.internal.MaxFigure(i),'Visible', 'on');
        if aspectRatio > 0
            set(state.internal.maxaxis(i),'DataAspectRatio', [aspectRatio 1 1])
        end
        if scale 
            if aspectRatioF > 0
                % start TPMOD_1 12/31/03 
                set(state.internal.MaxFigure(i),'Position', maxfigurePosition(i,:));
                % end TPMOD_1 12/31/03
            end
        end
    else
        set(state.internal.MaxFigure(i), 'Visible', 'off');
    end
end

%Handle merge window similarly (VI022108A)
if state.acq.channelMerge
    set(state.internal.mergeaxis,'XLim', [1 state.acq.pixelsPerLine],'YLim',[1 state.acq.linesPerFrame],'DataAspectRatioMode','manual','Position',axisPosition);
    if aspectRatio > 0
        set(state.internal.mergeaxis,'DataAspectRatio', [aspectRatio 1 1])
    end
    if scale
        if aspectRatioF > 0
            set(state.internal.MergeFigure,'Position',mergePosition);
        end
    end
    state.internal.mergeimage =  image('CData',uint8(zeros(state.acq.linesPerFrame,state.acq.pixelsPerLine,3)),'Parent',state.internal.mergeaxis); %VI071709B
    set(state.internal.MergeFigure,'Visible','on');
else
    set(state.internal.MergeFigure,'Visible','off');
end

updateClim;
updateMainControlSize;
%setStatusString(status); %VI103009A
