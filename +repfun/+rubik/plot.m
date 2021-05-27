function [state, nbMovesPerformed] = plot(state, generators, moves, sequence, movingView)
% Plots a Rubik's cube
%
% Plots the cube-state. Can also be used to plot the move itself
% (animation) by passing a move as second parameter.
%
% Args:
%     state (1, \*) : The colors of each facet of the cube 
%     darkMode (bool, optional) : dark mode toggle
%     generators (cell array, optional) : generators
%     moves (cell array, optional) : text description of the move
%         corresponding to each generator
%     sequence (1, \*) integer, optional : the sequence of generators (or
%         inverses) to be applied to the cube
%     movingView (bool, optional) : whether to rotate the cube while
%         solving it
%
% Returns:
% --------
%     state (1, \*)
%         final state
%     nbMovesPerformed (integer
%         number of moves performed
%
% Examples:
%     repfun.rubik.plot(state); will just plot 
%     repfun.rubik.plot(state, false, generators, moves, sequence); plots 
%         the cube in light mode and applies the sequence of moves

% Based on Joren Heit's rubplot.m

    d = sqrt(numel(state)/6);
    R = repfun.rubik.state2tables(state);
    
    if (nargin < 5)
        movingView = (d <= 3) || repfun.rubik.globals.rotateLargeCubes;
    end
    
    nonEmptySequence = (nargin >= 4) && (numel(sequence) > 0);
    movingView = movingView && nonEmptySequence;
    if nargin > 4
        nbMovesPerformed = numel(sequence);
    else
        nbMovesPerformed = 0;
    end
    if nonEmptySequence && (numel(sequence) > 1)
        % If several moves to be applied
                
        % Starts the cube rotation from current view angle
        initView = get(gca, 'View');
        if movingView
            repfun.rubik.rotatedView(true);
        end
        
        % Perform the moves
        pbar = replab.infra.repl.ProgressBar(numel(sequence));
        for i = 1:numel(sequence)
            state = repfun.rubik.plot(state, generators, moves, sequence(i), movingView);
            nbMovesPerformed = i;

            % We check if the user wants to interrupt the process
            pause(0.00001);
            if isequal(upper(repfun.util.lastKeyPressed(get(gcf,'Number'), 'get')), 'I')
                % We stop here
                break;
            end
            
            pbar.stepNoTimeEstimation(i, 'Solving the cube, press ''I'' to interrupt');
        end
        pbar.finish;
        
        % Bring the cube back to its original rotation angle
        if movingView || (nbMovesPerformed == numel(sequence))
            if repfun.globals.capturing
                % Choose the rotation closest to 360 degrees to see all
                % faces
                targetAzs = initView(1) + 90*[0 1 2 3];
                currentView = get(gca, 'View');
                [~, I] = sort(mod(targetAzs - currentView(1), 360));
                targetView = [targetAzs(I(end)) initView(2)];
            else
                targetView = initView;
            end
            repfun.rubik.rotateToView(d, targetView, repfun.rubik.globals.timeToHomeView, repfun.rubik.globals.timeFullRotation);
        end
        return
    end  

    if movingView
        % Moving view
        view = repfun.rubik.rotatedView;
    else
        % Static view
        view = get(gca, 'View');
    end
    
    if ~repfun.rubik.globals.darkMode
        map =   [183  18  32;...          % red
                 254 213  47;...          % yellow
                  13  72 172;...          % blue    
                 250 250 250;...          % white
                  25 155  76;...          % green
                 255  85  37;...          % orange  
                 100 100 100;...          % dark gray
                 190 190 190]/255;        % gray
        backgroundColor = [240 240 240]/255;
        insideColor = [0 0 0]/255;
        borderColor = [0 0 0]/255;
    else
        map =   [186  24  42;...          % red
                 226 187  18;...          % yellow
                  16  37 125;...          % blue
                   8   5   5;...          % black
                  15 126  73;...          % green
                 216  97  28;...          % orange
                 100 100 100;...          % dark gray
                 190 190 190]/255;        % gray
        backgroundColor = [33 33 33]/255;
        insideColor = [8 5 5]/255;
        borderColor = [225 225 220]/255;
    end
    
    % Set background color
    set(gcf, 'color', backgroundColor);
    
    S = rubCoord(d);
    P = planesCoord(d);
    hold off
    for i=1:6
        for j = 1:d^2
            s = S(:,:,i);
            r = R(:,:,i);
            if r(j) > 0
                fill31(s{j}(:,1), s{j}(:,2), s{j}(:,3), map(r(j),:), borderColor);
            end
            hold on
        end
    end
    repfun.rubik.set3DView(view, d);
    
    if nonEmptySequence
        dir = moves{abs(sequence)}(1);
        rows = str2num(moves{abs(sequence)}(2:end-1)')';
        num = mod(sign(sequence)*str2double(moves{abs(sequence)}(end)),4);
        if num > 0
            C = rubRotCoord(d);

            % Correct the row numbers for axes x and y
            if (dir == 'x') || (dir == 'y')
                rows = sort(d + 1 - rows);
            end

            % This defines the rotation axis numerically
            dirI = double(dir)-119;

            angle = [pi/2 pi -pi/2];

            nbSteps = repfun.rubik.globals.nbSteps;
            step  = nbSteps(num);
            angle = angle(num)/step;   

            alpha = @(x, i, n) sum(x*step*sin([1:i]/(n+1)*pi)/cot(pi/(2*(n+1))));
            switch dir
                case 'x'
                    RM = @(x, i, n)([1 0 0; 0 cos(alpha(x,i,n)) -sin(alpha(x,i,n)); 0 sin(alpha(x,i,n)) cos(alpha(x,i,n))]);
                case 'y'
                    RM = @(x, i, n)([cos(alpha(x,i,n)) 0 sin(alpha(x,i,n)); 0 1 0; -sin(alpha(x,i,n)) 0 cos(alpha(x,i,n))]);
                case 'z'
                    RM = @(x, i, n)([cos(alpha(x,i,n)) -sin(alpha(x,i,n)) 0; sin(alpha(x,i,n)) cos(alpha(x,i,n)) 0; 0 0 1]);          
            end

            % HERE is where the rotation happens
            S0 = S;
            for frame = 1:step
                S = S0;
                for row = rows % We do it for all rows that need to be turned together
                    for i = 1:size(C{row,dirI},1)
                        face = double(C{row,dirI}(i,1))-64;
                        S1 = S(:,:,face);
                        n = str2double(C{row,dirI}(i,2));
                        switch C{row,dirI}(i,3)
                            case 'r'
                                for j = 1:d
                                    S1{n,j} = (RM(angle, frame, step)*S1{n,j}')';
                                end
                            case 'c'
                                for j = 1:d
                                    S1{j,n} = (RM(angle, frame, step)*S1{j,n}')';
                                end
                            case 'x'
                                for j = 1:d^2
                                    S1{j} = (RM(angle, frame, step)*S1{j}')';
                                end
                        end
                        S(:,:,face) = S1;
                    end  
                end
                
                % For all rows at the boundary, we also plot the sides of
                % the cubes that may become visible
                hold off
                for row = 1:d-1
                    if (any(rows == row) && all(rows ~= row+1)) || ...
                         (all(rows ~= row) && any(rows == row+1))
                        fill31NoEdge(P{row, dirI}(:,1), P{row, dirI}(:,2), P{row,dirI}(:,3), insideColor);
                        hold on;
                        % We also rotate this plane
                        P2 = (RM(angle, frame, step)*P{row, dirI}')';
                        fill31NoEdge(P2(:,1), P2(:,2), P2(:,3), insideColor);
                    end
                end

                for i=1:6
                    for j = 1:d^2
                        s = S(:,:,i);
                        r = R(:,:,i);
                        fill31(s{j}(:,1), s{j}(:,2), s{j}(:,3), map(r(j),:), borderColor)
                        hold on
                    end
                end
                if movingView
                    repfun.rubik.set3DView(repfun.rubik.rotatedView, d);
                else
                    repfun.rubik.set3DView(view, d);
                end
            end
        end
        if nargout == 1
            if sequence > 0
                state = state(generators{abs(sequence)});
            else
                state(generators{abs(sequence)}) = state;
            end
        end
    end
end


function S = rubCoord(d)
% Returns the vertex coordinates of each patch that makes up the cube (in
% correct order to be compatible with the fill-function).

    isOctave = repfun.util.isOctave;

    S = cell(d,d,6);
    faces = 'ABCDEF';

    for i = 1:6  % for all faces
        s = S(:,:,i);
        c = zeros(4,3);
        face = faces(i);
        switch face
            case 'A'
                c(:,1) = d;
                for j = 1:d^2
                    s{j} = c;
                    if isOctave
                        s{j}(:,2) = [0 0 1 1] + (ceil(j/d)-1);
                        s{j}(:,3) = [d d-1 d d-1] - mod(j-1,d);
                    else
                        s{j}(:,2) = [0 0 1 1] + (ceil(j/d)-1);
                        s{j}(:,3) = [d d-1 d-1 d] - mod(j-1,d);
                    end
                    s{j} = s{j}-d/2;
                end
            case 'B'
                c(:,2) = d;
                for j = 1:d^2
                    s{j} = c;
                    if isOctave
                        s{j}(:,3) = [d d-1 d d-1] - mod(j-1,d);
                        s{j}(:,1) = [d d d-1 d-1] - (ceil(j/d)-1);
                    else
                        s{j}(:,3) = [d d-1 d-1 d] - mod(j-1,d);
                        s{j}(:,1) = [d d d-1 d-1] - (ceil(j/d)-1);
                    end
                    s{j} = s{j}-d/2;
                end 
            case 'C'
                c(:,1) = 0;
                for j = 1:d^2
                    s{j} = c;
                    if isOctave
                        s{j}(:,2) = [d d d-1 d-1] - (ceil(j/d)-1);
                        s{j}(:,3) = [d d-1 d d-1] - mod(j-1,d);
                    else
                        s{j}(:,2) = [d d d-1 d-1] - (ceil(j/d)-1);
                        s{j}(:,3) = [d d-1 d-1 d] - mod(j-1,d);
                    end
                    s{j} = s{j}-d/2;
                end
            case 'D'
                c(:,2) = 0;
                for j = 1:d^2
                    s{j} = c;
                    if isOctave
                        s{j}(:,3) = [d d-1 d d-1] - mod(j-1,d);
                        s{j}(:,1) = [0 0 1 1] + (ceil(j/d)-1);
                    else
                        s{j}(:,3) = [d d-1 d-1 d] - mod(j-1,d);
                        s{j}(:,1) = [0 0 1 1] + (ceil(j/d)-1);
                    end
                    s{j} = s{j}-d/2;
                end
            case 'E'
                c(:,3) = d;
                for j = 1:d^2
                    s{j} = c;
                    if isOctave
                        s{j}(:,2) = [0 0 1 1] + (ceil(j/d)-1);
                        s{j}(:,1) = [0 1 0 1] + mod(j-1,d);
                    else
                        s{j}(:,2) = [0 0 1 1] + (ceil(j/d)-1);
                        s{j}(:,1) = [0 1 1 0] + mod(j-1,d);
                    end
                    s{j} = s{j}-d/2;
                end
            case 'F'
                c(:,3) = 0;
                for j = 1:d^2
                    s{j} = c;
                    if isOctave
                        s{j}(:,2) = [0 0 1 1] + (ceil(j/d)-1);
                        s{j}(:,1) = [d d-1 d d-1] - mod(j-1,d);
                    else
                        s{j}(:,2) = [0 0 1 1] + (ceil(j/d)-1);
                        s{j}(:,1) = [d d-1 d-1 d] - mod(j-1,d);
                    end
                    s{j} = s{j}-d/2;
                end
        end
        S(:,:,i) = s;
    end
end

function S = planesCoord(d)
% Returns the vertex coordinates of plane that cuts the cube (in correct
% order to be compatible with the fill-function).

    isOctave = repfun.util.isOctave;

    S = cell(d-1,3);
    directions = 'XYZ';

    for i = 1:3  % for all faces
        face = directions(i);
        switch face
            case 'X'
                for j = 1:d-1
                    c = zeros(4,3);
                    c(:,1) = j;
                    if isOctave
                        c(:,2) = [0 0 d d];
                        c(:,3) = [d 0 d 0];
                    else
                        c(:,2) = [0 0 d d];
                        c(:,3) = [d 0 0 d];
                    end
                    S{j,i} = (c-d/2);
                end
            case 'Y'
                for j = 1:d-1
                    c = zeros(4,3);
                    c(:,2) = j;
                    if isOctave
                        c(:,3) = [d 0 d 0];
                        c(:,1) = [d d 0 0];
                    else
                        c(:,3) = [d 0 0 d];
                        c(:,1) = [d d 0 0];
                    end
                    S{j,i} = (c-d/2);
                end 
            case 'Z'
                for j = 1:d-1
                    c = zeros(4,3);
                    c(:,3) = d-j;
                    if isOctave
                        c(:,1) = [d d 0 0];
                        c(:,2) = [d 0 d 0];
                    else
                        c(:,1) = [d d 0 0];
                        c(:,2) = [d 0 0 d];
                    end
                    S{j,i} = (c-d/2);
                end
        end
    end
end

function C = rubRotCoord(d)
% Returns information about which of the coordinates are subject to the
% rotation and thus have to be subjected to the rotation matrices.

    C = cell(d,3);
    d = num2str(d);
    C{1,1}   = ['Cxx';['B' d 'c'];'D1c';'E1r';['F' d 'r']];
    C{1,2}   = ['Dxx';'A1c';['C' d 'c'];'E1c';'F1c'];
    C{1,3}   = ['Exx';'A1r';'B1r';'C1r';'D1r'];
    C{end,1} = ['Axx';'B1c';['D' d 'c'];['E' d 'r'];'F1r'];
    C{end,2} = ['Bxx';['A' d 'c'];'C1c';['E' d 'c'];['F' d 'c']];
    C{end,3} = ['Fxx';['A' d 'r'];['B' d 'r'];['C' d 'r'];['D' d 'r']];

    d = str2double(d);
    for i = 2:d-1
        x1 = num2str(i);
        x2 = num2str(d-(i-1));
        C{i,1} = [['B' x2 'c'];['D' x1 'c'];['E' x1 'r'];['F' x2 'r']];
        C{i,2} = [['A' x1 'c'];['C' x2 'c'];['E' x1 'c'];['F' x1 'c']];
        C{i,3} = [['A' x1 'r'];['B' x1 'r'];['C' x1 'r'];['D' x1 'r']];
    end

    if d==1
        C{1,1} = [C{1,1};'Cxx'];
        C{1,2} = [C{1,2};'Dxx'];
        C{1,3} = [C{1,3};'Exx'];
    end
end

function fill31(X, Y, Z, C, lineColor)
% draw a square in 3D

    if repfun.util.isOctave
        % Use mesh for Octave...
        mesh(reshape(X,2,2), reshape(Y,2,2), reshape(Z,2,2), 'EdgeColor', 'k', 'FaceColor', C)
    else
        fill3(X, Y, Z, C, 'LineWidth', 3, 'EdgeColor', lineColor);
    end
end

function fill31NoEdge(X, Y, Z, C)
% draw a square in 3D without edge

    if repfun.util.isOctave
        % Use mesh for Octave...
        mesh(reshape(X,2,2), reshape(Y,2,2), reshape(Z,2,2), 'EdgeColor', 'k', 'FaceColor', C, 'LineStyle', 'none')
    else
        fill3(X, Y, Z, C, 'LineStyle', 'none');
    end
end
