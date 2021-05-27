function [fixedLabelRef, fixedLabel] = identifyCenters(referenceState, state)
% Here, we identify the colors appearing in the centre of the cube's faces
% in the state given in stateTxt, and assign them their number with respect
% to the reference state.
%
% This only applies to the case where d is odd. Otherwise, the center
% pieces are not fixed.
%
% For nonzero elements `sel` of `fixedLabel`, we then have the guarantee that
% referenceState(fixedLabel(sel)) == state(sel)

d = sqrt(length(referenceState)/6);

if mod(d,2) == 0
    fixedLabelRef = zeros(1,6*d^2);
    fixedLabel = zeros(1,6*d^2);
    return;
end

% We identify the centers
ref = ceil(d^2/2) + [0:5]*d^2;

fixedLabelRef = zeros(1,6*d^2);
fixedLabelRef(ref) = ref;

fixedLabel = zeros(1,6*d^2);
for i = 1:6
    for j = 1:6
        if state(ref(i)) == referenceState(ref(j))
            fixedLabel(ref(i)) = ref(j);
        end
    end
end

