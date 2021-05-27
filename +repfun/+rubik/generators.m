function [allGeneratorsCell, moves] = generators(d)
% Returns the permutation action of all the moves on a Rubik's cube of a
% given dimension
%
% Args:
%   d (integer): dimension of the cube
%
% Returns:
% --------
%   allGeneratorsCell: cell array
%       The list of permutations
%   moves: cell array
%       Text description of each move


%% We compute the effect of several group generators on a dxdxd-dimensional
% model of the Rubik's cube
top0 = reshape([1:d^2],d,d)';
side10 = reshape(d^2+[1:d^2],d,d)';
side20 = reshape(2*d^2+[1:d^2],d,d)';
side30 = reshape(3*d^2+[1:d^2],d,d)';
side40 = reshape(4*d^2+[1:d^2],d,d)';
bottom0 = reshape(5*d^2+[1:d^2],d,d)';

% First, we consider rotations around the front axis
for layersCombination = 1:2^d-1
    % We initialize the Rubik's cube,
    top = top0;
    side1 = side10;
    side2 = side20;
    side3 = side30;
    side4 = side40;
    bottom = bottom0;
    
    % This tells for each layers whether it is rotated by 90 degrees or not
    layBin = repfun.util.toSeveralBasesInversed(layersCombination, 2*ones(1,d));
    lay = find(layBin);
    
    % compute the effect of the rotation,
    top(d+1-lay,:) = side40(d:-1:1,d+1-lay)';
    if layBin(1) == 1
        side1 = side10(d:-1:1,:)';
    end
    side2(:,lay) = top0(d+1-lay,:)';
    if layBin(d) == 1
        side3 = side30(:,d:-1:1)';
    end
    side4(:,d+1-lay) = bottom0(lay,:)';
    bottom(lay,:) = side20(d:-1:1,lay)';

    % and write the image in vector form
    generatorsFront(layersCombination,:) = [reshape(top',1,d^2) reshape(side1',1,d^2) reshape(side2',1,d^2) reshape(side3',1,d^2) reshape(side4',1,d^2) reshape(bottom',1,d^2)];
    
    movesFront{layersCombination} = ['x', num2str(sort(lay)')', '3']; % clock-wise, counter-trigonometric
    
    % We check that this is a valid permutation...
    if ~isequal(unique(generatorsFront(layersCombination,:)), 1:6*d^2)
        disp('Error : invalid permutation.');
        return;
    end
end

% Next, we consider rotations around the right axis
% The effect here is the same as around the front axis, after we have
% rotated the full rubik's cube by 90 degrees around the vertical axis.
% So let us describe this rotation

% compute the effect of the rotation,
top = top0(d:-1:1,:)';
side1 = side20;
side2 = side30;
side3 = side40;
side4 = side10;
bottom = bottom0(:,d:-1:1)';

Z90 = [reshape(top',1,d^2) reshape(side1',1,d^2) reshape(side2',1,d^2) reshape(side3',1,d^2) reshape(side4',1,d^2) reshape(bottom',1,d^2)];
assert(isequal(Z90(Z90(Z90(Z90))), [1:6*d^2]), 'Error : the Z90 permutation is not a 4-cycle.');
Z90i = repfun.util.inversePerm(Z90)';

% Now we combine it with the front generators
generatorsRight = Z90(generatorsFront(:,Z90i));

movesRight = cellfun(@(x) ['y', x(2:end)], movesFront, 'UniformOutput', false);


% Finally, we consider rotations around the top axis. These are easy to
% write down directly.
for layersCombination = 1:2^d-1
    % We initialize the Rubik's cube,
    top = top0;
    side1 = side10;
    side2 = side20;
    side3 = side30;
    side4 = side40;
    bottom = bottom0;
    
    % This tell for each layers whether it is rotated by 90 degrees or not
    layBin = repfun.util.toSeveralBasesInversed(layersCombination, 2*ones(1,d));
    lay = find(layBin);
    
    % compute the effect of the rotation,
    if layBin(1) == 1
        top = top0(d:-1:1,:)';
    end
    side1(lay,:) = side20(lay,:);
    side2(lay,:) = side30(lay,:);
    side3(lay,:) = side40(lay,:);
    side4(lay,:) = side10(lay,:);
    if layBin(d) == 1
        bottom = bottom0(:,d:-1:1)';
    end

    % and write the image in vector form
    generatorsTop(layersCombination,:) = [reshape(top',1,d^2) reshape(side1',1,d^2) reshape(side2',1,d^2) reshape(side3',1,d^2) reshape(side4',1,d^2) reshape(bottom',1,d^2)];

    movesTop{layersCombination} = ['z', num2str(lay')', '3'];

    % We check that this is a valid permutation...
    if ~isequal(unique(generatorsTop(layersCombination,:)), 1:6*d^2)
        disp('Error : invalid permutation.');
        return;
    end
end

% Now we can put all generators together:
allGenerators = [generatorsFront; generatorsRight; generatorsTop];

moves = cat(2, movesFront, movesRight, movesTop);

% We add the double moves
allGenerators2 = allGenerators;
for i = 1:size(allGenerators,1)
    allGenerators2(i,:) = allGenerators2(i,allGenerators2(i,:));
    moves{end+1} = [moves{i}(1:end-1), '2'];
end
allGenerators = [allGenerators; allGenerators2];

allGeneratorsCell = mat2cell(allGenerators, ones(1,size(allGenerators,1)), 6*d^2).';

