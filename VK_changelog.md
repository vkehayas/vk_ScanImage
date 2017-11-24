**annotationCorrelator.m**
```diff
line 501
-oldDist = pdist(oldCoords);
+oldDist = dist(oldCoords); % EDIT VK, 21/03/2014

line 561
-oldDist = pdist(oldCoords);
+oldDist = dist(oldCoords); % EDIT VK, 28/03/2014

line 826
-newAnnotations(i).correlationID = ia_getNewCorrelationID;
+newAnnotations(i).correlationID = ia_getNewCorrelationId;   % EDIT VK: 25/11/2014

line 976
-newAnnotations(i).correlationID = ia_getNewCorrelationID;
+newAnnotations(i).correlationID = ia_getNewCorrelationId;
```

**ia_annotate.m**
```diff
line 55
-annotations(index).correlationID = ia_getNewCorrelationId;
+annotations(index).correlationID = ia_getNewCorrelationId; % EDIT VK, 28/03/2014
```
**stackBrowser.m** (button remapping)
lines 1884-1974
```matlab
case 65
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
annotate_Callback(hObject);
```

**stackBrowswerControl.m**
```diff
line 112
-'defaultFilter', 'median', 'Class', 'char', 'Gui', 'defaultFilter', ...
+'defaultFilter', 'none', 'Class', 'char', 'Gui', 'defaultFilter', ...

line 133
-setLocal(progmanager, hObject, 'defaultFilter', 'median');
+setLocal(progmanager, hObject, 'defaultFilter', 'none');
```

**ia_updatePhotometryValues.m,**
```diff
VK140929A:  line 192
Rename variable `integral` to `integralValues`, due to conflict with built-in function `integral`

Modernized code, renamed loop indicator `i` to `iBounds` [loop starting at line 105, `for iBounds = 2:length(x)`]

VK140929D: line 146, line 149
Swapped `mean` and `median` between those two lines to match GUI options. `median` (thought to be ‘mean') is still broken (it saturates at $655$) but `mean` is producing the correct values.

VK140930A: line 194
+integralAboveBackground = integralRegion(integralRegion > background) - background;

line 198
-numel(integralRegion)
+numel(integralAboveBackground)

line 209
-calculated = (integral - background * prod(size(integralRegion))) / (normalizationFactor - background);%TO091707A
+calculated = integralValue ./ (normalizationFactor - background); %VK140930 Background subtraction was removed as now only values above threshold are integrated (see line 195)
```

**ia_updatePhotometryFromAnnotation**
```diff
VK140929C: line 31, line 52
Set default ’normalizationMethod’ to 1 (=mean)
```
**stackBrowser.m**
```diff
VK170906A
line 78-79 (Replace hard-coded limits)
-if getLocal(progmanager, hObject, 'whiteValue') > 3000
-setLocal(progmanager, hObject, 'whiteValue', 3000);
+if getLocal(progmanager, hObject, 'whiteValue') > 65000
+setLocal(progmanager, hObject, 'whiteValue', 65000);

-if getLocal(progmanager, hObject, 'blackValue') > 2999
-setLocal(progmanager, hObject, 'blackValue', 2999);
+if getLocal(progmanager, hObject, 'blackValue') > 64999
+setLocal(progmanager, hObject, 'blackValue', 64999);

VK170906B: line 477-478
Replace permitted range:
-'whiteValue', 200, 'Class', 'Numeric', 'Min' 0, 'Max', 2000, 'Gui', 'whiteValueSlider', 'Gui', 'whiteValueText', ...
-'blackValue', 0, 'Class', 'Numeric', 'Min' 0, 'Max', 2000, 'Gui', 'blackValueSlider', 'Gui', 'blackValueText', ...
+'whiteValue', 2000, 'Class', 'Numeric', 'Min' 1, 'Max', 65000, 'Gui', 'whiteValueSlider', 'Gui', 'whiteValueText', ...
+'blackValue', 0, 'Class', 'Numeric', 'Min' 0, 'Max', 64999, 'Gui', 'blackValueSlider', 'Gui', 'blackValueText', ...
```

**shiftDendriteMax.m**
```diff
VK170908A:
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
```
