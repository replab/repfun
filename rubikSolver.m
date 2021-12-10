function rubikSolver
% This script provides an interactive way of solving Rubik's cubes

replab_init;

% We keep in memory any Rubik's cube that was computed once during the
% session
persistent cubes

% This option allows to save computed cubes to rubiSolverData.mat.
% This file should be erased every time a different version of RepLAB is used.
saveDataInFile = true;
saveDataInFile = saveDataInFile && ~repfun.util.isOctave; % This functionality is not supported by octave
dataFilename = 'rubikSolverData.mat';

% Number of cube configurations precomputed with the following code:
%     d = 4;
%     generators = repfun.rubik.generators(d);
%     selMinGens = repfun.util.fromSeveralBasesInversed(eye(d), 2*ones(1,d))*[1 1 1] + ones(d,1)*[0, 2^d-1, 2*(2^d-1)];
%     selMinGens = sort(selMinGens(:));
%     G = replab.PermutationGroup.of(generators{selMinGens});
%     trivGens = cell(1,12);
%     p1 = [2 1 3:d^2];
%     p2 = [2:d^2 1];
%     for i = 1:6
%         trivGens{2*i-1} = [1:(i-1)*d^2, (i-1)*d^2+p1, i*d^2+1:6*d^2];
%         trivGens{2*i} = [1:(i-1)*d^2, (i-1)*d^2+p2, i*d^2+1:6*d^2];
%     end
%     GTriv = replab.PermutationGroup.of(trivGens{:});
%     colorRelabellingGroup = G.intersection(GTriv);
%     G.order/colorRelabellingGroup.order/24
nbConfTxt = {'1', '3674160', '43252003274489856000', ...
    '7401196841564901869874093974498574336000000000', ...
    '282870942277741856536180333107150328293127731985672134721536000000000000000', ...
    '157152858401024063281013959519483771508510790313968742344694684829502629887168573442107637760000000000000000000000000'};

% Similarly we could compute the number of configurations which are
% compatible with an assignment of the first three faces with
%     threeFacesGen = {[1:3*d^2, 3*d^2+2, 3*d^2+1, 3*d^2+3:6*d^2], ...
%                      [1:3*d^2, 3*d^2+2:6*d^2, 3*d^2+1]};
%     GThreeFaces = replab.PermutationGroup.of(threeFacesGen{:});
%     threeFacesIntersection = G.intersection(GThreeFaces);
% There is only one such configuration for d=2.

% We try to load any existing cubes
if saveDataInFile && exist(dataFilename, 'file')
    file = load(dataFilename);
    cubes = file.cubes;
end

