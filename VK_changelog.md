**annotationCorrelator.m**,
```diff
line 501
-oldDist = pdist(oldCoords);
+oldDist = dist(oldCoords); % EDIT VK, 21/03/2014
```
```diff
line 561
-oldDist = pdist(oldCoords);
+oldDist = dist(oldCoords); % EDIT VK, 28/03/2014
```

line 826
`newAnnotations(i).correlationID = ia_getNewCorrelationID;`
with
`newAnnotations(i).correlationID = ia_getNewCorrelationId;   % EDIT VK: 25/11/2014`

line 976
`newAnnotations(i).correlationID = ia_getNewCorrelationID;`
with
`newAnnotations(i).correlationID = ia_getNewCorrelationId;`

ia_annotate, line 55
`annotations(index).correlationID = ia_getNewCorrelationId;`
with
`annotations(index).correlationID = ia_getNewCorrelationId; % EDIT VK, 28/03/2014`

stackBrowser.m, lines 1884-1974, button remapping
   ```case 65
        %a
        % annotate_Callback(hObject);
        trackLeft_Callback(hObject); % EDIT VK:01/04/2014

    case 97
        %A
        %annotate_Callback(hObject);
        trackLeft_Callback(hObject); % EDIT VK:01/04/2014

%     case 69   % EDIT VK:01/04/2014
%         %e
    case 119
        % w % EDIT VK:01/04/2014
        trackUp_Callback(hObject);

%     case 101
%         %E
    case 87
        % W
        trackUp_Callback(hObject);

%     case 70 % EDIT VK:01/04/2014
%         %f
%         trackRight_Callback(hObject);
%
%     case 102
%         %F
%         trackRight_Callback(hObject);
% END EDIT VK:01/04/2014

    case 83
        %s
%         trackLeft_Callback(hObject); % EDIT VK:01/04/2014
        trackDown_Callback(hObject);

    case 115
        %S
%         trackLeft_Callback(hObject); % EDIT VK:01/04/2014
        trackDown_Callback(hObject);

    case 68
        %d
%         trackDown_Callback(hObject); % EDIT VK:01/04/2014
        trackRight_Callback(hObject);

    case 100
        %D
%         trackDown_Callback(hObject); % EDIT VK:01/04/2014
        trackRight_Callback(hObject);

%     case 90
%         %Z
    case 113 % EDIT VK:01/04/2014
        % q
        setLocal(progmanager, hObject, 'frameNumber', getLocal(progmanager, hObject, 'frameNumber') - 1);
        frameEditBox_Callback(hObject);

%     case 122
%         %z
    case 81 % EDIT VK:01/04/2014
        % Q
        setLocal(progmanager, hObject, 'frameNumber', getLocal(progmanager, hObject, 'frameNumber') - 1);
        frameEditBox_Callback(hObject);

%     case 120
%         %x
    case 101 % EDIT VK:01/04/2014
        % e
        setLocal(progmanager, hObject, 'frameNumber', getLocal(progmanager, hObject, 'frameNumber') + 1);
        frameEditBox_Callback(hObject);

%     case 88
%         %X
    case 69 % EDIT VK:01/04/2014
        % E
        setLocal(progmanager, hObject, 'frameNumber', getLocal(progmanager, hObject, 'frameNumber') + 1);
        frameEditBox_Callback(hObject);

    case 114    % EDIT VK:07/04/2014
        % r
        feval(getGlobal(progmanager, 'saveMenuItem_Callback', 'StackBrowserControl', 'stackBrowserControl'), ...
            getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), hObject)

    case 82 % EDIT VK:07/04/2014
        % R
        feval(getGlobal(progmanager, 'saveMenuItem_Callback', 'StackBrowserControl', 'stackBrowserControl'), ...
            getGlobal(progmanager, 'hObject', 'StackBrowserControl', 'stackBrowserControl'), hObject)

    case 32 % EDIT VK: 09/05/2014
        annotate_Callback(hObject);```

stackBrowswerControl.m, line 112
'defaultFilter', 'median', 'Class', 'char', 'Gui', 'defaultFilter', ...
with
'defaultFilter', 'none', 'Class', 'char', 'Gui', 'defaultFilter', ...

