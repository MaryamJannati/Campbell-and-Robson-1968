function s = deg2pix(angle, distance, screenInches)
    screenNumber = max(Screen('Screens')); 
    [screenWidthPixels, screenHeightPixels] = Screen('WindowSize', screenNumber);                 
    screenDiagonalPixels = sqrt(screenWidthPixels^2 + screenHeightPixels^2);          
    ppi = screenDiagonalPixels / screenInches;     
    theta_rad = angle * pi / 180;  
    S_physical = 2 * distance * tan(theta_rad / 2);          
    s = S_physical * ppi / 2.54;      
end