function words = compressSequence(d, words, generators, moves, chain, globalRotations, globalRotationsWords, figNumber)
% Here, we perform an attempt at simplifying the sequence of moves by
% examining the permutations corresponding to subsequences iteratively.
% This can be a very slow process.
%
% Note: The provided sequence does not perform the same permutation, but
% only one identical up to solid rotations of the whole cube (i.e. it does
% preserves the property of a cube being solved)
%
% Note: Here we assume that the three possible angle of rotations are
% encoded as (-1, 3), (1, 2), (1, 3) respectively
%
% Args:
%     d (integer) : dimension
%     words (1,\*) integer : sequence of generator indices (negative for
%         inverses)
%     generators (cell array) : the generators
%     moves (cell array) : list of moves in text form corresponding to each
%         generator
%     chain (replab.bsgs.ChainWithWords) : a chain with words
%     globalRotations (\*,\*) integer, optional: a list permutations which
%         do not affect the global result
%     figNumber (integer, optional) : number of the figure associated with
%         with the cube (for interaction only)
%
% Returns: (1,\*) integer
%     a smaller sequence of generators

if nargin < 7
    globalRotations = 1:6*d^2;
    globalRotationsWords = {[]};
end

if nargin < 8
    figNumber = 0;
else
    disp('Attempting to compress the move sequence.');
    disp('This can be a slow process. Press ''I'' to interrupt it.');
end

previousVerboseLevel = repfun.globals.verbose;
repfun.globals.verbose(0);

initialLength = length(words);

pbar = replab.infra.repl.ProgressBar(10000);
i = 1;
l = length(words)-1;
newPercent = -1;
while l >= 3
    j = i + l - 1;
    permutation = repfun.rubik.applySequence(1:6*d^2, generators, words(i:j));
    [seqij, besti] = repfun.rubik.permutation2Sequence(d, chain, moves, permutation, globalRotations);
    if length(seqij) < l
        % We found a shortcut for part of the sequence
        assert(isequal(permutation, repfun.rubik.applySequence(1:6*d^2, generators, [seqij, -fliplr(globalRotationsWords{besti})])))
        words = [words(1:i-1), seqij, -fliplr(globalRotationsWords{besti}), words(j+1:end)];
        tmp = [];
        while ~isequal(tmp, words)
            tmp = words;
            words = repfun.rubik.removeFullRotations(words, moves);        
            % In case we created some successive double rotations
            words = repfun.rubik.simplifySequence(d, words, moves);
        end
    end

    % We move the cursors
    i = i + 1;
    if j >= length(words)
        % We reached the end for this test length, start again with a
        % smaller length
        i = 1;
        l = min(l, length(words)) - 1;
    end
    
    % Update the progress bar
    n = length(words);
    accomplished = (n-l-1)*(n-l)/2 + min(i-1, n-3);
    total = (n-3)*(n-2)/2;
    previousPercent = newPercent;
    newPercent = floor(accomplished/total*10000);
    if newPercent ~= previousPercent
        pbar.step(newPercent, [num2str(initialLength), '->', num2str(length(words))]);
    end
    if figNumber > 0
        % We check if the user wants to interrupt the process
        pause(0.00001);
        if isequal(upper(repfun.util.lastKeyPressed(figNumber, 'get')), 'I')
            % We stop here
            pbar.finish;
            disp('I');
            repfun.globals.verbose(previousVerboseLevel);
            return;
        end
    end
end
pbar.finish;

%disp(num2str(words));

repfun.globals.verbose(previousVerboseLevel);

