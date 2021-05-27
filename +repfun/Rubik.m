classdef Rubik
% A d-dimensional Rubik's cube
%
% The encoding of the state used internally here currently corresponds to
% the following unfolding of the cube (here for dimension 2)
%
%  1  2                       (top)
%  3  4
%  5  6,  9 10, 13 14, 17 18  (4 sides)
%  7  8, 11 12, 15 16, 19 20 
% 21 22                       (bottom)
% 23 24

    properties %(SetAccess = protected)
        d % integer : the dimension of the cube
        fig % integer : number of the figure on which the cube is plotted
        generators % cell array : permutation corresponding to each possible move of the cube
        moves % cell array : text description of each generator
        globalRotations % (24,\*) integer : permutations that rotate the whole cube
        globalRotationsWords % cell array : a description of each global permutation in terms of a sequence of generators
        group % replab.PermutationGroup : The permutation group
        chain % replab.bsgs.ChainWithWords : A BSGS chain with words
        state % (1,\*) integer : color of each of the 6d^2 facets of the cube
        referenceState % (1,\*) integer : color of each of the 6d^2 facets of the cube when the cube will be solved (up to a global rotation(!))
        coset % (1,\*) integer : set of permutations that solve the cube
        sequence % (1,\*) integer : sequence of moves implementing the permutation
        position % integer : position when the cube is partially solved
    end
    
    methods
        
        function cube = Rubik(d, fig)
        % Constructs a Rubik's cube of given dimension
        %
        % By default a new figure is created for the cube
        %
        % Args:
        %     d (integer) : dimension of the cube
        %     fig (Figure, optional) : the figure on which to plot the cube
        
            replab_init;
            
            % Dimension
            cube.d = d;
            
            % Describe the moves on the cube (without inverses)
            [cube.generators, cube.moves] = repfun.rubik.generators(d);
            
            % We select a nice set of generators to generate the group
            % without too much redundancy
            selMinGens = repfun.util.fromSeveralBasesInversed(eye(d), 2*ones(1,d))*[1 1 1] + ones(d,1)*[0, 2^d-1, 2*(2^d-1)];
            selMinGens = sort(selMinGens(:));

            % Create the permutation group
            tic;
            cube.group = replab.PermutationGroup.of(cube.generators{selMinGens});
            if repfun.globals.verbose >= 1
                disp(['Group constructed, (', num2str(toc), 's)']);
                disp(' ')
            end

            tic;
            % Create the chain with words...
            if (d >= 3) && (d <= 6)
                % For these dimensions, we construct a slightly optimized
                % chain (to get smaller words)
                switch d
                    case 3
                        order = 1:3;
                    case 4
                        order = 1:4;
                    case 5
                        order = [1 2 4 3 6 5 7];
                    case 6
                        order = [1 2 3 6 8 7 4 5 9];
                end
                blocks = cube.group.orbits.blocks;
                assert(length(order) == length(blocks));
                base = cat(2, blocks{order});
                specialChain = replab.bsgs.Chain.make(6*d^2, cube.generators(selMinGens), base);
                
