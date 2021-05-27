function set3DView(view, d)
% This function sets a nice view on the region [-d/2, d/2]^3
%
% Only use this function when something new has been plotted (after a hold
% off command)

if nargin >= 2
    axis([-1 1 -1 1 -1 1]*d/sqrt(2))
end
set(gca, 'View', view, 'Projection', 'perspective')
if repfun.rubik.globals.strongPerspective && ...
        ((get(gca, 'CameraViewAngle') ~= 20) || (norm(get(gca, 'CameraPosition')) >= 5*d))
    set(gca, 'CameraViewAngle', 20)
    set(gca, 'CameraPosition', get(gca, 'CameraPosition')/2.5);
end
if ~repfun.rubik.globals.strongPerspective
    set(gca, 'CameraViewAngle', 10);
end
axis off
axis square
hold off
drawnow

if repfun.globals.capturing
    repfun.util.captureGcf('captureFrame');
    repfun.globals.clock('tick');
end
