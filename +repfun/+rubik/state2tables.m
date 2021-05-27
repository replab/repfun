function tables = state2tables(state)
% This function translates a state of the cube given as a vector into 6
% tables suited for the display functions
%
% The elements of the vector state are organized as follows for an 
% unfolded cube:
%      1  2                         (top)
%      3  4
%      5  6,  9 10, 13 14, 17 18,   (4 sides)
%      7  8, 11 12, 15 16, 19 20, 
%     21 22                         (bottom)
%     23 24
%
% The tables are provided as a dxdx6 nd-array of the following form:
%    5  6
%    7  8
%
%    9 10
%   11 12
%
%   13 14
%   15 16
%
%   17 18
%   19 20
%
%    1  2
%    3  4
%
%   21 22
%   23 25
%
% Args:
%     state (1,\*) integer : the state of the cube
%
% Returns: (dxdx6 integer)

    d = sqrt(numel(state)/6);

    % Permutation to another state encoding
    reOrder = [d^2+[1:4*d^2], 1:d^2, 5*d^2+[1:d^2]];

    tables = permute(reshape(state(reOrder), d, d, 6), [2 1 3]);
end
