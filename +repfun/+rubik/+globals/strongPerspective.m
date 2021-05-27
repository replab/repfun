function value = strongPerspective(newValue)
% Get/set whether to increase the perspective effect or not (octave has no
% perspective effect)

    persistent storedValue
    if nargin == 1
        storedValue = newValue;
    end
    if isempty(storedValue)
        storedValue = false;
    end
    value = storedValue;
end
