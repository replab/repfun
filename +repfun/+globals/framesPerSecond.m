function value = framesPerSecond(newValue)
% Get/set the number of frames per second for video rendering
    persistent storedValue
    if nargin == 1
        storedValue = newValue;
    end
    if isempty(storedValue)
        storedValue = 30;
    end
    value = storedValue;
end
