function [sequence, besti] = permutation2Sequence(d, chain, moves, coset, globalRotations)
% This function computes a sequence of moves that implement the
% permutation
%
% Args: 
%     d (integer) : cube dimension
%     chain (replab.bsgs.ChainWithWords) : a chain with words
%     moves (cell array) : list of moves in text form corresponding to each
%         generator
%     coset (1,\*) integer or replab.LeftCoset : the set of permutations to
%         decompose in terms of generators
%     globalRotations (\*,\*) integer, optional: a list permutations which
%         do not affect the global result
%
% Returns:
% --------
%     (1,\*) integer: a sequence of generator indices implementing the
%         permutation (negative for inverses)
%     integer: the index of the global rotation which yielded the sequence

    assert(~isempty(coset));

    if nargin < 5
        globalRotations = 1:6*d^2;
    end
    
    tic;
    % We try several way of equivalent permutations...
    words = cell(1, size(globalRotations,1));
    wordsi = cell(1, size(globalRotations,1));
    if repfun.globals.parallelization && (d >= 4)
        parfor i = 1:size(globalRotations,1)
            if isa(coset, 'double')
                perm = coset(globalRotations(i,:));
                words{i} = chain.word(perm);
                wordsi{i} = chain.word(repfun.util.inversePerm(perm));
            else
                perm = coset.representative(globalRotations(i,:));
                words{i} = chain.wordLeftCoset(perm, coset.group.chain);
                wordsi{i} = -fliplr(words{i});
%                 perm = coset.representative(globalRotations(i,:));
%                 newCoset = replab.LeftCoset(coset.group, perm, coset.parent);
%                 words{i} = chain.wordForLeftCoset(newCoset);
%                 newCoset = replab.LeftCoset(coset.group, repfun.util.inversePerm(perm), coset.parent);
%                 wordsi{i} = chain.wordForLeftCoset(newCoset);
            end

            % Perform some simple simplification of the move sequences
            tmp = [];
            while ~isequal(tmp, words{i})
                tmp = words{i};
                words{i} = repfun.rubik.simplifySequence(d, words{i}, moves);
            end
            tmp = [];
            while ~isequal(tmp, wordsi{i})
                tmp = wordsi{i};
                wordsi{i} = repfun.rubik.simplifySequence(d, wordsi{i}, moves);
            end
        end
    else
        for i = 1:size(globalRotations,1)
            if isa(coset, 'double')
                perm = coset(globalRotations(i,:));
                words{i} = chain.word(perm);
                wordsi{i} = chain.word(repfun.util.inversePerm(perm));
            else
                perm = coset.representative(globalRotations(i,:));
                words{i} = chain.wordLeftCoset(perm, coset.group.chain);
                wordsi{i} = -fliplr(words{i});
                
%                 newCoset = replab.LeftCoset(coset.group, perm, coset.parent);
%                 words{i} = chain.wordForLeftCoset(newCoset);
%                 newCoset = replab.LeftCoset(coset.group, repfun.util.inversePerm(perm), coset.parent);
%                 wordsi{i} = chain.wordForLeftCoset(newCoset);
%
%                 global state generators
% 
%                 perm = coset.representative(globalRotations(i,:));
%                 newCoset = replab.LeftCoset(coset.group, perm, coset.parent);
%                 words{i} = chain.wordCoset(newCoset);
%                 repfun.rubik.isSolved(repfun.rubik.applySequence(state, generators, words{i}))
%                 
%                 [a b] = chain.wordCoset(newCoset);
%                 state(b)
%                 repfun.rubik.applySequence(1:length(state), generators, (a))-b
% 
%                 iperm = repfun.util.inversePerm(perm);
%                 newCoset = replab.RightCoset(coset.group, iperm, coset.parent);
%                 wordsi{i} = chain.wordCoset(newCoset);
%                 repfun.rubik.isSolved(repfun.rubik.applySequence(state, generators, -fliplr(wordsi{i})))
%                 
%                 [a b] = chain.wordCoset(newCoset);
%                 state(inversePerm(b))
%                 repfun.rubik.applySequence(1:length(state), generators, a)-b
%                 repfun.rubik.applySequence(1:length(state), generators, -fliplr(a))-inversePerm(b)'
            end

            % Perform some simple simplification of the move sequences
            tmp = [];
            while ~isequal(tmp, words{i})
                tmp = words{i};
                words{i} = repfun.rubik.simplifySequence(d, words{i}, moves);
            end
            tmp = [];
            while ~isequal(tmp, wordsi{i})
                tmp = wordsi{i};
                wordsi{i} = repfun.rubik.simplifySequence(d, wordsi{i}, moves);
            end
        end
    end
    
    % ... and keep the shortest solution
    lengths = cellfun(@(x) length(x), words);
    lengthsi = cellfun(@(x) length(x), wordsi);
    minLengths = min(lengths);
    minLengthsi = min(lengthsi);
    if minLengths <= minLengthsi
        besti = find(lengths == minLengths, 1);
        sequence = words{besti};
    else
        besti = find(lengthsi == minLengthsi, 1);
        sequence = -fliplr(wordsi{besti});
    end
    allLengths = [lengths, lengthsi];

    if repfun.globals.verbose >= 2
        disp(['Word lengths statistics (', num2str(2*size(globalRotations,1)), ' samples): [', ...
            num2str(min(allLengths)), ', ', ...
            num2str(mean(allLengths),3), '(', num2str(std(allLengths),2), '), ', ...
            num2str(max(allLengths)), ']']);
    end
    if repfun.globals.verbose >= 1
        disp(['Decoding sequence found (', num2str(toc), 's)']);
    end
end
