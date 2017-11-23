function updateCurrentFigure
global state

% updateCurrentFigure.m****
% Function that will grab the current figure positions and write them to the structure state.
%
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% March 2, 2001

for channelCounter = 1:state.init.maximumNumberOfInputChannels
    position = get(state.internal.GraphFigure(channelCounter), 'Position');
    eval(['state.internal.figurePositionX' num2str(channelCounter) ' = position(1,1);']);
    eval(['state.internal.figurePositionY' num2str(channelCounter) '= position(1,2);']);
    eval(['state.internal.figureWidth' num2str(channelCounter) ' = position(1,3);']);
    eval(['state.internal.figureHeight' num2str(channelCounter) ' = position(1,4);']);
    position = get(state.internal.MaxFigure(channelCounter), 'Position');
    eval(['state.internal.maxfigurePositionX' num2str(channelCounter) ' = position(1,1);']);
    eval(['state.internal.maxfigurePositionY' num2str(channelCounter) '= position(1,2);']);
    eval(['state.internal.maxfigureWidth' num2str(channelCounter) ' = position(1,3);']);
    eval(['state.internal.maxfigureHeight' num2str(channelCounter) ' = position(1,4);']);
end

%TPMODPockels
roipos=[state.internal.roifigurePositionX state.internal.roifigurePositionY state.internal.roifigureWidth state.internal.roifigureHeight];
pos=get(state.internal.roifigure,'Position');
state.internal.roifigureVisible=get(state.internal.roifigure,'Visible');
state.internal.roifigurePositionX=pos(1,1);
state.internal.roifigurePositionY=pos(1,2);
state.internal.roifigureWidth=pos(1,3);
state.internal.roifigureHeight=pos(1,4);