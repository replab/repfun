function newView = rotatedView(reinit, period)
% This function returns the view that should be used now on the figure if
% we want to perform a full rotation around the object in the given period.
%
% Args:
%     reinit (bool, optional)
%     period (double, optional) : Period of the full rotation in second
%
% Returns:
% --------
%     newView (1,\*) : the view to be used for the desired followed rotation
%
% Examples:
%     >>> rotatedView(true)  % starts the rotation from the current viewing
%                              angle
%     >>> view = rotatedView % returns the view to be used to follow the
%                              desired rotation

persistent previousClock previousView

if nargin < 1
    reinit = false;
end

if nargin < 2
    period = repfun.rubik.globals.timeFullRotation;
end


if isempty(previousClock) || reinit
    previousClock = repfun.globals.clock;
    previousView = get(gca, 'view');
    newView = previousView;
    return;
end

% For a moving camera, we add an azimut angle that turns around the object
% in the required period

% estimate rotation angle since last call

% elapsed time
newClock = repfun.globals.clock;
deltaT = etime(newClock, previousClock);
previousClock = newClock; % for next time

% rotation angle
deltaAz = deltaT/period*360;
newView = previousView + [deltaAz, 0];
previousView = newView;
