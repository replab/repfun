function state = tables2state(tables)
% This function translates a tables describing a cube into its
% corresponding vector  representation (see state2tables.m for more
% details)
%
% Args:
%     tables (dxdx6 integer)
%
% Returns: (1,\*) integer

    d = sqrt(numel(tables)/6);

    % Permutation to another state encoding
    reOrder = [d^2+[1:4*d^2], 1:d^2, 5*d^2+[1:d^2]];

    state = permute(tables, [2 1 3]);
    state = state(:).';
    state(reOrder) = state;
end
