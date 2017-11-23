function updateHeaderForAcquisition
% Function to update header values, which will be stored in upcoming acquisition files, to match current state
%% NOTES
%   This version was rewritten from scratch. To see earlier versions of this function, see updateHeaderForAcquisition.mold -- Vijay Iyer 3/15/09
%% CREDITS
%   Created 3/15/09, by Vijay Iyer
%% *********************************************************
global state

processStateField('state');

    function processStateField(stateField)
        fNames = fieldnames(eval(stateField));  
        for i=1:length(fNames)
            fieldName = [stateField '.' fNames{i}];
            if isstruct(eval(fieldName))
                processStateField(fieldName);
            else %current field is a variable
                if any(bitand(getGlobalConfigStatus(fieldName),2))
                    processStateVar(fieldName);
                end
            end
        end   
    end

    function processStateVar(stateVar)
        %Determine if variable is already in the header string
        pos=findstr(state.headerString, [stateVar '=']);

        %Convert variable value into a string
        val = stateVar2String(stateVar);

        %Append string to header string
        if length(pos)==0 %Variable not already in header string; just add it!
            state.headerString=[state.headerString stateVar '=' val 13];
        else
            cr=findstr(state.headerString, 13);
            next=cr(find(cr>pos,1));
            if length(next)==0 %at end of header string
                state.headerString=[state.headerString(1:pos-1) stateVar '=' val 13];
            else %in middle of header string
                state.headerString=[state.headerString(1:pos-1) stateVar '=' val state.headerString(next:end)];
            end
        end

    end

end



