function stringVal = stateVar2String(stateVar)
%STATEVAR2STRING Convert a ScanImage state variable to a string
%
%% SYNTAX
%   stringVal = stateVar2String(stateVar)
%       stateVar: String containing name of a ScanImage state variable, in full structure format (e.g. 'state.acq.numPixels')
%       stringVal: String representing value of the input state variable
%
%% NOTES
%   Created to factor out common code used in CFG and Header saving
%   String value for variable is in a format that can be correctly parsed by initGUIsFromCellArray()
%
%% CREDITS
%   Created 3/15/09, by Vijay Iyer
%% ******************************************
global state

val=[];


if strfind(stateVar,'ArrayString') %%%%ArrayString values are due to be phased out...can now store arrays directly
    eval(['val= mat2str(' stateVar(1:end-6) ');']);
else
    eval(['val=' stateVar ';']);
end
%%%%%%%%%%%%%%%%%%%%%%%%

if iscell(val) %don't convert cell array vars
    stringVal = [];
elseif isnumeric(val)
    if ndims(val) > 2
        stringVal = ['''' ndArray2Str(val) '''']; %Use custom ndArray2Str() to deal with ND arrays; store as 'string string' to be loaded correctly by initGUIsFromCellArray()
    elseif isscalar(val) || isempty(val)
        stringVal = mat2str(val);
    else
        stringVal = ['''' mat2str(val) '''']; %Store 2D arrays as a 'string string' to be loaded correctly by initGUIsFromCellArray()
    end
else %should be a string...convert to a 'string string'
    stringVal = ['''' val ''''];
end