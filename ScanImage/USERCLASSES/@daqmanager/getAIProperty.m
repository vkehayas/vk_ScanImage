%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Call-through to get properties on analogoutput objects.
%%
%%  PROPERTY_VALUE = getAIProperty(OBJ, boardId, 'PROPERTY_NAME')
%%  PROPERTY_VALUE = getAIProperty(OBJ, channelName, 'PROPERTY_NAME')
%%
%%  Works like the standard 'get' function, except it takes a boardId as well as an object
%%  as the first arguments.
%%
%%  Created - Tim O'Connor 11/6/03
%%
%%  Changed:
%%   TO062405C: Check the running board value first. -- Tim O'Connor 6/24/05
%%   TO062405C: Special case for 'Running'. -- Tim O'Connor 6/24/05
%%   TO010606D: Special case for 'TriggersExecuted'. -- Tim O'Connor 1/6/06
%%   TO062306C: Documentation updated (added the channelName syntax), as suggested by Vijay Iyer. -- Tim O'Connor 6/23/06
%%
%%  Copyright - Howard Hughes Medical Institute/Cold Spring Harbor Laboratories 2003
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function property = getAIProperty(dm, identifier, propertyName)

%Check the args.
if nargin ~= 3
    error('Wrong number of arguments.');
end

%Talk directly to the AI object.
ai = getAI(dm, identifier);
if isempty(ai)
    if isnumeric(identifier)
        identifier = num2str(identifier);
    end
    error(sprintf('No analog input found with identifier: %s', identifier));
end
property = get(ai, propertyName);

%TO062405D, TO010606D
if any(strcmpi(propertyName, {'Running', 'TriggersExecuted'}))
    return;
end

%TO062405C
if strcmpi(get(ai, 'Running'), 'On')
    return;
end

if ~isnumeric(identifier)
    %Look up the aiProps for the channel.
    property = takeAIProperty(dm, identifier, propertyName);
    if ~isempty(property)
        %This overrides whatever the analog output is currently set to.
        return;
    end
end

return;