%                 % The following code section somehow makes the
%                 % construction of the chain with words faster, but the
%                 % words obtained are longer... so disabled now.
%                 % We extract only the stabilizing points from the chain
%                 delta = specialChain.Delta;
%                 base2 = [];
%                 co = 0;
%                 for i = 1:length(delta)
%                     if length(delta{i}) > 1
%                         % We have a stabilizing point
%                         co = co + 1;
%                         base2(co) = delta{i}(1);
%                     end
%                 end
%                 % Now we can compute the chain we really are interested in
%                 specialChain = replab.bsgs.Chain.make(6*d^2, cube.generators(selMinGens), base2);

                specialGroup = replab.PermutationGroup(6*d^2, cube.generators(selMinGens), 'chain', specialChain);
                cube.chain = replab.bsgs.ChainWithWords(specialGroup, cube.generators);
            else
                cube.chain = replab.bsgs.ChainWithWords(cube.group, cube.generators);
            end
            if repfun.globals.verbose >= 1
                disp(['Chain with words constructed (', num2str(toc), 's)']);
                tic;
            end
            
            % ...and initialize it
            cube.chain.sgsWordQuick;
            cube.chain.maximumWordLength;
            cube.chain.setCompleted;
            if repfun.globals.verbose >= 1
                disp(['Chain with words initialized (', num2str(toc), 's)']);
                disp(' ')
            end
            
            % Also, list the permutations that rotate the cube globally
            selGlobal = [];
            one2D = num2str([1:d].').';
            for i = 1:length(cube.moves)
                if isequal(cube.moves{i}(2:end), [one2D, '1']) || isequal(cube.moves{i}(2:end), [one2D, '3'])
                    selGlobal = [selGlobal i];
                end
            end
            G24 = replab.PermutationGroup.of(cube.generators{selGlobal});
            cube.globalRotations = cat(1, G24.elements.toCell{:});
            
            % ... and extract the corresponding words
            tmp = replab.bsgs.ChainWithWords(G24, cube.generators(selGlobal));
            tmp.sgsWordQuick;
            tmp.maximumWordLength;
            tmp.setCompleted;
            for i = 1:size(cube.globalRotations,1)
                wordsSel = tmp.word(cube.globalRotations(i,:));
                cube.globalRotationsWords{i} = sign(wordsSel).*selGlobal(abs(wordsSel));
            end
            
            % Initialize a plot for this cube
            if nargin >= 2
                % activate desired figure
                h = figure(fig);
            else
                % create a new figure
                h = figure;
                fig = get(gcf, 'Number');
            end
            set(h, 'keypressfcn', @(E,F) evalin('base', ['repfun.util.lastKeyPressed(', num2str(fig), ', ''set'', ''', F.Key, ''');']));
            cube.fig = fig;
            repfun.rubik.set3DView(repfun.rubik.globals.defaultView, d);

            % Initialize the state to a vanilla state
            cube = cube.setState(kron([1:6], ones(1, d^2)));
        end
        
        function this = setState(this, state)
        % Defines the state of the cube (and updates the plot accordingly)
        
            % Remember the state
            this.state = state;
            
            % Solution is unknown
            this.coset = [];
            this.sequence = [];
            this.position = 1;

            % Plot the color configuration
            this.plot;
        end
        
        function plot(this)
        % Plots the cube
        
            figure(this.fig);
            repfun.rubik.plot(this.state);
        end
        
        function this = solve(this)
        % This function finds the set of permutations and a succession of
        % moves which return the cube to the standard form
        
            global state generators
            state = this.state;
            generators = this.generators;
        
            if ~isempty(this.sequence)
                % If a solving sequence exists already, we keep it
                return
            end
            
            tic;
            this = this.findCoset;
            
            if isempty(this.coset)
                % No matching, unphysical state
                return;
            end
            
            tic;
            this.sequence = repfun.rubik.permutation2Sequence(this.d, this.chain, this.moves, this.coset, this.globalRotations);
            this.sequence = repfun.rubik.removeFullRotations(this.sequence, this.moves);
        end
        
        function this = findCoset(this)
        % This function finds the set of permutations from the group that
        % transforms state 'state' to 'referenceState'
        
            % To begin, we identify some of the pieces directly
            % First the corner pieces
            [this.referenceState, fixedLabelCornersRef, fixedLabelCorners] = repfun.rubik.identifyCorners(this.state);
            %referenceState(1:d^2:end) % The reference order of faces we will use
            if isempty(fixedLabelCornersRef)
                warning('No match found, the state doesn''t appear to be solvable');
                return;
            end
            
            % Then the edge pieces
            [fixedLabelEdgesRef, fixedLabelEdges] = repfun.rubik.identifyEdges(this.referenceState, this.state);
            if (this.d > 2) && isempty(fixedLabelEdgesRef)
                warning('No match found, the state doesn''t appear to be solvable');
                return;
            end
            
            % Finally the center pieces (for odd dimensions)
            [fixedLabelCentersRef, fixedLabelCenters] = repfun.rubik.identifyCenters(this.referenceState, this.state);

            % We merge all fixed elements
            fixedLabelRef = fixedLabelCornersRef + fixedLabelEdgesRef + fixedLabelCentersRef;
            fixedLabel = fixedLabelCorners + fixedLabelEdges + fixedLabelCenters;
            
            
            % Now we look for the remaining part of the mapping
            tic;
            if sum(fixedLabel == 0) == 0
                % We already fully know the permutation doing the job
                this.coset = repfun.util.inversePerm(fixedLabel);
            else
                % We give exact negative values to the known element
                referenceVect = this.referenceState;
                initialVect = this.state;
                referenceVect(fixedLabelRef~=0) = -fixedLabelRef(fixedLabelRef~=0);
                initialVect(fixedLabel~=0) = -fixedLabel(fixedLabel~=0);
                P = this.group.vectorFindPermutationsTo(referenceVect, initialVect);

                if isempty(P)
                    warning('No match found, the state doesn''t appear to be solvable');
                    return;
                end
                this.coset = P;
            end
            if repfun.globals.verbose >= 1
                disp(['Coset found (', num2str(toc), 's)']);
            end
        end
        
        function this = compressSolution(this)
        % Attempts to simplify the sequence
        %
        % Note: this can be a slow process. Sometimes a simplified sequence
        % can be further improved by calling this methods one more time
        
            this.sequence = repfun.rubik.compressSequence(this.d, this.sequence, this.generators, this.moves, this.chain, this.globalRotations, this.globalRotationsWords);
        end
        
        function this = applySequence(this, sequence)
        % Applies a move sequence to the state of the cube
        %
        % Args:
        %     sequence (1,\*) integer : sequence of moves indexed from the
        %         generators, negative numbers for inverses
        
            this.state = repfun.rubik.applySequence(this.state, this.generators, sequence);
        end
        
        function this = shuffle(this)
        % Shuffles the cube
        
            if isempty(this.coset)
                % make sure we start from a safe state
                this.state = kron(1:6, ones(1, this.d^2));
            end
            this = this.setState(this.state(this.group.sample));
        end
        
        function this = animate(this)
        % This function shows an animation of the cube being solved
        
            if isempty(this.coset)
                % Coset unknown, call findCoset first
                return;
            end
            
            % Apply the moves on the cube
            [this.state, nbMovesDone] = repfun.rubik.plot(this.state, this.generators, this.moves, this.sequence(this.position:end));
            
            % Update the position
            this.position = this.position + nbMovesDone;
        end
        
        function this = interactiveEvolution(this)
        % This function allows to solve the Rubik's cube in an interactive
        % manner
        
            repfun.rubik.isSolved(repfun.rubik.applySequence(this.state, this.generators, this.sequence))
        
            title = 'Use the following commands to solve the cube one step at a time:';
            items0 = {{'M', 'Display the menu'}, {'N', 'Go to next state'}, {'P', 'Go to previous state'}, ...
                {'R', 'Rotate'}, {'B', 'Toggle between above and below view'}, ...
                {'L', 'List all moves'}, {'C', 'Attempt to compress the move sequence'}, {'Q', 'Quit'}};
            items = {{'M', 'Display the menu'}, {'N', 'Go to next state'}, {'P', 'Go to previous state'}, ...
                {'R', 'Rotate'}, {'B', 'Toggle between above and below view'}, ...
                {'L', 'List all moves'}, {'Q', 'Quit'}};
        
            movesSequence = this.moves(abs(this.sequence));
            for i = 1:length(this.sequence)
                if this.sequence(i) < 0
                    % Inverse the direction of inversed rotations
                    movesSequence{i}(end) = num2str(4-str2num(movesSequence{i}(end)));
                end
            end

            currentState = this.state;
            
            nbSteps = length(movesSequence);
            currentStep = this.position-1;
            
            if currentStep == 0
                menu = repfun.Menu(title, items0{:});
            else
                menu = repfun.Menu(title, items{:});
            end
            menu.displayMenu;

            while currentStep <= nbSteps
                repfun.rubik.writeMoves(movesSequence, currentStep);
                
                choice = menu.getChoice(false, false, false, false, false);
                if (choice == 'N') && (currentStep == nbSteps)
                    choice = 'Q';
                end
                switch choice
                    case 'M'
                        disp(' ');
                        disp(' ');
                        menu.displayMenu;
                        sequenceToDo = [];
                    case 'N'
                        if currentStep < length(this.sequence)
                            currentStep = currentStep + 1;
                            sequenceToDo = this.sequence(currentStep);
                        else
                            sequenceToDo = [];
                        end
                        if currentStep == 1
                            menu = repfun.Menu(title, items{:});
                        end
                    case 'P'
                        if currentStep > 0
                            currentStep = currentStep - 1;
                            sequenceToDo = -this.sequence(currentStep+1);
                        else
                            sequenceToDo = [];
                        end
                        if currentStep == 0
                            menu = repfun.Menu(title, items0{:});
                        end
                    case 'R'
                        repfun.rubik.rotateToView(this.d, get(gca, 'view'));
                        sequenceToDo = [];
                    case 'B'
                        view = get(gca, 'View');
                        repfun.rubik.rotateToView(this.d, [view(1), -view(2)], 0.3);
                        sequenceToDo = [];
                    case 'C'
                        this.sequence = repfun.rubik.compressSequence(this.d, this.sequence, this.generators, this.moves, this.chain, this.globalRotations, this.globalRotationsWords, this.fig);
                        if (repfun.globals.verbose >= 2) && ~repfun.rubik.isSolved(repfun.rubik.applySequence(this.state, this.generators, this.sequence))
                            disp('We lost the solution...');
                        end
                        % We update the moves
                        movesSequence = this.moves(abs(this.sequence));
                        for i = 1:length(this.sequence)
                            if this.sequence(i) < 0
                                % Inverse the direction of inversed rotations
                                movesSequence{i}(end) = num2str(4-str2num(movesSequence{i}(end)));
                            end
                        end
                        sequenceToDo = [];
                    case 'L'
                        for i = 1:length(movesSequence)
                            move = movesSequence{i};
                            levels = [num2str(move(2:end-1).'), ','*ones(length(move)-2,1)].';
                            levels = levels(:).';
                            levels = levels(1:end-1);
                            if str2num(move(end)) == 1
                                move = [move(1), '(', levels, ')'];
                            else
                                move = [move(1), '(', levels, ')^', move(end)];
                            end
                            fprintf([move, char(' '*ones(1, this.d*2-1+5-length(move) + 1))]);
                            if mod(i, 10) == 0
                                disp(' ');
                            end
                        end
                        sequenceToDo = [];
                        disp(' ')
                        disp(' ')
                    case 'Q'
                        % We keep the current state so update the solving
                        % sequence
                        this.state = currentState;
                        this.position = currentStep + 1;
                        sequenceToDo = [];
                end
                
                if ~isempty(sequenceToDo)
                    if repfun.util.isOctave
                        % We need to clear the whole figure to remove the
                        % annotations
                        view = get(gca,'View');
                        clf;
                        repfun.rubik.set3DView(view, this.d);
                        currentState = repfun.rubik.plot(currentState, this.generators, this.moves, sequenceToDo, false);
                    else
                        % We can keep the annotations during the cube rotation
%                        delete(findall(gcf,'type','annotation'));
%                        repfun.rubik.writeMoves(movesSequence, currentStep-0.5);
                        currentState = repfun.rubik.plot(currentState, this.generators, this.moves, sequenceToDo, false);
                        delete(findall(gcf,'type','annotation'));
                    end
                else
                    % We erase the annotations
                    if repfun.util.isOctave
                        view = get(gca,'View');
                        clf;
                        repfun.rubik.set3DView(view, this.d);
                        repfun.rubik.plot(currentState);
                    else
                        delete(findall(gcf,'type','annotation'));
                    end
                end
                
                if choice == 'Q'
                    return
                end
            end
            
            % remember the final state
            this.state = repfun.rubik.tables2state(currentState);
            
            % remember the position
            this.position = currentStep + 1;
        end
        
    end
    
end
