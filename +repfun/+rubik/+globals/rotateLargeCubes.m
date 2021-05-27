function value = rotateLargeCubes(newValue)
% Get/set whether we want to rotate large cubes or not (nice for video, not
% for interactive mode)

    persistent storedValue
    if nargin == 1
        storedValue = newValue;
    end
    if isempty(storedValue)
        storedValue = false;
    end
    value = storedValue;
end