line 133
setLocal(progmanager, hObject, 'defaultFilter', 'median');
with
setLocal(progmanager, hObject, 'defaultFilter', 'none');


VK140929A: ia_updatePhotometryValues.m, line 192
Rename variable ‘integral’ to ‘integralValues’, due to conflict with built-in function ‘integral’

VK140929B: ia_updatePhotometryValues.m, line 219
<del>Removed background multiplication by number of ‘integralRegion’ pixels, assuming that both ‘integralRegion’ and ‘backgroundRegion’ are of approximately equal sizes</del>
Reverted to previous. Background is mean value, spine intensity is integral.

Modernized code in ia_updatePhotometryValues, renamed loop indicator ‘i’ to ‘iBounds’ [loop starting line = 105, for iBounds = 2:length(x)]

VK140929C: ia_updatePhotometryFromAnnotation, line 31, line 52
Set default ’normalizationMethod’ to 1 (=mean)

VK140929D: ia_updatePhotometryValues.m, line 146, line 149
Swapped ‘mean’ and ‘median’ between those two lines to match GUI options. ‘median’ (thought to be ‘mean') is still broken (it saturates at 655) but ‘mean’ is producing the correct values.

VK140930A, ia_updatePhotometryValues, line 194
add line:
integralAboveBackground = integralRegion(integralRegion > background) - background;

line 198: replace
numel(integralRegion)
with
numel(integralAboveBackground)

line 209
calculated = (integral - background * prod(size(integralRegion))) / (normalizationFactor - background);%TO091707A
with
calculated = integralValue ./ (normalizationFactor - background); %VK140930 Background subtraction was removed as now only values above threshold are integrated (see line 195)


VK170906A: stackBrowser.m, line 78-79
Replace hard-coded white value limit, replace
if getLocal(progmanager, hObject, 'whiteValue') > 3000
  setLocal(progmanager, hObject, 'whiteValue', 3000);
with
if getLocal(progmanager, hObject, 'whiteValue') > 65000
  setLocal(progmanager, hObject, 'whiteValue', 65000);

Replace hard-coded black value limit:
if getLocal(progmanager, hObject, 'blackValue') > 2999
  setLocal(progmanager, hObject, 'blackValue', 2999);
with
if getLocal(progmanager, hObject, 'blackValue') > 64999
  setLocal(progmanager, hObject, 'blackValue', 64999);

VK170906B: stackBrowser.m, line 477-478
Replace permitted range:
  'whiteValue', 200, 'Class', 'Numeric', 'Min' 0, 'Max', 2000, 'Gui', 'whiteValueSlider', 'Gui', 'whiteValueText', ...
  'blackValue', 0, 'Class', 'Numeric', 'Min' 0, 'Max', 2000, 'Gui', 'blackValueSlider', 'Gui', 'blackValueText', ...
with
  'whiteValue', 2000, 'Class', 'Numeric', 'Min' 1, 'Max', 65000, 'Gui', 'whiteValueSlider', 'Gui', 'whiteValueText', ...
  'blackValue', 0, 'Class', 'Numeric', 'Min' 0, 'Max', 64999, 'Gui', 'blackValueSlider', 'Gui', 'blackValueText', ...

VK170908A: shiftDendriteMax.m
Comment out median filter as it causes edge artifacts

lines 37-39

      %%% VK170908A %%%
% voxel(1,:)=medfilt1(voxel(1,:),14);
% voxel(2,:)=medfilt1(voxel(2,:),14);
% voxel(3,:)=medfilt1(voxel(3,:),14);
  %%% VK170908A %%%
lines 188-190

  %%% VK170908A %%%
  % voxel(1,:)=medfilt1(voxel(1,:),14);
  % voxel(2,:)=medfilt1(voxel(2,:),14);
  % voxel(3,:)=medfilt1(voxel(3,:),14);
  %%% VK170908A %%%
lines 215-217
  %%% VK170908A %%%
  % voxel(1,:)=medfilt1(voxel(1,:),20);
  % voxel(2,:)=medfilt1(voxel(2,:),20);
  % voxel(3,:)=medfilt1(voxel(3,:),20);
  %%% VK170908A %%%
