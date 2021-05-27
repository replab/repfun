function value = clock(method)
% This gives the time in a controlled manner
%
% Same as matlab's clock function, except that when
% repfun.globals.capturing is true, the time is incremented through manual
% 'ticks'.
%
% Args:
%     method (string) : One of the following:
%         'init' : resets the time to wall clock
%         'tick' : increments the clock
%         'get' : returns the clock (default)
%
% Example:
%     >>> repfun.globals.clock

    persistent myClock
    if isempty(myClock)
        myClock = clock;
    end
    
    if nargin < 1
        method = 'get';
    end
    
    switch method
        case 'init'
            myClock = clock;
        case 'tick'
            myClock(end) = myClock(end) + 1/repfun.globals.framesPerSecond;
        case 'get'
            if repfun.globals.capturing
                value = myClock;
            else
                value = clock;
            end
        otherwise
            error('Wrong argument');
    end
end
