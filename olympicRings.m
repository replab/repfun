function olympicRings
% This scripts provides a way to play with olympic rings, a fun
% generalization of the hungarian rings

replab_init;

% We keep in memory the rings once they are computed (can take ~1h the
% first time)
persistent or

% This option allows to save the persistant variable to the file
% olympicRings.mat. This file should be erased every time a different
% version of RepLAB is used.
saveDataInFile = true;
saveDataInFile = saveDataInFile && ~repfun.util.isOctave; % This functionality is not supported by octave
dataFilename = 'olympicRingsData.mat';

% We try to load any existing cubes
if isempty(or) && saveDataInFile && exist(dataFilename, 'file')
    file = load(dataFilename);
    or = file.or;
end

% We will use figure number 1
figNumber = 1;
h = figure(figNumber);
set(h, 'keypressfcn', @(E,F) evalin('base', ['repfun.util.lastKeyPressed(', num2str(figNumber), ', ''set'', ''', F.Key, ''');']));
% A clean figure with 16:9 aspect ratio
currentPosition = get(gcf, 'Position');
set(gcf, 'Position', [currentPosition([1 2]) round(currentPosition(4)*16/9), currentPosition(4)]);
clf;

% We create the rings
if isempty(or)
    or = repfun.OlympicRings(figNumber);
    if saveDataInFile
        % Save the cube
        save(dataFilename, 'or');
    end
else
    or.plot;
end

% Clear any previous capture
repfun.globals.capturing(false);
repfun.util.captureGcf('clear');

% We prepare the main menu
newline = char(10);
disp([newline, ...
      'Welcome to the olympic rings solver ', newline, ...
      newline, ...
      'To interact with this menu, press the key corresponding to the', newline, ...
      'desired action while keeping the rubik''s cube figure active.', newline, ...
      newline]);
title = 'What would you like to do?';
items = {{'M', 'Display the menu'}, {'H', 'Shuffle the rings'}, ...
         {'S', 'Solve the rings'}, {'C', 'Capture frames to video'}, ...
         {'Q', 'Quit'}};
menu = repfun.Menu(title, items{:});
menu.displayMenu;

% We get the current parameters
defaultTimePiRotation = repfun.orings.globals.timePiRotation;

% The menu loop
while true
    choice = menu.getChoice(false, true, false, false, false);

    switch choice
        case 'M'
            disp(' ');
            disp(' ');
            menu.displayMenu;
        case 'H'
            or = or.shuffle;
        case 'S'
            if (repfun.globals.verbose >= 1) && isempty(or.sequence)
                disp(' ');
            end
            or = or.solve;
            disp(' ');
            or = or.animate;
        case 'C'
            disp(' ');
            if ~repfun.globals.capturing
                repfun.util.captureGcf('clear');
                
                % We tune the parameters accordingly
                repfun.orings.globals.timePiRotation(0.4);
                repfun.globals.capturing(true);
                repfun.globals.clock('init');
                disp('Start capturing');
            else
                repfun.globals.capturing(false);
                disp('Stop capturing');
                repfun.util.captureGcf('save');
                
                % We restore settings for best interaction comfort
                repfun.orings.globals.timePiRotation(defaultTimePiRotation);
            end
        case 'Q'
            disp(' ');
            disp(' ');
            return;
    end
end
        
