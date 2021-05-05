function [sma, params] = getStateMatrix_LickSequence(params, TrialType, TrialNum)
global S BpodSystem
% works with teensy setup
NumPositions = S.GUI.NumPositions;
SerialPort = S.GUI.SerialPort; % Module 2 for motor control

cmds = defineSerialCommands(TrialType);

actions = getActions(params.Nlicks);
outputs = getOutputs(TrialType, SerialPort, cmds, params);


sma = NewStateMatrix();
sma = setTimers(sma, params);
sma = addTrialStartStates(sma, params.bit, TrialNum);

sma = AddState(sma, 'Name', 'InitialState', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'GoToStartPos'},...
    'OutputActions', []);


% sma = AddState(sma, 'Name', 'SendMotorCommands', ...
%     'Timer', 1,...
%     'StateChangeConditions', {'Tup','TrigTrialStart'},...
%     'OutputActions', {'SoftCode', 11});

% sma = AddState(sma, 'Name', 'TrigTrialStart', ...
%     'Timer', 1,...
%     'StateChangeConditions', {'Tup','GoCue'},...
%     'OutputActions', {BpodSystem.Modules.Name(SerialPort) , StartCode, 'SoftCode', 1});

sma = AddState(sma, 'Name', 'GoToStartPos', ...
    'Timer', 1,...
    'StateChangeConditions', {'Tup','GoCue'},...
    'OutputActions', outputs.GoToStartPos);

sma = AddState(sma, 'Name', 'StopLickingBefore', 'Timer', S.GUI.StopLickingPeriod,...
    'StateChangeConditions', {'Port1In', 'StopLickingBeforeReturn','Tup', 'GoCue'},...
    'OutputActions', []); % stop licking before advancing to next trial
sma = AddState(sma, 'Name', 'StopLickingBeforeReturn', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'StopLickingBefore'},...
    'OutputActions',[]); % return to stop licking

% sma = AddState(sma, 'Name', 'GoCue', 'Timer', 0.01,...
%     'StateChangeConditions', {'Tup', 'Position1'},...
%     'OutputActions', outputs.CueOutput); % answer or free reward
sma = AddState(sma, 'Name', 'GoCue', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', actions.ActionAfterCue},...
    'OutputActions', outputs.CueOutput); % answer or free reward

sma = AddState(sma, 'Name', 'GiveLeftDropShort', 'Timer', S.GUI.WaterValveTime*S.GUI.AutoWaterScale,...
    'StateChangeConditions', {'Tup', 'Position1'},...
    'OutputActions', outputs.LeftWaterOutput);

if NumPositions ~= 1
    sma = AddState(sma, 'Name', 'Position1', 'Timer', S.GUI.AnswerPeriod,...
        'StateChangeConditions', {'Port1In', 'Pause1', 'Tup', 'NoResponse'},...
        'OutputActions', []);
end

for i = 1:NumPositions-1
    if i ~= 1
        sma = AddState(sma, 'Name', ['Position', num2str(i)], 'Timer', S.GUI.PositionLickTime, ...
            'StateChangeConditions', {'Port1In', ['Pause', num2str(i)], 'Tup', 'TimeOut'}, ...
            'OutputActions', []);
    end
    
    sma = AddState(sma, 'Name', ['Pause', num2str(i)], 'Timer', S.GUI.MotorPauseTime,...
        'StateChangeConditions', {'Tup', ['MoveTo', num2str(i+1)]},...
        'OutputActions', outputs.Pause); % return to stop licking
    
    sma = AddState(sma, 'Name', ['MoveTo', num2str(i+1)], 'Timer', 0.05, ...
        'StateChangeConditions',  {'Tup', ['Position', num2str(i+1)]},...
        'OutputActions', {BpodSystem.Modules.Name(SerialPort), cmds.Delta});
    
end


sma = AddState(sma, 'Name', ['Position', num2str(NumPositions)], 'Timer', S.GUI.AnswerPeriod, ...
    'StateChangeConditions', {'Port1In', 'Reward', 'Tup', 'TimeOut'}, ...
    'OutputActions', []);

        
sma = AddState(sma, 'Name', 'Reward', ...
    'Timer', S.GUI.WaterValveTime,...
    'StateChangeConditions', {'Tup','RewardConsumption'},...
    'OutputActions', [outputs.RewardOutput, {'SoftCode', 10}]);

sma = AddState(sma, 'Name', 'RewardConsumption', 'Timer', S.GUI.ConsumptionPeriod,...
    'StateChangeConditions', {'Tup', 'StopLicking'},...
    'OutputActions', []); % reward consumption

sma = AddState(sma, 'Name', 'StopLicking', 'Timer', S.GUI.StopLickingPeriod,...
    'StateChangeConditions', {'Port1In', 'StopLickingReturn','Tup', 'ITI'},...
    'OutputActions', []); % stop licking before advancing to next trial
