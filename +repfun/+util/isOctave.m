function value = isOctave
% Returns true if running on octave
    persistent isOctave
    if isempty(isOctave)
        isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
    end
    value = isOctave;
end
