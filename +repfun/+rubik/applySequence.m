function state = applySequence(state, generators, sequence)
% Applies a move sequence to the state of the cube
%
% Args:
%     state (1,\*) integer : the state of the cube or a permutation
%     generators (1,\*) cell array : the generators
%     sequence (1,\*) integer : sequence of moves indexed from the
%         generators, negative numbers for inverses
%
% Returns (1,\*) integer
%     The state after application of the sequence of moves

    for i = 1:length(sequence)
        if sequence(i) > 0
            % apply the desired permutation
            state = state(generators{sequence(i)});
        else
            % Apply the inverse permuatation
            state(generators{-sequence(i)}) = state;
        end
    end
end
