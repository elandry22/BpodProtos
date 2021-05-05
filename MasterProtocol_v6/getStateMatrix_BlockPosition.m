function [sma, params] = getStateMatrix_BlockPosition(params, trialType, trialNum)
global S BpodSystem
%% OUTLINE
% motor moves lickport to 1 of 5 positions every 50 trials. All 5 positions
% are visited before repeating a position

%% STATE MATRIX

% works with teensy setup
NumPositions = S.GUI.NumPositions;
SerialPort = S.GUI.SerialPort; % Module 2 for motor control

% setup
if trialNum==1 || mod(trialNum-1,S.GUI.blocksize) == 0
    positions = getLickPortPositions();  %(numPos,(x,y))
    cmds = defineSerialCommands(trialType,positions);
end
actions = getActions();
outputs = getOutputs(trialType, params);

sma = NewStateMatrix();
sma = setTimers(sma, params); % set up timers for trial start and stimulation
sma = addTrialStartStates(sma, params.bit, trialNum); % location dependent starting states

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % INITIAL STATE AND MOTOR STATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if trialNum==1 || mod(trialNum-1,S.GUI.blocksize) == 0
    sma = AddState(sma, 'Name', 'InitialState', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'GoToXPos'},...
        'OutputActions', []);
    sma = AddState(sma, 'Name', 'GoToXPos', 'Timer', 0.3,...
        'StateChangeConditions', {'Tup', 'GoToYPos'},...
        'OutputActions', {BpodSystem.Modules.Name(SerialPort), cmds.x});
    sma = AddState(sma, 'Name', 'GoToYPos', 'Timer', 0.3,...
        'StateChangeConditions', {'Tup', 'PreSample'},...
        'OutputActions', {BpodSystem.Modules.Name(SerialPort), cmds.y});
else
    sma = AddState(sma, 'Name', 'InitialState', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'PreSample'},...
        'OutputActions', []);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % PRE SAMPLE AND PRE SAMPLE STOP LICKING STATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sma = AddState(sma, 'Name', 'PreSample', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup','StopLickingPreSample'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'StopLickingPreSample', 'Timer', 0.99,...
    'StateChangeConditions', {'Port1In', 'StopLickingReturnPreSample','Tup','Sample'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'StopLickingReturnPreSample', 'Timer', 0.1,...
    'StateChangeConditions', {'Tup','StopLickingPreSample'},...
    'OutputActions', []); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % SAMPLE AND SAMPLE STOP LICKING STATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sma = AddState(sma, 'Name', 'Sample', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup','StopLickingSample'},...
    'OutputActions', outputs.SampleOutput);

sma = AddState(sma, 'Name', 'StopLickingSample', 'Timer', 3,...
    'StateChangeConditions', {'Port1In', 'StopLickingReturnSample','Tup','GoCue'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'StopLickingReturnSample', 'Timer', 0.1,...
    'StateChangeConditions', {'Tup','StopLickingSample'},...
    'OutputActions', []); 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % GO CUE STATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% provides individually scaled amount of water out of correct port if cue
% is water droplet. plays go cue sound if selected. starts stimulation
% timer if stim trial
if ~isempty(outputs.CueOutput)
    if isfield(outputs, 'WaterValveTime')
        sma = AddState(sma, 'Name', 'GoCue', 'Timer', outputs.WaterValveTime,... % only drops water if water drop cue
            'StateChangeConditions', {'Tup', actions.ActionAfterCue},...
            'OutputActions', outputs.CueOutput);
    else
        sma = AddState(sma, 'Name', 'GoCue', 'Timer', 0.01,... % only drops water if water drop cue
            'StateChangeConditions', {'Tup', actions.ActionAfterCue},...
            'OutputActions', outputs.CueOutput);
    end
else
    sma = AddState(sma, 'Name', 'GoCue', 'Timer', 0.01,... %
        'StateChangeConditions', {'Tup', actions.ActionAfterCue},...
        'OutputActions', []);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % POST GO CUE STATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% these states only accessed when autowater is on
% amount of time spent in state is how long valve is open for
sma = AddState(sma, 'Name', 'GiveLeftDropShort', 'Timer', outputs.LeftValveTime*S.GUI.AutoWaterScale,...
    'StateChangeConditions', {'Tup', 'AnswerPeriod'},...
    'OutputActions', outputs.LeftWaterOutput); % free reward left
sma = AddState(sma, 'Name', 'GiveRightDropShort', 'Timer', outputs.RightValveTime*S.GUI.AutoWaterScale,...
    'StateChangeConditions', {'Tup', 'AnswerPeriod'},...
    'OutputActions', outputs.RightWaterOutput); % free reward right

% keeps Bpod from reacting to inactive port2
sma = AddState(sma, 'Name', 'AnswerPeriod', 'Timer', S.GUI.AnswerPeriod,...
    'StateChangeConditions', {'Port1In','LickedLeft','Tup','NoResponse'},...% send them to stopLickingReturn? do we want them to lick at least once? should that be a parameter? or lick as many times as they want?
    'OutputActions', []);

if S.GUI.SpontCueType==1 % water drop cue, water came out at go cue
    sma = AddState(sma, 'Name', 'LickedLeft', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', actions.LeftLickAction},...
        'OutputActions', []);
    sma = AddState(sma, 'Name', 'LickedRight', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', actions.RightLickAction},...
        'OutputActions', []);
    sma = AddState(sma, 'Name', 'Reward', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'StopLicking'},...
        'OutputActions', []);
else
    sma = AddState(sma, 'Name', 'LickedLeft', 'Timer', outputs.LeftValveTime,...
        'StateChangeConditions', {'Tup', 'Reward'},...
        'OutputActions', outputs.LeftResponse);
    sma = AddState(sma, 'Name', 'LickedRight', 'Timer', outputs.RightValveTime,...
        'StateChangeConditions', {'Tup', 'Reward'},...
        'OutputActions', outputs.RightResponse);
    sma = AddState(sma, 'Name', 'Reward', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'StopLicking'},...
        'OutputActions', []);
