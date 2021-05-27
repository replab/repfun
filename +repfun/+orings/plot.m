function [state, sequence] = plot(state, generators, sequence)
% This function plots the olympic rings in a given state
%
% Args:
%     state ((1,\*) integer) : the state of the rings
%     moves ((2,\*) integer, optional) : the rotations to be applied
%     generators (cell array) : the generators of the 

clf;
set(gcf, 'color', [1 1 1]);

% Plots the rings
repfun.orings.drawCircle(state, 1);
repfun.orings.drawCircle(state, 2, 0, [0 0]);
repfun.orings.drawCircle(state, 3);
repfun.orings.drawCircle(state, 4, 0, [0 0]);
repfun.orings.drawCircle(state, 5);
repfun.orings.drawnow;

if (nargin < 2) || isempty(sequence)
    return;
end

moves = repfun.orings.sequencetoMove(sequence);

initClock = repfun.globals.clock;
time = @() etime(repfun.globals.clock, initClock);


% We also keep track of the cursors
handlesState = [-1 1 -1 1 -1]*pi/2;


% We solve the various rings concurrently
position = 1;
done = zeros(1, length(sequence));
rotating = zeros(1,5);
rotMoves = zeros(1,5);
rotPositions = cell(1,5);
notRotatingBefore = ones(1,5);
pbar = replab.infra.repl.ProgressBar(numel(sequence));
previousPosition = 0;
while position <= length(sequence)
    [rotating, rotMoves, rotPositions] = getNewRotation(moves, done, position, rotating, rotMoves, rotPositions);
    [rotating, finished] = applyRotation(state, rotating, rotMoves, rotating & notRotatingBefore, time, handlesState);
    notRotatingBefore = ~rotating;
    
    % Take into account finished rotations
    for i = 1:5
        if finished(i) == 1
            if rotMoves(i) ~= 0
                state = state(generators{i, mod(rotMoves(i), 33)});
                handlesState(i) = mod(handlesState(i) + rotMoves(i)/33*2*pi, 2*pi);
            end
            done(rotPositions{i}) = 1;
            rotMoves(i) = 0;
            rotPositions{i} = [];
        end
    end
    % Move the cursor
    while (position <= length(sequence)) && (done(position) == 1)
        position = position + 1;
    end
    
    % We check if the user wants to interrupt the process
    pause(0.00001);
    if isequal(upper(repfun.util.lastKeyPressed(get(gcf,'Number'), 'get')), 'I')
        % We stop here
        sequence = sequence(done == 0);
        break;
    end

    if (position > previousPosition) && (position <= length(sequence))
        pbar.step(position, 'Solving the rings, press ''I'' to interrupt');
        previousPosition = position;
    end
end
pbar.finish();


% % We do one move after the other one
% for i = 1:length(sequence)
%     state = rotateOneByOne(state, moves(:,i), generators, time);
% end

end



function [rotating, finished] = applyRotation(state, rotating, rotMoves, newlyRotating, timeFunction, handlesState)
% Applies or continues to apply the prescribed rotations to the rings.
%
% Args:
%     state ((1,\*) integer) : the state of the rings
%     rotation (1,\*) : 1 for rings which are currently being rotated
%     rotMoves (1,5) : the overall rotation angle to apply to each rotating
%         ring
%     newlyRotating (1,5) : whether we start a rotation on the given circle
%     timeFunction : function returning the absolute current proper time
%     cursorState : the state of the cursors if we want to plot them
%
% Returns:
% --------
%     rotation (1,\*) : 1 for rings whose rotation is not finised
%     finished (1,\*) : 1 for rings which were rotating and whose rotation
%         is now finished

    % We remember when each rotation started
    persistent startTimes
    
    if isempty(startTimes)
        startTimes = zeros(1,5);
    end

    % Are we starting to rotate a new circle?
    for i = 1:5
        if newlyRotating(i) == 1
            startTimes(i) = timeFunction();
        end
    end
    
    finished = zeros(1,5);
    angles = zeros(1,5);
    
    % Compute the rotation angles
    time = timeFunction();
    for i = 1:5
        if rotating(i) == 1
            deltaT = time - startTimes(i);
            fullTime = sqrt(abs(rotMoves(i))/15.5)*repfun.orings.globals.timePiRotation;
            if deltaT < fullTime
                angles(i) = (1-cos(deltaT/fullTime*pi))/2*rotMoves(i)*2*pi/33;
            else
                % The rotation is now finished on this ring
                angles(i) = rotMoves(i)*2*pi/33;
                rotating(i) = 0;
                finished(i) = 1;
            end
        end
    end
    
    % Draw the circles
    clf;
    for i = 1:5
        isTurning = (angles ~= 0);
        leftIsTurning = (i > 1) && isTurning(i-1);
        rightIsTurning = (i < 5) && isTurning(i+1);

        displayLeft = isTurning(i);
        displayRight = isTurning(i) || (~rightIsTurning);

        if nargin >= 6
            repfun.orings.drawCircle(state, i, angles(i), [displayLeft, displayRight], handlesState);
        else
            repfun.orings.drawCircle(state, i, angles(i), [displayLeft, displayRight]);
        end
    end
    repfun.orings.drawnow;
