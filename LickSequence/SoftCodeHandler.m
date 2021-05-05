function SoftCodeHandler(Byte)

global BpodSystem S

trialnum = BpodSystem.Data.trialNumber;
trialtype = BpodSystem.Data.trialType;

if Byte < 10
    switch Byte
        case 1
            ypos = 1;
        case 2
            ypos = 2;
        case 3
            ypos = 3;
        case 4
            ypos = 4;
        case 5
            ypos = 5;
    end
    switch trialtype
        case 0
            ypos = 10-ypos;
    end
    xdat = get(BpodSystem.GUIHandles.lickRasters{trialnum}, 'XData');
    ydat = get(BpodSystem.GUIHandles.lickRasters{trialnum}, 'YData');
    
    
    set(BpodSystem.GUIHandles.lickRasters{trialnum}, 'XData', [xdat trialnum], 'Ydata', [ydat ypos], 'Color', 'k');
    
    
elseif Byte == 10
    set(BpodSystem.GUIHandles.lickRasters{trialnum}, 'Color', 'g');
end

if Byte == 11
% Send Motor Command Values with Arduino Code "LickSequence"
    centerX = S.GUI.centerX; % mm
    deltaX = S.GUI.deltaX; % mm
    stepSize = 0.1905; % LSM type B
    
    Npositions = S.GUI.Npositions;
    if mod(Npositions,2) == 1
        relPosition = round(Npositions/2) - 1;
    else
        relPosition = (Npositions/2) - 0.5;
    end

    centerSteps = round(centerX/(stepSize/1000))
    deltaSteps = round(deltaX/(stepSize/1000));
    startSteps = centerSteps - 2*deltaSteps;
    stopSteps = centerSteps + 2*deltaSteps;
    
    Message1 = ['a' num2str(startSteps)]
    Message2 = ['b' num2str(stopSteps)]
    Message3 = ['c' num2str(deltaSteps)]

    s = serial('COM9','BaudRate',115200); % set correct Teensy COM port
    fopen(s)
    fprintf(s,Message1)
    pause(0.1)
    fprintf(s,Message2)
    pause(0.1)
    fprintf(s,Message3)
    fclose(s)
end

if Byte == 12
    % send motor command array
    s = serial('COM9','BaudRate',115200); % set correct Teensy COM port
    
    MessageArray = {'/1 01 move abs 100000\r',
                    '/1 01 move abs 200000\r',
                    '/1 01 move rel 10000\r',
                    '/1 01 move rel -10000\r'}
    nMessages = length(MessageArray);
    
    fopen(s);
    for i = 1:nMessages
        Message = char(MessageArray(i));
        fprintf(s,Message);
    end
    fclose(s);
end
