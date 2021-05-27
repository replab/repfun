function value = parallelization(newValue)
% Get/set whether to use parallel for loops or not
    persistent storedValue
    if nargin == 1
        storedValue = newValue;
    end
    if isempty(storedValue)
        storedValue = true;
    end
    value = storedValue;
end
