function sequence = removeFullRotations(sequence, moves)
% Here we analyse the provided sequence, move all full rotations of the
% cube to the end of the sequence and remove them
%
% Note: The provided sequence does not perform the same permutation, but
% only one identical up to solid rotations of the whole cube (i.e. it does
% preserves the property of a cube being solved)
%
% Args:
%     words (1,\*) integer : sequence of generator indices (negative for
%         inverses)
%     moves (cell array) : list of moves in text form corresponding to each
%         generator
%
% Returns: (1,\*) integer
%     a sequence of generators without full rotations

    persistent previousMoves commutatorNN commutatorCN commutatorNC commutatorCC

    % For debuggin purpose
    keepFullRotations = false;
    
    descriptionLength = cellfun(@(x) length(x), moves);
    d = max(descriptionLength)-2;
    fullGenerator = find(descriptionLength == max(descriptionLength));

    if isempty(previousMoves) || ~isequal(moves, previousMoves)
        % We compute the commutator matrix just once
        [commutatorNN, commutatorCN, commutatorNC, commutatorCC] = makeCommutatorMatrices(d, fullGenerator, moves);
        previousMoves = moves;
    end


    i = 0;
    nbFullRotationsFound = 0;
    while i < length(sequence)
        i = i + 1;
        if any(abs(sequence(i)) == fullGenerator)
            nbFullRotationsFound = nbFullRotationsFound + 1;
            % We commute all further moves with this global rotation
            globalRot = sequence(i);
            if globalRot > 0
                for j = i+1:length(sequence)
                    if sequence(j) > 0
                        sequence(j-1) = commutatorNN(abs(globalRot), abs(sequence(j)));
                    else
                        sequence(j-1) = commutatorNC(abs(globalRot), abs(sequence(j)));
                    end
                end
            else
                for j = i+1:length(sequence)
                    if sequence(j) > 0
                        sequence(j-1) = commutatorCN(abs(globalRot), abs(sequence(j)));
                    else
                        sequence(j-1) = commutatorCC(abs(globalRot), abs(sequence(j)));
                    end
                end
            end
            if keepFullRotations
                sequence(end) = globalRot;
                if i + nbFullRotationsFound >= length(sequence)
                    return;
                end
            else
                sequence = sequence(1:end-1);
            end
            i = i - 1;
        end
    end

end


function [commutatorNN, commutatorCN, commutatorNC, commutatorCC] = makeCommutatorMatrices(d, fullGenerator, moves)
    % Construct the opposite moves
    movesC = moves;
    for i = 1:length(moves)
        movesC{i} = [moves{i}(1:end-1), num2str(4-str2num(moves{i}(end)))];
    end
    
    % Identify full rotations
    commutatorNN = zeros(length(fullGenerator), length(moves));
    commutatorCN = zeros(length(fullGenerator), length(moves));
    commutatorNC = zeros(length(fullGenerator), length(moves));
    commutatorCC = zeros(length(fullGenerator), length(moves));
    for i = fullGenerator
        axis = moves{i}(1) - 119;
        angle = str2num(moves{i}(end));
        commutatorNN(i,:) = commut(d, axis, angle, moves, moves);
        commutatorCN(i,:) = commut(d, axis, 4-angle, moves, moves);
        commutatorNC(i,:) = commut(d, axis, angle, movesC, moves);
        commutatorCC(i,:) = commut(d, axis, 4-angle, movesC, moves);
    end
end

function commuted = commut(d, axis, angle, movesToEncode, moves)
% This function finds how all the moves commute with a global rotation
% of given angle around a given axis

    % We need to compute the commutator with all generators
    commuted = zeros(1, length(movesToEncode));
    for j = 1:length(movesToEncode)
        axis2 = movesToEncode{j}(1) - 119;
        levels = str2num(movesToEncode{j}(2:end-1).').';
        compLevels = num2str(fliplr(d+1-levels).').';
        angle2 = str2num(movesToEncode{j}(end));
        compAngle = num2str(4-angle2);
        if axis == axis2
            % The rotations commute
            mv2 = movesToEncode{j};
        else
            if axis == 1
                if axis2 == 2
                    switch angle
                        case 1
                            mv2 = ['z', compLevels, compAngle];
                        case 2
                            mv2 = ['y', compLevels, compAngle];
                        case 3
                            mv2 = ['z', movesToEncode{j}(2:end)];
                    end
                elseif axis2 == 3
                    switch angle
                        case 1
                            mv2 = ['y', movesToEncode{j}(2:end)];
                        case 2
                            mv2 = ['z', compLevels, compAngle];
                        case 3
                            mv2 = ['y', compLevels, compAngle];
                    end
                end
            elseif axis == 2
                if axis2 == 3
                    switch angle
                        case 1
                            mv2 = ['x', compLevels, compAngle];
                        case 2
                            mv2 = ['z', compLevels, compAngle];
                        case 3
                            mv2 = ['x', movesToEncode{j}(2:end)];
                    end
                elseif axis2 == 1
                    switch angle
                        case 1
                            mv2 = ['z', movesToEncode{j}(2:end)];
                        case 2
                            mv2 = ['x', compLevels, compAngle];
                        case 3
                            mv2 = ['z', compLevels, compAngle];
                    end
                end
            elseif axis == 3
                if axis2 == 1
                    switch angle
                        case 1
                            mv2 = ['y', compLevels, compAngle];
                        case 2
                            mv2 = ['x', compLevels, compAngle];
                        case 3
                            mv2 = ['y', movesToEncode{j}(2:end)];
                    end
                elseif axis2 == 2
                    switch angle
                        case 1
                            mv2 = ['x', movesToEncode{j}(2:end)];
                        case 2
                            mv2 = ['y', compLevels, compAngle];
                        case 3
                            mv2 = ['x', compLevels, compAngle];
                    end
                end
            end
        end
        % We identify the move in the standard list
        item = 0;
        mv2Comp = [mv2(1:end-1), num2str(4-str2num(mv2(end)))];
        for k = 1:length(moves)
            if isequal(mv2, moves{k})
                item = k;
            elseif isequal(mv2Comp, moves{k})
                item = -k;                        
            end
        end
        if item == 0
            error(['Operation ', mv2, ' was not found in the list of generators']);
        else
            commuted(j) = item;
        end
    end
end
