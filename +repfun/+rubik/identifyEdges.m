function [fixedLabelRef, fixedLabel] = identifyEdges(referenceState, state)
% Here, we identify the colors appearing on the edges of the cube in the
% state given in stateTxt, and assign them their number with respect to the
% reference state.
%
% For d = 3, we have the exact identification given by fixedLabel such that
% for nonzero elements `sel` of `fixedLabel`, we then have the guarantee that
% referenceState(fixedLabel(sel)) == state(sel)
%
% For d > 3, classes of identical elements are assigned identical values in
% fixedLabelRef for referenceState as in fixedLabel for state.


d = sqrt(length(referenceState)/6);

if d <= 2
    fixedLabelRef = zeros(1,6*d^2);
    fixedLabel = zeros(1,6*d^2);
    return;
end

% We compute the corner cycles
ref = ...
[1        d        0         0         0         0         0         0
d^2-d+1   d^2      0         0         0         0         0         0
d^2+1     d^2+d    2*d^2+1   2*d^2+d   3*d^2+1   3*d^2+d   4*d^2+1   4*d^2+d
2*d^2-d+1 2*d^2    3*d^2-d+1 3*d^2     4*d^2-d+1 4*d^2     5*d^2-d+1 5*d^2 
5*d^2+1   5*d^2+d  0         0         0         0         0         0
6*d^2-d+1 6*d^2    0         0         0         0         0         0];

edges = {...
    [ref(1,1)+1:ref(1,2)-1;   ref(3,6)-1:-1:ref(3,5)+1], ...
    [ref(1,1)+d:d:ref(2,1)-d; ref(3,7)+1:ref(3,8)-1], ...
    [ref(2,1)+1:ref(2,2)-1;   ref(3,1)+1:ref(3,2)-1], ...
    [ref(1,2)+d:d:ref(2,2)-d;   ref(3,4)-1:-1:ref(3,3)+1], ...
    ...
    [ref(3,8)+d:d:ref(4,8)-d;   ref(3,1)+d:d:ref(4,1)-d], ...
    [ref(3,2)+d:d:ref(4,2)-d;   ref(3,3)+d:d:ref(4,3)-d], ...
    [ref(3,4)+d:d:ref(4,4)-d;   ref(3,5)+d:d:ref(4,5)-d], ...
    [ref(3,6)+d:d:ref(4,6)-d;   ref(3,7)+d:d:ref(4,7)-d], ...
    ...
    [ref(5,1)+1:ref(5,2)-1;   ref(4,1)+1:ref(4,2)-1], ...
    [ref(5,1)+d:d:ref(6,1)-d; ref(4,8)-1:-1:ref(4,7)+1], ...
    [ref(6,1)+1:ref(6,2)-1;   ref(4,6)-1:-1:ref(4,5)+1], ...
    [ref(5,2)+d:d:ref(6,2)-d; ref(4,3)+1:ref(4,4)-1], ...
    };


fixedLabelRef = zeros(1,6*d^2);
fixedLabel = zeros(1,6*d^2);

edges = cat(2, edges{:})';
nbEdges = size(edges, 1);

if ~isequal(unique(sort(referenceState(edges),2), 'rows'), unique(sort(state(edges),2), 'rows'))
    % Some edges won't match
    fixedLabelRef = [];
    fixedLabel = [];
    return;
end

if d == 3
    % We can identify the colors within each edge exactly
    
    fixedLabelRef(edges) = edges;
    for i = 1:nbEdges
        for j = 1:nbEdges
            if isequal(state(edges(i,:)), referenceState(edges(j,:)))
                fixedLabel(edges(i,:)) = edges(j,:);
            elseif isequal(state(edges(i,:)), referenceState(edges(j,2:-1:1)))
                fixedLabel(edges(i,:)) = edges(j,2:-1:1);
            end
        end
    end
else
    % We cannot identify the colors within the edges exactly, so we assign
    % them some numbers

    shift = 6*d^2;
    uniqueEdges = unique(referenceState(edges),'rows');

    % A unique numbering of edges (supports multiple edges)
    toEdgeNumber = @(edge) shift + (edge(:,1)-1)*6 + edge(:,2)-1;

    % A unique numbering of the colors appearing within an edge (for one edge, several colors)
    %toNumber = @(edge) shift + (edge(1)-1)*36 + (edge(2)-1)*6 + edge-1;
    
    % This version does not create new numbers when the elements of the
    % edge appear in a different order
    toNumberOrdered = @(edge) shift + (min(edge)-1)*36 + (max(edge)-1)*6 + edge-1;

    for i = 1:nbEdges
        fixedLabelRef(edges(i,:)) = toNumberOrdered(referenceState(edges(i,:)));
        fixedLabel(edges(i,:)) = toNumberOrdered(state(edges(i,:)));
    end
end

