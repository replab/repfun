function rotateToView(d, targetView, time, inMovingPeriod, outMovingPeriod)
% This function moves the view point from its current value to the target
% value in the requested time
%
% Note: if the target view equals the current view, a full azimutal
% rotation is performed.
%
% Args:
%     d (integer) : the dimension of the cube we are looking at
%     targetView ((1,2) double) : the final view
%     time (double, optional) : the time of the transformation in seconds
%     inMovingPeriod (double, optional) : the period (1/rotation speed) of
%         the current rotation
%     outMovingPeriod (double, optional) : the period (1/rotation speed) of
%         the upcoming rotation

if nargin < 3
    time = 2; % 2 sec
end

if (nargin < 4) || isempty(inMovingPeriod) || (inMovingPeriod == 0)
    inMovingPeriod = inf;
end

if (nargin < 5) || isempty(outMovingPeriod) || (outMovingPeriod == 0)
    outMovingPeriod = inf;
end

startView = get(gca, 'View');

if isequal(startView, targetView)
    % We set the cube in motion
    startView = startView + [0.001 0];
end

initClock = repfun.globals.clock;

fAz = f(360/inMovingPeriod, 360/outMovingPeriod, mod(targetView(1)-startView(1), 360), time);
fEl = f(0, 0, targetView(2)-startView(2), time);
%fEl1 = f(0, 0, -targetView(2)-startView(2), time/2);
%fEl2 = f(0, 0, 2*targetView(2), time/2);

t = 0;
while t < time
    newClock = repfun.globals.clock;
    t = etime(newClock, initClock);
    
%    if t <= time/2
%        fEl = fEl1;
%    else
%        fEl = @(t) -targetView(2)-startView(2) + fEl2(t-time/2);
%    end
    newView = startView + [fAz(t), fEl(t)];
    repfun.rubik.set3DView(newView, d);
%    set(gca, 'View', newView);
%    if repfun.rubik.globals.strongPerspective
%        set(gca, 'CameraViewAngle', 30)
%        set(gca, 'CameraPosition', get(gca, 'CameraPosition')/3);
%    end
%    drawnow;
end

% Set the final view
repfun.rubik.set3DView(targetView, d);
%set(gca, 'View', targetView);
%if repfun.rubik.globals.strongPerspective
%    set(gca, 'CameraViewAngle', 30)
%    set(gca, 'CameraPosition', get(gca, 'CameraPosition')/3);
%end

end


function func = f(omega0, omega1, alphaTot, tmax)
% This function gives a smooth evolution from 0 to alphaTot as a function
% of t in [0, tmax], with initial angular speed omega0, and final angular
% speed omega1
    func = @(t) -((2*omega0 + omega1)*t^2*tmax^2 - omega0*t*tmax^3 + 2*alphaTot*t^3 - ((omega0 + omega1)*t^3 + 3*alphaTot*t^2)*tmax)/tmax^3;
end
