function mask = raised_cosine(size_patch, xp, yp)
   
    radius = sqrt(xp.^2 + yp.^2);
    % Define flat and edge regions
    flatRadius = (size_patch/2) * 0.5;  % central 50% flat
    edgeRadius = (size_patch/2) * 0.5;  % outer 50% for cosine taper
    mask = ones(size(radius));
    % Apply cosine taper for outer region
    idx = radius > flatRadius;
    mask(idx) = 0.5 * (1 + cos(pi * (radius(idx) - flatRadius) / edgeRadius));
    % Set outside patch to zero
    mask(radius > (flatRadius + edgeRadius)) = 0;
end
