function words2 = simplifySequence(d, words, moves)
% This function performs a simple simplification of a sequence of moves by
% concatenating successive moves performed along the same axis
%
% Note: Here we assume that the three possible angle of rotations are
% encoded as (-1, 3), (1, 2), (1, 3) respectively
%
% Args:
%     d (integer) : dimension
%     words (1,\*) integer : sequence of generator indices (negative for
%         inverses)
%     moves (cell array) : list of moves in text form corresponding to each
%         generator
%
% Returns: (1,\*) integer
%     a smaller sequence of generators

    persistent previousMoves movesProperties movesDecimalFast movesMapping one2d zeros1d

    if isempty(previousMoves) || isempty(movesProperties) || isempty(movesDecimalFast) || isempty(one2d) || ~isequal(previousMoves, moves)
        movesProperties = translateToProperties(moves);
        movesDecimalFast = translateToDecimalFast(movesProperties);
        one2d = num2str([1:d].').';
        zeros1d = zeros(1,d);

        % This allows to quickly find a generator from its description
        movesMapping = repfun.util.inversePerm(movesDecimalFast);

        previousMoves = moves;
    end

    words2 = 0*words;
    i = 1;
    i2 = 1;
    while i <= length(words)
        axis = moves{abs(words(i))}(1);
        axisD = double(axis)-119;
        j = i;
        while (j+1 <= length(words)) && (moves{abs(words(j+1))}(1) == axis)
            j = j + 1;
        end

        globalRotation = [];
        turned = [];

        if j == i
            % We have just one move along this axis. We check what is the most
            % compact way of encoding this rotation
            turning = movesProperties{abs(words(i))}{2};
            angle = mod(sign(words(i))*movesProperties{abs(words(i))}{3}, 4);
            isTurning = zeros1d;
            isTurning(turning) = 1;

            if (length(turning) > d/2) || ((length(turning) == d/2) && (isTurning(1) == 0) && (sum(abs(diff(isTurning))) == 2))
                % It would be nicer to extract a global rotation
                globalRotation = {axisD, 1:d, angle};

                % The remaining moves to be done
                turned = mod(-angle, 4)*ones(1,d);
                turned(turning) = 0;
            end
        elseif j > i
            % We have several successive moves along the same axis. We check
            % what is the most compact way of encoding this rotation
            turned = zeros1d;
            totalTurning = 0;
            nbFullRotations = 0;
            for k = i:j
                turning = movesProperties{abs(words(k))}{2};
                angle = sign(words(k))*movesProperties{abs(words(k))}{3};
                turned(turning) = mod(turned(turning) + angle, 4);
                totalTurning = totalTurning + sum(turning~=0);
                nbFullRotations = nbFullRotations + (length(turning) == d);
            end

            % Find the most used rotation angle
            nbT = [sum(turned==0), sum(turned==1), sum(turned==2), sum(turned==3)];

            % Evaluate the number of operations needed
            nbMovesNeeded = sum(nbT(2:end)~=0);

            % Note: full rotations don't count        
            if (nbT(1) ~= max(nbT)) ...
                    || (nbMovesNeeded < j-i+1-nbFullRotations) ...
                    || ((nbMovesNeeded == j-i+1-nbFullRotations) && (sum(turned~=0) < totalTurning - d*nbFullRotations))
                % We can simplify the move so we do it

                if nbT(1) ~= max(nbT)
                    % We extract a global rotation
                    shiftBy = find(nbT == max(nbT), 1)-1;
                    globalRotation = {axisD, 1:d, shiftBy};

                    % The remaining moves to be done
                    turned = mod(turned - shiftBy, 4);
                end
            else
                % Nothing to do
                turned = [];
            end
        end

        % We encode the result
        if ~isempty(globalRotation) || ~isempty(turned)
            if ~isempty(globalRotation)
                words2(i2) = rotation2move(globalRotation{1}, globalRotation{2}, globalRotation{3}, movesMapping);
                i2 = i2 + 1;
            end
            % We encode the remaining moves
            if any(turned == 1)
                words2(i2) = rotation2move(axisD, find(turned==1), 1, movesMapping);
                i2 = i2 + 1;
            end
            if any(turned == 2)
                words2(i2) = rotation2move(axisD, find(turned==2), 2, movesMapping);
                i2 = i2 + 1;
            end
            if any(turned == 3)
                words2(i2) = rotation2move(axisD, find(turned==3), 3, movesMapping);
                i2 = i2 + 1;
            end
        else
            % Nothing to simplify, we keep the same moves
            words2(i2+[0:j-i]) = words(i:j);
            i2 = i2 + j-i+1;
        end

        i = j+1;
    end
    words2 = words2(1:i2-1);
end


function movesDecimal = translateToProperties(moves)
% Encodes each move into a numeric cell array structure

    for i = 1:length(moves)
        switch moves{i}(1)
            case 'x'
                movesDecimal{i}{1} = 1;
            case 'y'
                movesDecimal{i}{1} = 2;
            case 'z'
                movesDecimal{i}{1} = 3;
        end
        movesDecimal{i}{2} = str2num(moves{i}(2:end-1).').';
        movesDecimal{i}{3} = str2num(moves{i}(end));
    end
end

function movesDecimalFast = translateToDecimalFast(movesDecimal)
% Assigns an integer to all moves

    movesDecimalFast = zeros(1, length(movesDecimal));
    for i = 1:length(movesDecimal)
        movesDecimalFast(i) = moveDecimal2Integer(movesDecimal{i}{1}, movesDecimal{i}{2}, movesDecimal{i}{3});
    end
end

function number = moveDecimal2Integer(axis, levels, angle)
% Assigns an integer to a move
%
% Note, in principle, the angle here should be only 2 or 3 (rotation by an
% angle of 1 is encoded as the inverse of a rotation of angle 3). But we
% tolerate it to be 1 too (for safety and efficiency purpose).

    number = sum(2.^(levels-1))*9 + (axis-1)*3 + (abs(angle-2)+2-1);
end

function newMove = rotation2move(axis, levels, angle, movesMapping)
% here, angle can be 1, 2 or 3

    moveNb = movesMapping(moveDecimal2Integer(axis, levels, angle));
    if moveNb ~= 0
        if angle == 1
            newMove = -moveNb;
        else
            newMove = moveNb;
        end
    else
        error(['Move {', num2str(axis), ', ', num2str(levels), ', ', num2str(angle), '} not found in the list of generators']);
    end
end


