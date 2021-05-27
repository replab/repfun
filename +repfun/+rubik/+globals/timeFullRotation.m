function value = timeFullRotation(newValue)
% Get/set the time taken to perform a full rotation of the view over the
% cube
    persistent storedValue
    if nargin == 1
        storedValue = newValue;
    end
    if isempty(storedValue)
        storedValue = 30; % 30 sec
    end
    value = storedValue;
end
