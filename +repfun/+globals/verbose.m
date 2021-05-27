function value = verbose(newValue)
% Get/set the verbose level
    persistent storedValue
    if nargin == 1
        storedValue = newValue;
    end
    if isempty(storedValue)
        storedValue = 1;
    end
    value = storedValue;
end
