function value = nbSteps(newValue)
% Get/set the number of steps to be computed when animating a rotation by
% pi/4, pi/2, -pi/4 degrees respectively.
    persistent storedValue
    if nargin == 1
        assert(isequal(size(newValue), [1 3]), 'Wrong dimension');
        storedValue = newValue;
    end
    if isempty(storedValue)
        storedValue = [4 7 4];
    end
    value = storedValue;
end
