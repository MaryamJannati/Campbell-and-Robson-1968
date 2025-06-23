% FIXME   : convert timing from time to frame number
% ADDTOME : instructions

input("Are you ready to run the experiment? y/n: ","s");
% -----current dir-----
cd '/Users/nip-maryam/Documents/NIP lab Felix Wichmann/Campbell_Robson_1967/experiment';

% -----dir to save-----
timestamp = datetime("today");
saveDir   = '/Users/nip-maryam/Documents/NIP lab Felix Wichmann/Campbell_Robson_1967/data';

% -----setting up the mac keyboard-----
%deviceIndices  = GetKeyboardIndices();
%keyboardDevice = deviceIndices(1);  % Use the first keyboard device

% -----get info-----
prompt    = {'Participant ID:','Viewing distance (cm) :', 'Screen inches:', 'Patch size (deg):', ...
    'Number of trials:', 'Number of blocks:'};
dlgtitle  = 'Input';
fieldsize = [1 60; 1 60; 1 60; 1 60; 1 60; 1 60];
definput  = {'','50','13','10', '2', '2'};
info      = inputdlg(prompt,dlgtitle,fieldsize,definput);

% -----file names to save data-----
file_name = sprintf('%s_%s_experiment1_2afc.csv', char(info(1)), timestamp);
file_path = fullfile(saveDir, file_name);

% -----visual degree to pixel and patch coordinates-----
vdeg        = str2double(info(4)); % size in degree
dis         = str2double(info(2)); % distance
inch        = str2double(info(3)); % screen inches

one_deg2Pix = deg2pix (1, dis, inch); 
size_patch  = deg2pix (vdeg, dis, inch); 

x           = -size_patch/2 : size_patch/2-1;
y           = -size_patch/2 : size_patch/2-1;
[xp, yp]    = meshgrid(x, y);

% -----sound-----
% --Initialize PsychPortAudio--
InitializePsychSound(1);
isi = 0.2;

% -----PTB-----

% --sync tests--
% VBLSyncTest()
% PerceptualVBLSyncTest()
Screen('Preference', 'SkipSyncTests', 1); % set to 0 in actual experiment

% --default setting--
PsychDefaultSetup(2); % openGL, unifyKeyNames, normalized color range

% --screen--
getScreens   = Screen ('Screens');
chosenScreen = max (getScreens); % external screen has the max number

% --define luminance--
white = WhiteIndex (chosenScreen); % 255(1) in an 8bits screen
black = BlackIndex (chosenScreen); % 0 in an 8bits screen
grey  = white/2;


% --window--
[win, rect]        = PsychImaging('OpenWindow', chosenScreen, grey, []); 
[centerX, centerY] = RectCenter(rect);

% --processing preference--
Priority(MaxPriority(win));

% --refresh rate--
ifi = Screen('GetFlipInterval', win); % inter-frame interval
Hz  = FrameRate(win); % the refresh rate of the screen

% -----experiment parameters-----
wave_type   = {'square', 'sawtooth'};
contrasts   = [0.5, 1]; % method of constant stimuli - suprathreshold
frequencies = 0.5:0.5:10;      % 0.5:0.5:10;
data        = [];
trial_index = 1;
numBlocks = str2double (info (6));
numTrials = str2double (info (5));

% -----instructions-----

% -----experiment loop-----
try
for iblock = 1:numBlocks
     disp(['Starting block ', num2str(iblock)]);
    for itrial = 1:numTrials
        % rng (s);
        for iwave = 1:length(wave_type)
            rwd   = randperm(length(wave_type)); % random distribution of the wave types1
            wave  = wave_type(rwd);
            wave  = wave {iwave};
            disp ('grating shape:')
            disp (wave); 
            rci       = randi(length(contrasts)); % random integer
            contrast  = contrasts(rci); % choose a random scalar contrast from contrasts' vector
            rfi       = randi(length(frequencies));
            freq      = frequencies(rfi);
            [data] = exp2_run_trial(win, chosenScreen, one_deg2Pix, data, iblock, trial_index, ...
                wave, contrast, freq, xp, yp, size_patch, centerX, centerY);

            data{trial_index}.confidence = NaN;
            question = confidence_question(win, centerY, grey, black); % display the confidence question
            % --beep--
            Beeper('high', 0.5, isi);
            % --
            data{trial_index}.confidence = question;            
            WaitSecs(0.5);
            trial_index = trial_index + 1;               
            
        end
        WaitSecs(0.5); % wait before next trial
    end
   if iblock < numBlocks
        Screen('FillRect', win, grey);
        Screen('TextSize', win, 50); 
        Screen('TextFont', win, 'Times New Roman'); 
             lines = {
                'You can take some time to rest now.', ...
                'When you are ready, press any key to continue the experiment!', ...
                'Or press the (esc) key to stop the experiment.'
                 };
        lineSpacing = 100;
              for i = 1:length(lines)
                   yOffset = (i - length(lines) / 2 - 0.5) * lineSpacing; 
                    yPosition = centerY + yOffset;
                   DrawFormattedText(win, lines{i}, 'center', yPosition, black);
              end
        Screen('Flip', win);

   while true
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(KbName('ESCAPE'))               
                % save data
                data = [data{:}];
                data = struct2table(data);
                writetable (data,file_path);
                sca;
                error('Experiment terminated by user.'); 
            else
                break;
            end
        end
   end
   end
end
catch ME
    if strcmp(ME.message, 'UserTerminated')
        disp('Experiment terminated early by user. Saving data...');
    else
        rethrow(ME);  % Rethrow unexpected errors
    end

end

% Save data and close screen
data = [data{:}];
data = struct2table(data);
writetable (data,file_path);

sca;

