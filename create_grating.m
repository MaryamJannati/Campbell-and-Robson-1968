function [g] = create_grating (waveType, contrast, cpp, xp, duty, phase)

% Screen ('ColorRange', win, 1, [], 1); % normalize the color range

% -----parameters-----
mean_lum = 0.5;
amplitude = mean_lum * contrast;    
    
    switch waveType
        case 'sine'
            g = mean_lum + amplitude * sin(2 * pi * cpp * xp + phase);
        case 'square'
            g = mean_lum + amplitude * square(2 * pi * cpp * xp + phase);
        case 'rectangular'                                     
            g = mean_lum + amplitude * square(2 * pi * cpp * xp + phase, duty * 100);           
        case 'sawtooth'
            g = mean_lum + amplitude * sawtooth(2 * pi * cpp * xp + phase);
    end
