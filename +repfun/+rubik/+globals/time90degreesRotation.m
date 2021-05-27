function value = time90degreesRotation(newValue)
% Get/set the time to take to in rendering mode
    persistent storedValue
    if nargin == 1
        storedValue = newValue;
    end
    if isempty(storedValue)
        storedValue = 0.3333; % 10/30 sec
    end
    value = storedValue;
end
