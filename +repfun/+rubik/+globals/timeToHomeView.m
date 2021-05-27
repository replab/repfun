function value = timeToHomeView(newValue)
% Get/set the time taken to restore the initial point of view
    persistent storedValue
    if nargin == 1
        storedValue = newValue;
    end
    if isempty(storedValue)
        storedValue = 2; % 2 sec
    end
    value = storedValue;
end
