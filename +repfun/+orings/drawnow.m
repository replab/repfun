function drawnow
% Refreshes the plot after drawing

    axis equal;
    axis off;
    axis([0 91 0 42]);
    drawnow;
    if repfun.globals.capturing
        repfun.util.captureGcf('captureFrame');
        repfun.globals.clock('tick');
    end
end
