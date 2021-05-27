function [referenceState, fixedLabelRef, fixedLabel] = identifyCorners(state)
% Here, we identify the colors appearing on the corner of the cube in the
% state given in stateTxt, and assign them their number with respect to the
% reference state.
%
% For nonzero elements `sel` of `fixedLabel`, we then have the guarantee that
% referenceState(fixedLabel(sel)) == state(sel)

d = sqrt(length(state)/6);

% We compute the corner cycles
ref = ...
[1        d        0         0         0         0         0         0
d^2-d+1   d^2      0         0         0         0         0         0
d^2+1     d^2+d    2*d^2+1   2*d^2+d   3*d^2+1   3*d^2+d   4*d^2+1   4*d^2+d
2*d^2-d+1 2*d^2    3*d^2-d+1 3*d^2     4*d^2-d+1 4*d^2     5*d^2-d+1 5*d^2 
5*d^2+1   5*d^2+d  0         0         0         0         0         0
6*d^2-d+1 6*d^2    0         0         0         0         0         0];

% tmp = [ref(:,1:2); ref(:,3:4); ref(:,5:6); ref(:,7:8)];
% tmp = tmp';
% tmp = tmp(:);
% tmp = tmp(tmp~=0)';

cornerCycles = {...
    [ref(1, 1) ref(3, [6 7])], ...
    [ref(1, 2) ref(3, [4 5])], ...
    [ref(2, 1) ref(3, [8 1])], ... % careful: non-increasing indices here
    [ref(2, 2) ref(3, [2 3])], ...
    [ref(5, 1) ref(4, [1 8])], ... % careful: non-increasing indices here
    [ref(5, 2) ref(4, [3 2])], ... % careful: non-increasing indices here
    [ref(6, 1) ref(4, [7 6])], ... % careful: non-increasing indices here
    [ref(6, 2) ref(4, [5 4])]};    % careful: non-increasing indices here

% Extract the corner colors
actualCorners = zeros(8,3);
for i = 1:8
    actualCorners(i,:) = state(cornerCycles{i});
    if length(unique(actualCorners(i,:))) < 3
        % Inconsistent coloring
        referenceState = [];
        fixedLabelRef = [];
        fixedLabel = [];
        return;
    end
end

% We deduce the simplest reference State
referenceOrder = zeros(1,6);
referenceOrder([1 4 5]) = actualCorners(1, 1:3);
for i = 1:8
    if any(actualCorners(i,:) == referenceOrder(1)) && any(actualCorners(i,:) == referenceOrder(4))
        referenceOrder(3) = setdiff(actualCorners(i,:), referenceOrder([1 4]));
    end
    if any(actualCorners(i,:) == referenceOrder(1)) && any(actualCorners(i,:) == referenceOrder(5))
        referenceOrder(2) = setdiff(actualCorners(i,:), referenceOrder([1 5]));
    end
end
referenceOrder(6) = setdiff(1:6, referenceOrder);
if any(referenceOrder == 0)
    % Inconsistent coloring
    referenceState = [];
    fixedLabelRef = [];
    fixedLabel = [];
    return;
end
referenceState = kron(referenceOrder, ones(1,d^2));

% Now extract the target corner colors 
refCorners = zeros(8,3);
for i = 1:8
    refCorners(i,:) = referenceState(cornerCycles{i});
end

% We don't know the permutation, so sort the colors for each corner
actualCorners = sort(actualCorners, 2);
refCorners = sort(refCorners, 2);

% We look for matches between actual and target corners
matches = zeros(1,8);
for i = 1:8
    for j = 1:8
        if isequal(actualCorners(i,:), refCorners(j,:))
            matches(i) = j;
        end
    end
end
if sum(matches==0) ~= 0
    % The coloring of the corners does not match
    fixedLabelRef = [];
    fixedLabel = [];
    return;
end

% Extract the corresponding mapping
fixedLabelRef = zeros(1,6*d^2);
fixedLabel = zeros(1,6*d^2);
for i = 1:8
    fixedLabelRef(cornerCycles{i}) = cornerCycles{i};

    actualJ = zeros(1,3);
    for j = 1:3
        actualJ(j) = find(state(cornerCycles{i}) == referenceState(cornerCycles{matches(i)}(j)));
        fixedLabel(cornerCycles{i}(actualJ(j))) = cornerCycles{matches(i)}(j);
    end
    % We check that the cyclicity is correct
    if ~isequal([1 2 3], actualJ(actualJ(actualJ)))
        % Even parity, the chirality is broken
        fixedLabelRef = [];
        fixedLabel = [];
        return;
    end    
end

sel = find(fixedLabel ~= 0);
assert(length(sel) == 24);
assert(isequal(referenceState(fixedLabel(sel)), state(sel)));