sma = AddState(sma, 'Name', 'StopLickingReturn', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'StopLicking'},...
    'OutputActions',[]); % return to stop licking

sma = AddState(sma, 'Name', 'NoResponse', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'TrialEnd'},...
    'OutputActions',[]); % no response

sma = AddState(sma, 'Name', 'TimeOut', 'Timer', S.GUI.TimeOut,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', []);%{'WavePlayer1',4});% incorrect response

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



function cmds = defineSerialCommands(TrialType)
global S
cmdNums = {'1', '2', '3', '4'}; % for LickSequence
% cmdsVar = uint8([1 2 3 4]);
% for i = 1:length(cmdsVar)
%     cmdNums{i} = cmdsVar(i);
% end
LoadSerialMessages(2, cmdNums);
Npositions = S.GUI.NumPositions;
centerX = S.GUI.centerX; % mm
deltaX = S.GUI.deltaX; % mm

stepSize = 0.1905; % LSM type B; in microns

if mod(Npositions,2) == 1
    relPosition = ceil(Npositions/2) - 1; % odd # of positions
else
    relPosition = (Npositions/2) - 0.5; % even # of positions
end

centerSteps = round(centerX/(stepSize/1000));
deltaSteps = round(deltaX/(stepSize/1000));
startSteps = round(centerSteps - relPosition*deltaSteps);
stopSteps = round(centerSteps + relPosition*deltaSteps);

Message1 = ['a' num2str(startSteps)];
Message2 = ['b' num2str(stopSteps)];
Message3 = ['c' num2str(deltaSteps)];

s = serial('COM9','BaudRate',115200); % set correct Teensy COM port
fopen(s);
fprintf(s,Message1);
pause(0.1)
fprintf(s,Message2);
pause(0.1)
fprintf(s,Message3);
pause(1)
fclose(s);

% CommandArray = {['/1 01 move abs ' num2str(startSteps) '!']};
% 
% CommandArray = {['/1 01 move abs ' num2str(startSteps) '!'], ...
%     ['/1 01 move abs ' num2str(stopSteps) '!'], ...
%     ['/1 01 move rel ' num2str(deltaSteps) '!'], ...
%     ['/1 01 move rel -' num2str(deltaSteps) '!']};
% 
% s = serial('COM9','BaudRate',115200); % set correct Teensy COM port
% fopen(s);
% 
% for i = 1:length(CommandArray)
%     Message = char(CommandArray{i});
%     fprintf(s,Message)
% %     pause(0.1)
% end
% fclose(s);

if TrialType==0
    cmds.Delta = 3;
    cmds.StartPos = 1;
elseif TrialType==1
    cmds.Delta = 4;
    cmds.StartPos = 2 ;
else
    disp('!Trial type not recognized');
end



function actions = getActions(Nlicks)
global S

actions.LeftLickAction = cell(Nlicks, 1);

for i = 1:Nlicks-1
    actions.LeftLickAction{i} = ['Position' num2str(i+1)];
end

actions.LeftLickAction{end} = 'Reward';

actions.ActionAfterCue = 'Position1';

if S.GUI.Autowater == 1 % give small drop of free water on L
    actions.ActionAfterCue = 'GiveLeftDropShort';
end


function outputs = getOutputs(trialType, SerialPort, cmds, params)
global S BpodSystem

outputs.LeftWaterOutput = {'ValveState',2^0};
outputs.RightWaterOutput = {'ValveState',2^1};
% 
% switch trialType % Determine trial-specific state matrix fields
%     case 1  % lick left
%         SoundChannel = 'PWM1';
%         RewardOutput = outputs.LeftWaterOutput;
%     case 0  % lick right
%         SoundChannel = 'PWM2';
%         RewardOutput = outputs.RightWaterOutput;
% end



% outputs.SoundOutput = {SoundChannel,255};
if ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'EphysRig1'))
    outputs.CueOutput = {'PWM4', 255, 'BNCState', 2};
elseif ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'Box'))
    outputs.CueOutput = {'BNCState',1};
end
outputs.RewardOutput = outputs.LeftWaterOutput;


outputs.GoToStartPos = {BpodSystem.Modules.Name(SerialPort), cmds.StartPos};
outputs.Pause = [];
if S.GUI.MaskingFlash
    outputs.GoToStartPos = [outputs.GoToStartPos, 'BNCState', 2];
    outputs.Pause = {'BNCState', 2};
end


if params.giveStim
    if strcmp(params.stimState, 'GoCue')
        outputs.CueOutput = [outputs.CueOutput,'GlobalTimerCancel', 2, 'GlobalTimerTrig', 4];
%         S.Timers(4) = 1;
%         outputs.CueOutput = {'GlobalTimerCancel', 2, 'GlobalTimerTrig', 4};
    end
end







