function is = toSeveralBasesInversed(n, bases)
% is = toSeveralBasesInversed(n, bases)
%
% Does the same as the function with a similar name, except that it starts
% counting with the least significant digit on the left.

% Written by Jean-Daniel Bancal, last modified 7 March 2011.

is = fliplr(repfun.util.toSeveralBases(n, fliplr(bases)));

% Not worse :
%is = toSeveralBases(n, bases(length(bases):-1:1));
%is = is(length(is):-1:1);