end

% only accessed if water drop cue and mouse then licks opposite port
sma = AddState(sma, 'Name', 'TimeOut', 'Timer', S.GUI.TimeOut,...
    'StateChangeConditions', {'Tup', 'StopLicking'},...
    'OutputActions', []);


% stop licking after answer period, keeps Bpod from reacting to inactive port2
sma = AddState(sma, 'Name', 'StopLicking', 'Timer', S.GUI.StopLickingPeriod,...
    'StateChangeConditions', {'Port1In', 'StopLickingReturn','Tup','ITI'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'StopLickingReturn', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup','StopLicking'},...
    'OutputActions', []); 

sma = AddState(sma, 'Name', 'NoResponse', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'ITI', 'Timer', params.ITI,...
    'StateChangeConditions', {'Tup', 'TrialEnd'},...
    'OutputActions', []);

% states that can't be reached, for posterity for reading Bpod data
% (expPipeline.m)

sma = AddState(sma, 'Name', 'EarlyLickSample', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'TrialEnd'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'EarlyLickDelay', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'TrialEnd'},...
    'OutputActions', []);

sma = addTrialEndStates(sma);




end % getStateMatrix_BlockPosition

%% HELPER FUNCTIONS

function positions = getLickPortPositions()
    global S

    numPos = S.GUI.NumPositions;
    theta_deg = S.GUI.deltaTheta; % degrees
    radius = S.GUI.arcRadius; % mm
    cx = S.GUI.cx; % initial pos of axis 1 - read from zaber console
    cy = S.GUI.cy; % initial pos of axis 2
    
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
    positions = lp_pos;
end  % getLickPortPositions

function cmds = defineSerialCommands(trialType,positions)

    cmdNums = {'1', '2'}; % for LickSequence
    LoadSerialMessages(2, cmdNums);
    
    Message1 = ['a' num2str(positions(trialType,1))]; % axis 1 abs pos
    Message2 = ['b' num2str(positions(trialType,2))]; % axis 2 abs pos
    
    % establish serial connection with teensy and send messages
    s = serial('COM9','BaudRate',115200); % set correct Teensy COM port
    fopen(s);
    fprintf(s,Message1);
    pause(0.1)
    fprintf(s,Message2);
    pause(1)
    fclose(s);
%     % close serial connections
%     if ~isempty(instrfind)
%        fclose(instrfind);
%        delete(instrfind);
%     end
    
    cmds.x = 1;
    cmds.y = 2;
%     "/01 1 01 move abs "
% "/01 2 01 move abs "

end  % defineSerialCommands

function actions = getActions()
    global S
    
    actions.LeftLickAction = 'Reward';
    actions.RightLickAction = 'TimeOut';
    actions.ActionAfterCue = 'AnswerPeriod';
    if S.GUI.Autowater == 1 % give small drop of free water on L
        actions.ActionAfterCue = 'GiveLeftDropShort';
    end

end % getActions

function outputs = getOutputs(trialType, params)
    global S
    
    % for 1 lick port, outputs.RightResponse cleared at end of function
    outputs.LeftWaterOutput = {'ValveState',2^0};  
    outputs.RightWaterOutput = {'ValveState',2^1}; 
    outputs.CueOutput = [];
    
    if S.GUI.SpontCueType==1 % water drop cue
        outputs.CueOutput = outputs.LeftWaterOutput;
        outputs.WaterValveTime = S.GUI.WaterValveTime*S.GUI.LeftPortScale;
        outputs.LeftResponse = [];
        outputs.RightResponse = [];
    elseif S.GUI.SpontCueType==2 % None
        outputs.CueOutput = [];
        outputs.LeftResponse = outputs.LeftWaterOutput;
        outputs.RightResponse = outputs.RightWaterOutput;
        outputs.LeftValveTime = S.GUI.WaterValveTime*S.GUI.LeftPortScale;
        outputs.RightValveTime = S.GUI.WaterValveTime*S.GUI.RightPortScale;
    else  % go Cue
        outputs.CueOutput = {'PWM4', 255};
        outputs.LeftResponse = outputs.LeftWaterOutput;
        outputs.RightResponse = outputs.RightWaterOutput;
        outputs.LeftValveTime = S.GUI.WaterValveTime*S.GUI.LeftPortScale;
        outputs.RightValveTime = S.GUI.WaterValveTime*S.GUI.RightPortScale;
        outputs.SampleOutput = {'PWM2', 255};
    end
    
    % add BNCState 2 at go cue for any cue for analysis
    if ~isempty(outputs.CueOutput)
        outputs.CueOutput = [outputs.CueOutput, 'BNCState',2];
    else
        outputs.CueOutput = {'BNCState', 2};
    end

    
    if S.GUI.NumLickPorts == 1
        outputs.RightResponse = [];
    end

end % getOutputs 












