function value = lastKeyPressed(figNumber, method, key)
% This allows to access the last key pressed in a given figure
%
% Note: For this function to be useful, it should be assigned at the
% creation of the figure as shown in the example below.
%
% Args:
%     figNumber (integer) : the figure number
%     method (string) : One of the following:
%         'clear' : empties the register
%         'set' : set the register to the provided keystroke
%         'get' : returns the last recorded keystroke and clears the
%             register
%     key (char, optional) : the character to be recorded when using the
%         'set' method
%
% Example:
%     >>> h = figure(fig);
%     >>> set(h, 'keypressfcn', @(E,F) evalin('base', ['repfun.util.lastKeyPressed(', num2str(fig), ', ''set'', ''', F.Key, ''');']));
%     >>> repfun.util.lastKeyPressed(fig, 'clear')
%     >>> pause(10) % type a character in the figure
%     >>> repfun.util.lastKeyPressed(fig, 'get')

    persistent storedValue
    if isempty(storedValue)
        storedValue = {};
    end
    if length(storedValue) < figNumber
        storedValue{figNumber} = '';
    end
    
    switch method
        case 'clear'
            storedValue{figNumber} = '';
        case 'set'
            storedValue{figNumber} = key;
        case 'get'
            value = storedValue{figNumber};
            storedValue{figNumber} = '';
        otherwise
            error('Wrong argument');
    end
end
