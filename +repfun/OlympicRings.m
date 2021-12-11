classdef OlympicRings
% A set of olympic rings
%
% This describes a group with 
%   58647843971320721409607903577565776255770915811522296813662399778772412311348317752738888006293661394838528991623327693618510094402304472790645386496087794701218153077181480992696881923737611858489550243880586714047723342811245289492866662400000000000000000000000000000000000000
% elements, and a large diameter.
%
% Each solution has multiplicity
%   19247698393939298997500798719509019560690710529815825239659695013454521697157865888749662659993868757168536340512592883613506461375240601600000000000000000000000000000000000

    properties %(SetAccess = protected)
        fig % integer : number of the figure on which the rings are plotted
        generators % cell array : permutations corresponding to each possible move of rings
        group % replab.PermutationGroup : The permutation group
        chain % replab.bsgs.ChainWithWords : A BSGS chain with words
        state % (1,\*) integer : color of each of the 157 discs
        cosetPermutation % (1,\*) integer : set of permutations that solves the ring
        sequence % (1,\*) integer : sequence of moves implementing a permutation from the coset of solutions
    end
    
    methods
        
        function rings = OlympicRings(fig)
        % Constructs a set of olympic rings
        %
        % By default a new figure is created for the rings
        %
        % Args:
        %     fig (Figure, optional) : the figure on which to plot the
        %     rings
        
            replab_init;
            
            % Describe possible moves of the rings (with inverses)
            rings.generators = repfun.orings.generators;
            
            tic;
            % Create the group and chain with words...
            %base = fliplr(1:157);
            base = [1:78; fliplr(80:157)];
            base = [base(:)', 79];
            specialChain = replab.bsgs.Chain.make(157, rings.generators(1:5), base, vpi('58647843971320721409607903577565776255770915811522296813662399778772412311348317752738888006293661394838528991623327693618510094402304472790645386496087794701218153077181480992696881923737611858489550243880586714047723342811245289492866662400000000000000000000000000000000000000'));
            specialGroup = replab.PermutationGroup(157, rings.generators(1:5), 'chain', specialChain);
            rings.group = specialGroup;
            
            rings.chain = replab.bsgs.ChainWithWords(specialGroup, rings.generators(1:5*15));
            if repfun.globals.verbose >= 1
                disp(['Group and chain with words constructed (', num2str(toc), 's)']);
                tic;
            end
            
            % ...and initialize it
            rings.chain.sgsWordQuick;
            rings.chain.maximumWordLength;
            rings.chain.setCompleted;
            if repfun.globals.verbose >= 1
                disp(['Chain with words initialized (', num2str(toc), 's)']);
                disp(' ')
            end
            
            % Initialize a plot for this rings
            if nargin >= 1
                % activate desired figure
                h = figure(fig);
            else
                % create a new figure
                h = figure;
                fig = get(gcf, 'Number');
            end
            set(h, 'keypressfcn', @(E,F) evalin('base', ['repfun.util.lastKeyPressed(', num2str(fig), ', ''set'', ''', F.Key, ''');']));
            rings.fig = fig;

            % Initialize the state to a vanilla state
            rings = rings.setState(repfun.orings.vanillaState);
        end
        
        function this = setState(this, state)
        % Defines the state of the rings (and updates the plot accordingly)
        
            % Remember the state
            this.state = state;
            
            % Solution is unknown
            this.cosetPermutation = [];
            this.sequence = [];

            % Plot the color configuration
            this.plot;
        end
        
        function plot(this)
        % Plots the rings
        
            figure(this.fig);
            repfun.orings.plot(this.state);
        end
        
        function this = solve(this)
        % This function finds the coset of permutations and a succession of
        % moves which return the rings to the standard form
        
            if ~isempty(this.sequence)
                % If a solving sequence exists already, we keep it
                return
            end
            
            tic;
            this = this.findCoset;
            
            if isempty(this.cosetPermutation)
                % No matching, unphysical state
                return;
            end
            
            tic;
            this.sequence = this.chain.wordLeftCoset(this.cosetPermutation.representative, this.cosetPermutation.subgroup.chain);
        end
        
        function this = findCoset(this)
        % This function finds the set of permutations from the group that
        % transforms state 'state' to its solved state
        
            referenceState = repfun.orings.vanillaState;
            P = this.group.vectorFindPermutationsTo(referenceState, this.state);

            if isempty(P)
                warning('No match found, the state doesn''t appear to be solvable');
                return;
            end
            this.cosetPermutation = P;
            if repfun.globals.verbose >= 1
                disp(['Coset found (', num2str(toc), 's)']);
            end
        end
        
        function this = applySequence(this, sequence)
        % Applies a move sequence to the state of the rings
        %
        % Args:
        %     sequence (1,\*) integer : sequence of moves indexed from the
        %         generators, negative numbers for inverses
        
            this.state = repfun.rubik.applySequence(this.state, this.generators, sequence);
        end
        
        function this = shuffle(this)
        % Shuffles the rings
        
            this.state = repfun.orings.vanillaState;
            this = this.setState(this.state(this.group.sample));
        end
        
        function this = animate(this)
        % This function shows an animation of the rings being solved
        
            if isempty(this.cosetPermutation)
                % Coset unknown, call findCoset first
                return;
            end
            
            % Apply the moves on the rings
            [this.state, this.sequence] = repfun.orings.plot(this.state, this.generators, this.sequence);
            
            % Draw the final state without the handles
            repfun.orings.plot(this.state);
        end
        
    end
    
end
