function moves = sequencetoMove(sequence)
% This function translates a sequence of generators into rotations on
% specific rings
%
% Args:
%     sequence (1, \*) integer : a sequence of generator (or inverses)
%
% Returns:
%     (2, \*) integer : the circle and rotation step of each sequence
%         element

moves = zeros(2, length(sequence));

moves(1,:) = mod(abs(sequence)-1, 5)+1;
moves(2,:) = floor((abs(sequence)-1)/5)+1;
moves(2,:) = sign(sequence).*moves(2,:);

end
