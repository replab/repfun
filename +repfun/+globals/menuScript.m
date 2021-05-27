function value = menuScript(method, choices)
% This allows to program a set of instruction to be retreived by the Menu
% class.
%
% Args:
%     method (string) : One of the following:
%         'clear' : empties the list of programmed menu choices
%         'add' : add choices to the list of programmed commands
%         'get' : returns the next programmed choice (and removes it from
%             the list)
%     choices (string, optional) : Argument for the 'add' method
%
% Example:
%     >>> repfun.globals.menuScript('clear');
%     >>> repfun.globals.menuScript('add', 'd2htcqcscq'); % Produces a video of a random 2x2x2 cube being solved
%     >>> rubikSolver;

    persistent programmedChoices
    if isempty(programmedChoices)
        programmedChoices = '';
    end
    
    switch method
        case 'clear'
            programmedChoices = '';
        case 'add'
            programmedChoices = [programmedChoices choices];
        case 'get'
            if length(programmedChoices) >= 1
                value = programmedChoices(1);
                programmedChoices = programmedChoices(2:end);
            else
                value = '';
            end
        otherwise
            error('Wrong argument');
    end
end
