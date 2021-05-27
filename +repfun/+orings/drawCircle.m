function drawCircle(state, n, rotationAngle, partialPart, handlesState)
% This function draws the circle number n.
%
% Optionally, specify a rotation angle, and whether left and/or right
% overlapping parts of the circle  should be drawn.
%
% Args:
%     state ((1, \*) integer) : the state of the rings
%     n (integer) : the ring to draw
%     rotationAngle (double, optional) : the angle by which the ring is
%         rotated
%     partialPart ((1,\*) integer, optional) : whether to draw the left and
%         right-overlaping part of the circle
%     cursorState ((1,\*) double, optional) : the angles of the cursors, if
%         we want to show them

    persistent globalAngles
    if isempty(globalAngles)
        globalAngles = zeros(1, 5);
    end

    if nargin < 3
        rotationAngle = 0;
    end
    
    if nargin < 4
        % By default, plot the whole circle
        partialPart = [1 1];
    end
    

    %% Definitions
    colors =   [  0 129 200;...          % blue
                252 177  49;...          % yellow
                  0   0   0;...          % black
                  0 166  81;...          % green
                238  51  78]/255;        % red

    bigRadius = 13;
    smallRadius = 1.23;
    circle = @(xy, color) rectangle('Position', [xy-smallRadius [2 2]*smallRadius], ...
        'Curvature', [1 1], 'FaceColor', color, 'EdgeColor', 'none');
    %circle = @(xy, color) plot(xy(1), xy(2), 'o', 'MarkerEdgeColor', color, 'MarkerFaceColor', color, 'MarkerSize', 10);

    % Here are the centers of each circles
    centers = {[14.32, 27.68], ...
               [14.32 + 15.5, 27.68 - 13.36], ...
               [14.32 + 31, 27.68], ...
               [14.32 + 46.5, 27.68 - 13.36], ...
               [14.32 + 62, 27.68]};

    % Here are the indices of each circle, starting from the vertically
    % located element
    indices{1} = [25, 33, 26:31, 32, 1:24];
    indices{2} = [56, 32, 57:62, 33, 34:49, 64, 50:55, 63];
    indices{3} = [87, 95, 88:93, 94, 65:80, 63, 81:86, 64];
    indices{4} = [118, 94, 119:124, 95, 96:111, 126, 112:117, 125];
    indices{5} = [127:151, 125, 152:157, 126];

%     % We list the elements of the above indices which overlap several rings
%     overlap = zeros(5, 33);
%     overlap(1:4, [2, 9]) = 1;
%     overlap(2:5, [26, 33]) = 1;


    %% Drawing
    draw = ones(1,33);
    if (partialPart(1) == 0) && (n > 1)
        % We do not draw the left-overlapping part
        if mod(n, 2) == 1
            draw([26, 33]) = 0;
        else
            draw([2, 9]) = 0;
        end
    end
    if (partialPart(2) == 0) && (n < 5)
        % We do not draw the right-overlapping part
        if mod(n, 2) == 1
            draw([2, 9]) = 0;
        else
            draw([26, 33]) = 0;
        end
    end

    hold on;
    shift = pi/2*(-1)^mod(n, 2) + rotationAngle;
    for i = 1:length(indices{n})
        if draw(i) == 1
            phi = shift + (i-1)/length(indices{n})*2*pi;
            position = centers{n} + bigRadius*[cos(phi) sin(phi)];
            circle(position, colors(state(indices{n}(i)), :));
        end
    end
    hold off;
    
    if nargin >= 5
        % Also plot the cursor
        hold on;
        angleHandle = handlesState(n) + rotationAngle;
        if rotationAngle ~= 0
            % This circle is currently moving
            plot(centers{n}(1) + [-2 4]*cos(angleHandle), centers{n}(2) + [-2 4]*sin(angleHandle), 'LineWidth', 4);
        else
            % This circle is not currently moving
            plot(centers{n}(1) + [-2 4]*cos(angleHandle), centers{n}(2) + [-2 4]*sin(angleHandle), 'LineWidth', 2);
        end
        hold off;
    end
end
