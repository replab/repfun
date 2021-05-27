classdef Menu < handle
% Defines an interactive menu
%
% This menu is special in that it is displayed in the command line, but
% captures character typed in a figure. This is useful to make a figure
% interactive, with instructions being provided in the terminal.

    properties (SetAccess = protected)
        title % string : menu title
        entries % cell array : list of entries
        ignoreCase % bool : whether to ignore case
        nbDisplayedInputsSinceMenu % integer : number of inputs prompted since the last menu was displayed
    end
    
    methods
        
        function menu = Menu(title, varargin)
        % Constructs an interactive menu
        %
        % A menu entry comprises:
        %  1) A letter triggering the entry choice (char)
        %  2) A text describing this entry (string)
        %  3) A function to call upon (function handle, optional)
        %
        % Args:
        %   title (string): Title of the menu
        %   varargin (cell array): successive menu entries
        %
        % Returns:
        %   repfun.Menu: The menu
        %
        % Example:
        %   >>> repfun.Menu('Yes or No?', {'y', 'Yes', @() disp('You chose "Yes"');}, {'n', 'No'})
        
            assert(isa(title, 'char'), 'Title should be a string');
            menu.title = title;
            
            assert(nargin > 1, 'No entries in the menu');
            menu.entries = cell(nargin-1, 3);
            for i = 1:nargin-1
                assert(isa(varargin{1}, 'cell'), 'Entries should be provided in cell array format');
                assert((length(varargin{i}) >= 2) && (length(varargin{i}) <= 3), 'An entry should contain between two and three parameters');
                
                assert(isa(varargin{i}{1}, 'char') && (length(varargin{i}{1}) == 1), 'Triggering letter should be a single character');
                assert(isa(varargin{i}{2}, 'char'), 'Menu entry description should be a string');
                
                menu.entries(i, 1:length(varargin{i})) = varargin{i};
                if length(varargin{i}) == 3
                    assert(isa(varargin{i}{3}, 'function_handle'), 'Triggered function should be a function handle');
                else
                    menu.entries{i,3} = @() []; % empty function
                end
            end
            
            % Let's run some sanity check
            nbEntries = size(menu.entries,1);
            for i = 1:nbEntries-1
                for j = i+1:nbEntries
                    if isequal(menu.entries{i,1}, menu.entries{j,1})
                        warning(['Triggering letter ', menu.entries{i,1}, ' is used for entries ', num2str(i), ' and ', num2str(j), ', only one element will be accessible.']);
                    end
                end
            end
            
            menu.ignoreCase = true;
            if menu.ignoreCase
                for i = 1:nbEntries
                    menu.entries{i,1} = upper(menu.entries{i,1});
                end
            end
            
            menu.nbDisplayedInputsSinceMenu = 0;
        end
        
        function displayMenu(this)
        % Displays the menu
            
            disp(this.title);

            nbEntries = size(this.entries,1);
            for i = 1:nbEntries
                disp(['  (', this.entries{i,1}, ') ', this.entries{i,2}]);
            end
            disp(' ');
            
            this.nbDisplayedInputsSinceMenu = 0;
        end

        function [choice, item] = getChoice(this, displayMenu, displayChoice, displayFailure, acceptNumbers, lastRequest, acceptScriptEntries)
        % gets a user choice from the menu
        %
        % Requests user input until a valid choice is made. Then calls the
        % corresponding function handle and return the choice.
        % 
        % Args:
        %   displayMenu (bool, optional): whether to display the menu or
        %       not, default is true
        %   displayChoice (bool, optional): whether to print the chosen
        %       option, default is true
        %   displayFailure (bool, optional): whether to print the typed
        %       character if incorrect, default is false
        %   acceptNumbers (bool, optional): whether the elements in the
        %       list can be chosen by typing their index, only possible for
        %       up to nine elements in the menu, true by default
        %   lastRequest (bool, optional): whether this is the last request
        %       to be done with this menu (will enter newline characters),
        %       default is true
        %   acceptScriptEntries (bool, optional): whether to accept entries
        %       from repfun.globals.menuScript for the menu choice (if such
        %       an entry is available, the menu corresponding menu item
        %       will be chosen without waiting for a user input; otherwise,
        %       a user input will still be required)
        %
        % Returns:
        %   repfun.Menu: The menu

            if nargin < 2
                displayMenu = true;
            end
            if nargin < 3
                displayChoice = true;
            end
            if nargin < 4
                displayFailure = false;
            end
            if nargin < 5
                acceptNumbers = true;
            end
            acceptNumbers = acceptNumbers && (size(this.entries,1) <= 9);
            if nargin < 6
                lastRequest = true;
            end
            if nargin < 7
                acceptScriptEntries = true;
            end
            
            if displayMenu
                this.displayMenu;
            end
            
            answer = 0;
            while answer == 0

                character = '';
                if acceptScriptEntries
                    character = repfun.globals.menuScript('get');
                end
                if isempty(character)
                    % get user input
                    w = false;
                    while ~w
                        w = waitforbuttonpress;
                    end
                    character = get(gcf, 'CurrentCharacter');
                end

                if this.ignoreCase
                    character = upper(character);
                end
                
                % check if user input is valid and accept it
                if length(character) == 1
                    nbEntries = size(this.entries, 1);
                    for i = 1:nbEntries
                        if isequal(character, this.entries{i,1}) || (acceptNumbers && isequal(character, num2str(i)))
                            answer = i;
                            break;
                        end
                    end
                end
                
                if (answer == 0) && displayFailure
                    fprintf(character);
                    this.nbDisplayedInputsSinceMenu = this.nbDisplayedInputsSinceMenu + 1;
                    if mod(this.nbDisplayedInputsSinceMenu, 70) == 0
                        disp(' ');
                    end
                end
            end
            
            if displayChoice
                fprintf(character);
                this.nbDisplayedInputsSinceMenu = this.nbDisplayedInputsSinceMenu + 1;
                if mod(this.nbDisplayedInputsSinceMenu, 70) == 0
                    disp(' ');
                end
            end
            if lastRequest
                disp(' ');
                disp(' ');
            end
            this.entries{answer, 3}();
            choice = character;
            item = answer;
        end
        
    end
    
end
