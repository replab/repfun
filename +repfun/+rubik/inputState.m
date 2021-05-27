function state = inputState(d)
% This provides a simple interactive way of entering the state of a Rubik's cube

initialView = get(gca,'View');

% We prepare the menu
title = 'Please enter the color of the highlighted element';
if repfun.rubik.globals.darkMode
    items = {{'r', 'Red'}, {'y', 'Yellow'}, {'b', 'Blue'}, {'k', 'Black'}, {'g', 'Green'}, {'o', 'Orange'}, {'c', 'Cancel last color'}, {'q', 'Quit'}};
else
    items = {{'r', 'Red'}, {'y', 'Yellow'}, {'b', 'Blue'}, {'w', 'White'}, {'g', 'Green'}, {'o', 'Orange'}, {'c', 'Cancel last color'}, {'q', 'Quit'}};
end
menu = repfun.Menu(title, items{:});
menu.displayMenu;

views = {[115 45] [115 25] [150 25] [150+90 25] [150+180 25] [70 -45]};

state = 7*ones(1,6*d^2);
i = 0;
while i < 6*d^2
    i = i + 1;
    state(i) = 8;
    
    % Set the viewing angle to see the relevant part of the cube
    % This must be done ahead for octave, but should be done afterwards
    % with matlab... so a bit more complicated than needed.
    if mod(i-1, d^2) == 0
        repfun.rubik.rotateToView(d, views{1 + floor((i-1)/d^2)}, 0.5);
    end
    
    % Plot the current state of the cube
    repfun.rubik.plot(state);
    
    % Get the user's input
    [choice, item] = menu.getChoice(false, true, false, true, i==6*d^2);
    if item <= 6
        state(i) = item;
    elseif choice == 'C'
        state(i) = 7;
        i = i - 2 + (i == 1);
    elseif choice == 'Q'
        state = [];
        set(gca, 'View', initialView);
        return;
    end
    
    if (choice == 'C') && (mod(i+1, d^2) == 0)
        repfun.rubik.rotateToView(d, views{1 + floor(i/d^2)}, 0.5);
    end
end
disp(' ');
repfun.rubik.plot(state);

%disp(num2str(state))

pause(1);
repfun.rubik.rotateToView(d, initialView, 0.5);
