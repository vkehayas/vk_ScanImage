function setColorMapFromMenu(input)
global gh state
handles=flipud(get(gh.mainControls.colormap, 'Children'));
set(handles,'Checked','off');
setImagesToWhole;
if ischar(input)
    %mkaes the colormpas from the menus...
    selected=getfield(gh.mainControls,input);
    state.internal.colormapSelected=find(handles==selected);
    set(handles(state.internal.colormapSelected),'Checked','On');
    set(state.internal.GraphFigure,'ColorMap',makeColorMap(input));
elseif isnumeric(input)
    selected=handles(input);
    set(selected,'Checked','On');
    state.internal.colormapSelected=input;
    set(state.internal.GraphFigure,'ColorMap',makeColorMap(get(selected,'Tag')));
end

