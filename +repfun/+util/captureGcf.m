function value = captureGcf(method, fileType)
% This allows capture a movie from the current figure
%
% Args:
%     method (string) : One of the following:
%         'clear' : empties the register
%         'captureFrame' : captures the current frame
%         'nbFrames' : returns the number of frames captured
%         'save' : save captured frame to a file
%     option (string, optional) : Video type when saving, one of the following:
%         'gif' : Graphics Interchange Format
%         'mp4' : MPEG-4
%         'both' : save into both gif and mp4 files

    if nargin < 2
        fileType = 'both';
    end
    
    persistent capture
    if isempty(capture)
        capture = repfun.Capture;
    end
    
    switch method
        case 'clear'
            capture = repfun.Capture;            
        case 'captureFrame'
            capture = capture.captureFrame;
        case 'nbFrames'
            value = length(capture.frames);
        case 'save'
            capture.saveVideo(fileType);
        otherwise
            error('Wrong argument');
    end
end
