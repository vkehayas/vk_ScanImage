function gotoROINum(num)
% thsi is the function for the ui menu for the roi rectangles
global state gh
str=get(gh.mainControls.roiSaver,'String');
val=get(gh.mainControls.roiSaver,'Value');

if ~iscellstr(str)
    str={str};
end

max=length(str);
if isempty(num) | num > max 
    beep;
    disp('Invalid ROI number');
else
    set(gh.mainControls.roiSaver,'Value',num);
    gotoROI(gh.mainControls.roiSaver);
end