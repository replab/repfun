function allGenerators = generators
% Returns the permutation action of all the moves on a set of olympic rings
%
% The element [i, j] of allGenerators corresponds to rotating the ith ring
% by j steps in the trigonometric direction.
%
% Returns:
% --------
%   allGenerators: cell array
%       The list of permutations


% Rotate ring 1 by 1 step
gen{1} = [32, 1:24, 33, 26:30, 31, 25, 34:157];

% Rotate ring 2 by 1 step
gen{2} = [1:31, 56, 62, 33:48, 64, 50:54, 63, 32, 57:61, 55, 49, 65:157];

% Rotate ring 3 by 1 step
gen{3} = [1:62, 80, 86, 94, 65:79, 63, 81:85, 64, 95, 88:92, 93, 87 96:157];

% Rotate ring 4 by 1 step
gen{4} = [1:93, 118, 124, 95:110, 126, 112:116, 125, 94, 119:123, 117, 111, 127:157];

% Rotate ring 5 by 1 step
gen{5} = [1:124, 151, 157, 126:150, 125, 152:156];

allGenerators = cell(5, 33);
allGenerators(1:5,1) = gen;
co = 0;
for i = 1:33
    for j = 1:5
        co = co + 1;
        allGenerators{j,i} = gen{j};
        gen{j} = gen{j}(allGenerators{j});
    end
end

