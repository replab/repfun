function value = defaultView(newValue)
% Get/set the default viewing angle
    persistent storedValue
    if nargin == 1
        assert(isequal(size(newValue), [1 2]), 'Wrong dimension');
        storedValue = newValue;
    end
    if isempty(storedValue)
        storedValue = [115 25];
    end
    value = storedValue;
end
