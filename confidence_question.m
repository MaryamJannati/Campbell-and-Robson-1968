function question = confidence_question(win, centerY, bgColor,txtColor)

     Screen('FillRect', win, bgColor);
     Screen('Flip', win);
     WaitSecs(0.2);
     
     Screen('TextSize', win, 30);
     Screen('TextFont', win, 'Times New Roman');
     % Display the question
     lines = {
         'How confident are you about your answer?', ...
         ' Key (1) = NOT so confident', ...
         ' Key (2) = ALMOST confident',...
         'key (3) = VERY confident' ...
          }; 
      lineSpacing = 80;
      for i = 1:length(lines)
           yOffset = (i - length(lines) / 2 - 0.5) * lineSpacing; 
            yPosition = centerY + yOffset;
           DrawFormattedText(win, lines{i}, 'center', yPosition, txtColor);
      end
        
        Screen('Flip', win);        
    % Wait for key press
   PsychDefaultSetup(2); % openGL, unifyKeyNames, normalized color range

    question = NaN;
    while true
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(KbName('ESCAPE'))
                 error('UserTerminated');
            elseif keyCode(KbName('3#'))
                question = 3;  % Very confident
            elseif keyCode(KbName('2@'))
                question = 2;  % Almost
            elseif keyCode(KbName('1!'))
                question = 1;  % Not so confident           
            end
            while KbCheck; end  % Wait for key release
            break;
        end
    end
    ListenChar(2);
end

