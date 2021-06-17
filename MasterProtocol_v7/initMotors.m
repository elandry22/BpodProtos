function initMotors(trialType)

% this function intializes the motors and command for the 
% lick sequence task
% trialType == 0 (right to left sequence)
% trialType == 1 (left to right sequence)

global S

numPos = S.GUI.NumPositions;
theta_deg = S.GUI.deltaTheta; % degrees
radius = S.GUI.arcRadius; % mm
cx = S.GUI.cx; % initial pos of axis 1 - read from zaber console
cy = S.GUI.cy; % initial pos of axis 2

import zaber.motion.Library;
import zaber.motion.ascii.Connection;
import zaber.motion.ascii.Stream;
import zaber.motion.Units;
import zaber.motion.Measurement;
import zaber.motion.ascii.StreamAxisDefinition;
Library.enableDeviceDbStore();

%% calculate lick port positions
radius = radius * 1000; % now in microns (input as mm)

ct = -floor(numPos/2);
angles = zeros(1,numPos);
for i=1:numPos
    angles(i) = 90 + (ct*theta_deg);
    if (angles(i) == 90)
        angles(i) = 0;
    end
    ct = ct + 1;
end
% left to right trials
if trialType == 1
    angles = flip(angles);
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

%% send commands to motor


% open serial connection
connection = Connection.openSerialPort('COM11');
% correct port can be found through Zaber Console
try
    % find device
    deviceList = connection.detectDevices();        
    device = deviceList(1);
    stream = device.getStream(1); 
    stream.disable();
    
    
    % send motors home and move relative commands
    % not sure why this is necessary but NI error without
    axis1 = device.getAxis(1);
    axis2 = device.getAxis(2);
    axis1.home();
    axis2.home();
    axis1.moveRelative(0, Units.NATIVE);
    axis2.moveRelative(0, Units.NATIVE);
    
    % setup stream, send commands
    stream.setupLive([1,2]);
%     streamAxis1 = streamAxisDefinition.getAxisNumber()
    stream.waitDigitalInput(1, true);
    for i = 1:numPos
        stream.lineAbsolute([
            Measurement(lp_pos(i,1), Units.NATIVE)
            Measurement(lp_pos(i,2), Units.NATIVE)
        ]);
        if i~=numPos
            stream.waitDigitalInput(1, true);
%             stream.wait(0.02, Units.TIME_SECONDS);
        end
    end
    
    % motor commands go above here
    connection.close();
catch exception
    connection.close();
    rethrow(exception);
end

end

