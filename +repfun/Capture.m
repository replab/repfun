classdef Capture
% Make a movie from figure captures

    properties (SetAccess = protected)
        frames % (\*,\*) : figure frames
    end
    
    methods
        
        function capture = Capture()
        % Constructs a movie
        % Args:
        %
        % Returns: Capture
            
        end
        
        function this = captureFrame(this)
        % Captures the current figure
        %
        % Returns: Capture
        %     new Capture object with one more frame
        
            if isempty(this.frames)
                this.frames = getframe(gcf);
            else
                this.frames(length(this.frames)+1) = getframe(gcf);
            end
        end

        function saveVideo(this, type)
        % Saves the frames captures into a file
        % 
        % Args:
        %     type (string) : can be one of the following:
        %         'gif' : a gif movie
        %         'mp4' : an mp4 movie
        
            if isempty(this.frames) || (numel(this.frames) <= 1)
                % Nothing to save
                return;
            end
            
            if nargin < 2
                type = 'both';
            end
            
            if repfun.util.isOctave
                % Only one format is supported on octave
                type = 'gif';
            end
            
            filename = datestr(now, 'yyyy-mm-ddTHH-MM-SS.FFF');
            if isequal(type, 'gif') || isequal(type, 'both')
                for i = 1:length(this.frames)
                    im = frame2im(this.frames(i));
                    if repfun.util.isOctave
                        [imind, cm] = rgb2ind(im);
                    else
                        [imind, cm] = rgb2ind(im, 256);
                    end
                    if i == 1
                        imwrite(imind, cm, [filename, '.gif'], 'gif', 'Loopcount', inf, 'DelayTime', 1);
                    elseif i == length(this.frames)
                        imwrite(imind, cm, [filename, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 1);
                    else
                        imwrite(imind, cm, [filename, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 1/repfun.globals.framesPerSecond);
                    end
                end
            end
            if isequal(type, 'mp4') || isequal(type, 'both')
                % open the video file
                writerObj = VideoWriter([filename, '.avi'], 'Uncompressed AVI');
                writerObj.FrameRate = repfun.globals.framesPerSecond;
                open(writerObj);

                % write the frames into the file
                for i = 1:repfun.globals.framesPerSecond
                    writeVideo(writerObj, this.frames(1));
                end
                for i = 2:length(this.frames)-1
                    writeVideo(writerObj, this.frames(i));
                end
                for i = 1:repfun.globals.framesPerSecond
                    writeVideo(writerObj, this.frames(end));
                end

                % close the file
                close(writerObj);

                % convert AVI to MP4, for this to work, you should have
                % installed ffmpeg and have it available on PATH
                if isunix
                    [a, ~] = system(['ffmpeg -i ', filename, '.avi -y -an -c:v libx264 -crf 15 -preset slow -profile:v high -vf "crop=trunc(iw/2)*2:trunc(ih/2)*2" -level 3.0 -pix_fmt yuv420p -brand mp42 ', filename, '.mp4']);
                    if a == 0
                        system(['rm ', filename, '.avi']);
                    else
                        warning('Error during the AVI to MP4 conversion, video kept in AVI format.')
                    end
                elseif ispc
                    [a, ~] = system(['ffmpeg.exe -i', filename, '.avi -y -an -c:v libx264 -crf 15 -preset slow -profile:v high -vf "crop=trunc(iw/2)*2:trunc(ih/2)*2" -level 3.0 -pix_fmt yuv420p -brand mp42 ', filename, '.mp4']);
                    if a == 0
                        system(['rm ', filename, '.avi']);
                    else
                        warning('Error during the AVI to MP4 conversion, video kept in AVI format')
                    end
                end
            end
            disp('Movie saved');
        end
        
    end
    
end
