function result = isSolved(state)
% Tests whether a rubik's cube state is in a solved configuration
%
% Args:
%     state (1,\*) integer : the state of the cube
%
% Returns: boolean

d = sqrt(length(state)/6);
result = isequal(state, kron(state(1:d^2:end), ones(1,d^2)));
