function n = fromSeveralBasesInversed(is, bases)
% n = fromSeveralBasesInversed(is, bases)
%
% Does the same as the function with a similar name, except that it starts
% counting with the least significant digit on the left.

% Written by Jean-Daniel Bancal, last modified 7 March 2011.

n = repfun.util.fromSeveralBases(fliplr(is), fliplr(bases));

