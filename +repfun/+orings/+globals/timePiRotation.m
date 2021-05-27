function value = timePiRotation(newValue)
% Get/set the duration of a 180 degrees circle rotation

    persistent storedValue
    if nargin == 1
        storedValue = newValue;
    end
    if isempty(storedValue)
        storedValue = 5; % 5s
    end
    value = storedValue;
end
