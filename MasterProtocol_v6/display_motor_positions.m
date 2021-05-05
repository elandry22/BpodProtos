function display_motor_positions(cx,cy)

stepSize = 0.1905e-3; % LSM type B; in mm

numPos = 5;
theta_deg = 35; % degrees
radius = 2.2 * 1000; % microns, arc radius (distance b/w mouse jaw/tongue to lickport at center)
    
ct = -floor(numPos/2);
angles = zeros(1,numPos);
for i=1:numPos
    angles(i) = 90 + (ct*theta_deg);
    if (angles(i) == 90)
        angles(i) = 0;
    end
    ct = ct + 1;
end

lp_pos = zeros(numPos, 2);
centerPos = ceil(numPos/2);
lp_pos(centerPos,1) = cx;
lp_pos(centerPos,2) = cy;
for i=1:numPos
    if i==centerPos
        continue
    end
    theta_rad = deg2rad(angles(i));
    delX = radius * cos(theta_rad);
    delY = radius - (radius * sin(theta_rad));
    % convert microns to microsteps
    delX_steps = delX / 0.1905;
    delY_steps = delY / 0.1905;
    % compute lickport positions
    lp_pos(i,1) = round(cx - delX_steps);
    lp_pos(i,2) = round(cy + delY_steps);
end

axis = lp_pos;

format long
axis = array2table(axis)
format short
end % display_motor_positions


