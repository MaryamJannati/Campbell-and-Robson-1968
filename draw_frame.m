function draw_frame(win, prect, cornerLength, lineWidth)
    [left, top, right, bottom] = deal(prect(1), prect(2), prect(3), prect(4));
    Screen('DrawLine', win, [255 255 255], left, top, left+cornerLength, top, lineWidth);
    Screen('DrawLine', win, [255 255 255], left, top, left, top+cornerLength, lineWidth);
    Screen('DrawLine', win, [255 255 255], right, top, right-cornerLength, top, lineWidth);
    Screen('DrawLine', win, [255 255 255], right, top, right, top+cornerLength, lineWidth);
    Screen('DrawLine', win, [255 255 255], left, bottom, left+cornerLength, bottom, lineWidth);
    Screen('DrawLine', win, [255 255 255], left, bottom, left, bottom-cornerLength, lineWidth);
    Screen('DrawLine', win, [255 255 255], right, bottom, right-cornerLength, bottom, lineWidth);
    Screen('DrawLine', win, [255 255 255], right, bottom, right, bottom-cornerLength, lineWidth);
    %Screen('Flip', win);
end