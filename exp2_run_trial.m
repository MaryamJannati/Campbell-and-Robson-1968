function [data] = exp2_run_trial(win, chosenScreen, one_deg2Pix, data, iblock, trial_index, wave, contrast, ...
    freq, xp, yp, size_patch, centerX, centerY, phase)

% -----set optional phase input-----

if nargin < 15 || isempty(phase)
     phase = rand() * 2 * pi;
end
% s = rng("default"); % set default seed for generating the same random variables each time
duty      = rand();
% rng (s);

PsychDefaultSetup(2); % openGL, unifyKeyNames, normalized color range

% -----patch rect-----
prect  = CenterRectOnPoint([0 0 size_patch size_patch], centerX, centerY);

% --define luminance--
white = WhiteIndex (chosenScreen); % 255(1) in an 8bits screen
black = BlackIndex (chosenScreen); % 0 in an 8bits screen
grey  = white/2;

% -----define the mask-----
mask = raised_cosine(size_patch, xp, yp);


% -----general parameters-----
isi         = 0.2; % stimulus presentation time
iti         = 0.2; % time between two stimulus interval in one trial
fi          = 0.2; % fixation pause time
cpp         = freq / one_deg2Pix; % cycle per pixel
s_interval = randi(2);



% -----trial-----

% --stimulus interval randomization and grating creation--

if s_interval == 1
    [g1] = create_grating(wave, contrast, cpp, xp, duty, phase); 
    [g2] = create_grating('sine', contrast, cpp, xp, duty, phase); 
else
    [g1] = create_grating('sine', contrast, cpp, xp, duty, phase);
    [g2] = create_grating(wave, contrast, cpp, xp, duty, phase);
end


% --applying raised cosine mask--
masked_grating1 = g1 .* mask + grey .* (1- mask);   
masked_grating2 = g2 .* mask + grey .* (1- mask);

% --make texture and flip the gratings--

% --fixation frame--
draw_frame(win, prect, 20, 4);
Screen('Flip', win);
WaitSecs(fi);

% blank page inter trial        
Screen('FillRect', win, grey);  
Screen('Flip', win);
WaitSecs(iti);

% interval 1 
draw_frame(win, prect, 20, 4);
tex1 = Screen('MakeTexture', win, masked_grating1);
Screen('DrawTexture', win, tex1, [], prect);
Screen('Flip', win);
% --beep--
Beeper('low', 0.5, isi);
WaitSecs(isi);
            
% blank page inter trial        
Screen('FillRect', win, grey);  
Screen('Flip', win);
WaitSecs(iti);
           
% interval 2
draw_frame(win, prect, 20, 4);  
tex2 = Screen('MakeTexture', win,  masked_grating2);
Screen('DrawTexture', win, tex2, [], prect);
Screen('Flip', win);        
% --beep--
Beeper('med', 0.5, isi);
WaitSecs(isi);

% question
Screen('FillRect', win, grey);                 
Screen('TextSize', win, 30);
Screen('TextFont', win, 'Times New Roman'); 


if strcmp(wave, 'sawtooth')                     
    lines = {
        'The sawtooth pattern was in:', ...
        ' press 1 = interval 1    press 2 = interval 2' ...
        }; 
elseif strcmp(wave, 'square') 
    lines = {
        'The square pattern was in interval:', ...
        ' Key (1) = interval 1    Key (2) = interval 2' ...
        }; 
end

for j = 1:length(lines)
        yOffset = (j - length(lines) / 2 - 0.5) * 100;
        yPosition = centerY + yOffset;
        DrawFormattedText(win, lines{j}, 'center', yPosition, black);
end
Screen('Flip', win);


% -----collecting answers and reaction times-----
questionTimeWindow = GetSecs;

while true
    [keyIsDown, pressTime, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(KbName('1!'))
            resp = 1;
        elseif keyCode(KbName('2@'))
            resp = 2;
        elseif keyCode(KbName('ESCAPE'))
            error('UserTerminated');
        else
            resp = NaN;
        end           
        
        rt = pressTime - questionTimeWindow;
        % Wait for a key to be released
        while KbCheck
            % wait for release
        end
        releaseTime = GetSecs;
        keyHold = releaseTime - pressTime;
        relreleaseTime = releaseTime - questionTimeWindow;
              
break;
    end
end    
ListenChar(2); % don't type in command window

is_correct = (resp == s_interval);       

duty = NaN;
  
disp('isCorrect (0== No; 1==Yes):');
disp(is_correct);

data{trial_index} = struct( ... 
                   'block', iblock, ...
                   'trial', trial_index, ...
                   'wave_type', wave, ...
                   'spatial_frequency', freq, ...
                   'contrast', contrast, ...
                   'phase', phase, ...                   
                   'duty_cycle', duty, ...
                   'stimulus_interval', s_interval, ...
                   'response', resp, ...
                   'is_correct', is_correct, ...
                   'reaction_time', rt, ...
                   'key_release_time', relreleaseTime, ...
                   'key_hold_duration', keyHold ...                   
                   );        

end

