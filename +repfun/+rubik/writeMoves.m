function writeMoves(movesSequence, currentStep)
% This function adds text boxes to a figure with the previous and upcoming
% moves in the sequence
    
    whileMoving = (currentStep ~= round(currentStep));
    currentStep = floor(currentStep);
    
    if ~repfun.util.isOctave
        % Not supported by octave
        delete(findall(gcf,'type','annotation'));
    end
    
    if repfun.rubik.globals.darkMode
        color = [1 1 1];
    else
        color = [0 0 0];
    end

    annotation('textbox', [.8, .8, .1, .2], 'String', ['Step ', num2str(currentStep), '/', num2str(length(movesSequence))], ...
        'fontsize', 12, 'linestyle', 'none', 'color', color);
    
    if ~whileMoving
        if currentStep >= 2
            text = latexify(movesSequence{currentStep-1});
            annotation('textbox', [.12, .1, .2, .1], 'String', text, 'linestyle', 'none', 'color', color);
        end
        if currentStep >= 1
            text = latexify(movesSequence{currentStep});
            annotation('textbox', [.32, .1, .2, .1], 'String', text, 'fontsize', 15, 'linestyle', 'none', 'color', color);
        end
        if currentStep <= length(movesSequence)-1
            text = latexify(movesSequence{currentStep+1});
            annotation('textbox', [.62, .1, .2, .1], 'String', text, 'fontsize', 15, 'linestyle', 'none', 'color', color);
        end
        if currentStep <= length(movesSequence)-2
            text = latexify(movesSequence{currentStep+2});
            annotation('textbox', [.82, .1, .2, .1], 'String', text, 'linestyle', 'none', 'color', color);
        end
    else
        if currentStep >= 1
            text = latexify(movesSequence{currentStep});
            annotation('textbox', [.22, .1, .2, .1], 'String', text, 'fontsize', 12, 'linestyle', 'none', 'color', color);
        end
        if currentStep <= length(movesSequence)-1
            text = latexify(movesSequence{currentStep+1});
            annotation('textbox', [.47, .1, .2, .1], 'String', text, 'fontsize', 17, 'linestyle', 'none', 'color', color);
        end
        if currentStep <= length(movesSequence)-2
            text = latexify(movesSequence{currentStep+2});
            annotation('textbox', [.72, .1, .2, .1], 'String', text, 'fontsize', 12, 'linestyle', 'none', 'color', color);
        end
    end

    return;
    
    function move = latexify(move)
        levels = [num2str(move(2:end-1).'), ','*ones(length(move)-2,1)].';
        levels = levels(:).';
        levels = levels(1:end-1);
        if str2num(move(end)) == 1
%            move = [move(1), '_{', num2str(move(2:end-1).').', '}'];
            move = [move(1), '(', levels, ')'];
        elseif str2num(move(end)) ~= 3
%            move = [move(1), '_{', num2str(move(2:end-1).').', '}^', move(end)];
            move = [move(1), '(', levels, ')^', move(end)];
        else
%            move = [move(1), '_{', num2str(move(2:end-1).').', '}^{-1}'];
            move = [move(1), '(', levels, ')^{-1}'];
        end
    end
end