end


function [rotating, rotMoves, rotPositions] = getNewRotation(moves, done, position, rotating, rotMoves, rotPositions)
% returns the rings which can be rotated now, together with the associated
% overall moves and corresponding move positions
%
% Args:
%     moves (2,\*) : the chain of moves
%     done (integer) : moves which have been performed already
%     position (integer) : all moves before position are finished
%     rotating (1,\*) : 1 for rings which are currently being rotated
%     rotMoves (1,5) : the overall rotation angle currently happening for
%         each rotating rings
%     rotPositions (cell array) : elements of `moves` currently taken into
%         account by rotMoves
% 
% Returns:
% --------
%     rotating (1,\*) : 1 for rings which can be rotated in the current
%         step
%     rotMoves (1,5) : overall rotation to be performed on each ring
%     rotPositions (cell array) : position of the moves corresponding to
%         each non-zero element of rotating2

    % Identify rings which cannot be moved currently
    blocked = zeros(1,5);
    for i = 1:5
        if rotating(i) == 1
            blocked(i) = 1;
            if i > 1
                blocked(i-1) = 1;
            end
            if i < 5
                blocked(i+1) = 1;
            end
        end
    end
    
    % We check if any additional ring can be rotated, and extract the
    % corresponding rotation
    j = position;
    while (sum(blocked) ~= 5) && (j <= size(moves, 2))
        if done(j) == 0
            % Only check for new moves
            if blocked(moves(1,j)) == 0
                % We found another ring which can be rotated now. Let's take it
                % into account
                rotating(moves(1,j)) = 1;
                rotMoves(moves(1,j)) = mod(rotMoves(moves(1,j)) + moves(2,j), 33);
                if rotMoves(moves(1,j)) > 15
                    rotMoves(moves(1,j)) = rotMoves(moves(1,j)) - 33;
                end
                rotPositions{moves(1,j)} = [rotPositions{moves(1,j)}, j];
            end

            % Whether the current move can be performed or not, we can look
            % further only provided that the upcoming moves commute with this
            % one too.
            if moves(1,j) > 1
                blocked(moves(1,j)-1) = 1;
            end
            if moves(1,j) < 5
                blocked(moves(1,j)+1) = 1;
            end
        end
        
        j = j + 1;
    end
    
%    rotating
%    rotMoves
%    moves(:,position+[0:10])
end


function state = rotateOneByOne(state, move, generators, timeFunction)
% Applies exactly one move
    
    angles = zeros(1,5);
    
    t0 = timeFunction();
    deltaT = 0;
    fullTime = sqrt(abs(move(2,1))/15.5)*repfun.orings.globals.timePiRotation;
    
    while deltaT < fullTime
        angles(move(1,1)) = (1-cos(deltaT/fullTime*pi))/2*move(2,1)*2*pi/33;
        
        clf;
        for i = 1:5
            isTurning = (angles ~= 0);
            leftIsTurning = (i > 1) && isTurning(i-1);
            rightIsTurning = (i < 5) && isTurning(i+1);
            
            displayLeft = isTurning(i);
            displayRight = isTurning(i) || (~rightIsTurning);
            
            repfun.orings.drawCircle(state, i, angles(i), [displayLeft, displayRight]);
        end
        repfun.orings.drawnow;
        
        deltaT = timeFunction()-t0;
    end
    
    state = state(generators{move(1,1), mod(move(2,1)-1, 33)+1});
end

