function time = timeRotation(state, generators, moves)
% Measures the time it takes to perform the first rotation and back (and
% possibly come back to the starting view)
%
% Args:
%     state (1,\*) integer : the state of the cube or a permutation
%     generators (1,\*) cell array : the generators
%     moves (cell array, optional) : text description of the move
%         corresponding to each generator
%
% Returns: double
%     time in second to perform the operation

    t0 = tic;
    repfun.rubik.plot(state, generators, moves, [1 -1]);
    time = toc(t0);
end
