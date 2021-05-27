function invPerm = inversePerm(perm)
% Calculates the inverse permutation of a given one
%
% Args:
%     perm (1,\*) integers : a permutation
%
% Returns: (1,\*) integer
%     inverse permutation

assert(max(perm) < 10^9, 'Permutation element too large');

invPerm = zeros(1,max(perm));
for i = 1:length(perm)
    if perm(i) ~= 0
        invPerm(perm(i)) = i;
    end
end