% We will use figure number 1
figNumber = 1;
h = figure(figNumber);
set(h, 'keypressfcn', @(E,F) evalin('base', ['repfun.util.lastKeyPressed(', num2str(figNumber), ', ''set'', ''', F.Key, ''');']));
clf;
if repfun.rubik.globals.strongPerspective
    % Make the figure square
    currentPosition = get(gcf, 'Position');
    set(gcf, 'Position', [currentPosition(1) currentPosition(2)+currentPosition(4)-416, 416 416]);
end
delete(findall(gcf, 'type', 'annotation'));
set(gca, 'view', repfun.rubik.globals.defaultView);

% We create a standard 3x3 cube to start
if repfun.util.isOctave
    d = 2;
else
    d = 3;
end
if isempty(cubes) || isempty(cubes{d})
    cubes{d} = repfun.Rubik(d, figNumber);
    if saveDataInFile
        % Save the cube
        save(dataFilename, 'cubes');
    end
else
    cubes{d}.plot;
end

% Clear any previous capture
repfun.globals.capturing(false);
repfun.util.captureGcf('clear');

% We prepare the main menu
newline = char(10);
disp([newline, ...
      'Welcome to the interactive Rubik''s cube solver', newline, ...
      newline, ...
      'To interact with this menu, press the key corresponding to the', newline, ...
      'desired action while keeping the rubik''s cube figure active.', newline, ...
      newline]);
title = 'What would you like to do?';
items = {{'M', 'Display the menu'}, {'D', 'Change the cube''s dimension'}, ...
         {'L', 'Toggle between light and dark mode'}, {'R', 'Rotate'}, {'B', 'Toggle between above and below view'}, ...
         {'I', 'Input a color configuration'}, {'H', 'Shuffle the cube'}, ...
         {'S', 'Solve the cube'}, {'T', 'Solve the cube interactively'}, ...
         {'C', 'Capture frames to video'}, {'Q', 'Quit'}};
menu = repfun.Menu(title, items{:});
menu.displayMenu;

% We get the current parameters
defaultNbSteps = repfun.rubik.globals.nbSteps;
defaultRotateLargeCubes = repfun.rubik.globals.rotateLargeCubes;

% The menu loop
while true
    choice = menu.getChoice(false, true, false, false, false);

    switch choice
        case 'M'
            disp(' ');
            disp(' ');
            menu.displayMenu;
        case 'D'
            disp(' ');
            disp(' ');
            fprintf('Enter the desired dimension: ');
            previousD = d;
            d = 0;
            while d < 2
                character = repfun.globals.menuScript('get');
                if isempty(character)
                    % get user input
                    w = false;
                    while ~w
                        w = waitforbuttonpress;
                    end
                    character = get(gcf, 'CurrentCharacter');
                end
                if ~isempty(str2num(character))
                    d = str2num(character);
                end
            end
            disp(num2str(d));
            if (d > length(cubes)) || isempty(cubes{d})
                if d >= 4
                    disp(['Preparing a ', num2str(d), 'x', num2str(d), ' Rubik''s cube, this might take some time...']);
                end
                cubes{d} = repfun.Rubik(d, figNumber);
                if saveDataInFile
                    % Save the new cube
                    save(dataFilename, 'cubes');
                end
            else
                cubes{d}.plot;
            end
            % Adjusting the figure's size
            %currentPosition = get(gcf, 'Position');
            %factorPosition = d/previousD;
            %set(gcf, 'Position', [currentPosition(1) currentPosition(2)+(1-factorPosition)*currentPosition(4), factorPosition*currentPosition(3:4)]);
            % Print some info about the cube symmetry
            if repfun.globals.verbose >= 1
                disp(' ');
                disp(['Rubik''s cube of size ', num2str(d), '.']);
                if d <= length(nbConfTxt)
                    % We know the number of configurations
                    disp('Number of distinct cube configurations:');
                    disp(['    ', nbConfTxt{d}]);
                end
                orderTxt = num2str(cubes{d}.chain.order).';
                orderTxt = strrep(orderTxt(:).', ' ', '');
                disp('The group order is:')
                disp(['    ', orderTxt]);
            end
            disp(' ');
            menu.displayMenu;
        case 'L'
            repfun.rubik.globals.darkMode(~repfun.rubik.globals.darkMode);
            cubes{d}.plot;
        case 'R'
            repfun.rubik.rotateToView(d, get(gca, 'view'));
        case 'B'
            view = get(gca, 'View');
            repfun.rubik.rotateToView(d, [view(1), -view(2)], 0.3);
        case 'I'
            disp(' ');
            newState = repfun.rubik.inputState(d);
            if ~isempty(newState)
                cubes{d} = cubes{d}.setState(newState);
            else
                % Replot previous state
                cubes{d}.plot;
            end
            disp(' ');
            menu.displayMenu;
        case 'H'
            cubes{d} = cubes{d}.shuffle;
        case 'S'
            if (repfun.globals.verbose >= 1) && isempty(cubes{d}.sequence)
                disp(' ');
            end
            cubes{d} = cubes{d}.solve;
            disp(' ');
            cubes{d} = cubes{d}.animate;
        case 'T'
            disp(' ');
            cubes{d} = cubes{d}.solve;
            if repfun.globals.verbose >= 1
                disp(' ');
            end
            cubes{d} = cubes{d}.interactiveEvolution;
            disp(' ');
            menu.displayMenu
        case 'C'
            disp(' ');
            if ~repfun.globals.capturing
                repfun.util.captureGcf('clear');
                
                % We tune the parameters accordingly
                repfun.rubik.globals.nbSteps(round([1 1.5 1]*repfun.rubik.globals.time90degreesRotation*repfun.globals.framesPerSecond));
                repfun.rubik.globals.rotateLargeCubes(true);
                repfun.globals.capturing(true);
                repfun.globals.clock('init');
                disp('Start capturing');
            else
                repfun.globals.capturing(false);
                disp('Stop capturing');
                repfun.util.captureGcf('save');
                
                % We restore settings for best interaction comfort
                repfun.rubik.globals.nbSteps(defaultNbSteps);
                repfun.rubik.globals.rotateLargeCubes(defaultRotateLargeCubes);
            end
        case 'Q'
            disp(' ');
            disp(' ');
            return;
    end
end

