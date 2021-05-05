% Test X-MBC2 Step Controller with soft code command
function  LickSequence()
global S BpodSystem

S = struct;
S = BpodSystem.ProtocolSettings;

% Setup GUI with default parameters and set callbacks
setupGUI_LickSequence()
BpodParameterGUI('init', S);


BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';
BpodSystem.GUIHandles.OutcomePlot = figure(12434);
BpodSystem.GUIHandles.OutcomeAxes = axes();hold on;
xlabel('Trial Number');
ylabel('Port position');

SerialPort = S.GUI.SerialPort; % Module 2 for motor control
    ITI = S.GUI.ITImu;
    n = S.GUI.NTrials;
    centerX = S.GUI.centerX; % mm
    deltaX = S.GUI.deltaX; % mm

    stepSize = 0.1905; % LSM type B
% absX = S.GUI.absX; % mm
% absY = S.GUI.absY; % mm

% stepSize = 0.1905; % LSM type B
% xSteps = round(absX/(stepSize/1000));
% ySteps = round(absY/(stepSize/1000));
% deltaSteps = round(deltaX/(stepSize/1000));

% Messages = {'/1 01 move abs 150000',
%             '/1 01 move abs 200000',
%             '/1 01 move rel 10000',
%             '/1 01 move rel -10000'};
SerialPort = S.GUI.SerialPort; % Module 2 for motor control

Messages  = {'1','2','3','4'}; % input messages for arduino motor control
Acknowledged = LoadSerialMessages(SerialPort, Messages); % messages are limited to 3 bytes

% add GUI parameters
% output array
% alternate outputs between trials

% start at predefined absolute center position
% use delta parameter to move relative to center
% two trial types: forward and reverse
% use loadserialmessages() to create motor command array

% find optimal deltaX and total distance
% set up reward sequence
% speed up motor

% Forward sequence
% -- 1) Auditory Cue
% -- 2) Start at position 1 - wait for lick - move to next position
% -- 3) Repeat n-2 times
% -- 4) n position - wait for lick - RewardDelay
% -- 5) Reward - RandomDelay before next trial
% Reverse sequence

% use matlab to update motor commands to teensy
% add state to send centerX position
% add state to send deltaX position

defineSerialCommands();

for trial = 1:n
    disp(trial)
    SerialPort = S.GUI.SerialPort; % Module 2 for motor control
    ITI = S.GUI.ITImu;
    n = S.GUI.NTrials;
    centerX = S.GUI.centerX; % mm
%     absY = S.GUI.absY; % mm
    deltaX = S.GUI.deltaX; % mm

    stepSize = 0.1905; % LSM type B
%     xSteps = round(absX/(stepSize/1000));
%     ySteps = round(absY/(stepSize/1000));
    centerSteps = round(centerX/(stepSize/1000));
    deltaSteps = round(deltaX/(stepSize/1000));

    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
    %     ITI = exprnd(S.GUI.ITImu);
    
    if mod(trial,2) == 1
        trialStart = 0;
        MoveCode = 3; % move Forward
        StartCode = 1; % start at beginning
    else
        trialStart = 1;
        MoveCode = 4; % move backward
        StartCode = 2; % start at end position
    end
    
    BpodSystem.Data.trialNumber = trial;
    BpodSystem.Data.trialType = trialStart;
    BpodSystem.GUIHandles.lickRasters{trial} = plot(BpodSystem.GUIHandles.OutcomeAxes, 0, 0, 'k.');
    
    
    % disp(MoveCode)
    % disp(StartCode)
    sma = NewStateMatrix(); % Create a blank matrix to define the trial's finite state machine
    % add state for soft code to move target
    % set up seperate function to call soft code
    
    sma = AddState(sma, 'Name', 'SendMotorCommands', ...
        'Timer', 1,...
        'StateChangeConditions', {'Tup','TrigTrialStart'},...
        'OutputActions', {'SoftCode', 11});
    
    sma = AddState(sma, 'Name', 'TrigTrialStart', ...
        'Timer', 1,...
        'StateChangeConditions', {'Tup','GoCue'},...
        'OutputActions', {BpodSystem.Modules.Name(SerialPort) , StartCode, 'SoftCode', 1});
    
    sma = AddState(sma, 'Name', 'GoCue', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'Position1'},...
        'OutputActions', {'PWM4', 255,}); % answer or free reward
    
    sma = AddState(sma, 'Name', 'Position1', ...
        'Timer', S.GUI.ResponseTime,...
        'StateChangeConditions', {'Port1In', 'MoveTo2','Tup','TrialEnd'},...
        'OutputActions', []);
    
    sma = AddState(sma, 'Name', 'MoveTo2', ...
        'Timer', 0.05,...
        'StateChangeConditions', {'Tup','Position2'},...
        'OutputActions', {BpodSystem.Modules.Name(SerialPort), MoveCode, 'SoftCode', 2});
    
    sma = AddState(sma, 'Name', 'Position2', ...
        'Timer', S.GUI.ResponseTime,...
        'StateChangeConditions', {'Port1In', 'MoveTo3','Tup','TrialEnd'},...
        'OutputActions', []);
    
     sma = AddState(sma, 'Name', 'MoveTo3', ...
        'Timer', 0.05,...
        'StateChangeConditions', {'Tup','Position3'},...
        'OutputActions', {BpodSystem.Modules.Name(SerialPort), MoveCode, 'SoftCode', 3});
    
    sma = AddState(sma, 'Name', 'Position3', ...
        'Timer', S.GUI.ResponseTime,...
        'StateChangeConditions', {'Port1In', 'MoveTo4','Tup','TrialEnd'},...
        'OutputActions', []);
    
    sma = AddState(sma, 'Name', 'MoveTo4', ...
        'Timer', 0.05,...
        'StateChangeConditions', {'Tup','Position4'},...
        'OutputActions', {BpodSystem.Modules.Name(SerialPort), MoveCode, 'SoftCode', 4});
    
    sma = AddState(sma, 'Name', 'Position4', ...
        'Timer', S.GUI.ResponseTime,...
        'StateChangeConditions', {'Port1In', 'MoveTo5','Tup','TrialEnd'},...
        'OutputActions', []);
    
     sma = AddState(sma, 'Name', 'MoveTo5', ...
        'Timer', 0.05,...
        'StateChangeConditions', {'Tup','Position5'},...
        'OutputActions', {BpodSystem.Modules.Name(SerialPort), MoveCode, 'SoftCode', 5});
    
    sma = AddState(sma, 'Name', 'Position5', ...
        'Timer', S.GUI.ResponseTime,...
        'StateChangeConditions', {'Tup','TrialEnd','Port1In','Reward'},...
        'OutputActions', []);
    
    sma = AddState(sma, 'Name', 'Reward', ...
        'Timer', 0.1,...
        'StateChangeConditions', {'Tup','TrialEnd'},...
        'OutputActions', {'ValveState', 1, 'SoftCode', 10});
    
    %
    %     sma = AddState(sma, 'Name', 'Reward', ...
    %         'Timer', S.GUI.RewardDelay,...
    %         'StateChangeConditions', {'Tup', 'RewardConsumption'},...
    %         'OutputActions', []); % add reward output later
    %
    %     sma = AddState(sma, 'Name', 'RewardConsumption', ...
    %         'Timer', S.GUI.ResponseTime,...
    %         'StateChangeConditions', {'Port1In', 'StopLicking','Tup','Position1'},...
    %         'OutputActions', []);
    %
    %     sma = AddState(sma, 'Name', 'StopLicking', 'Timer', S.GUI.StopLickingPeriod,...
    %                     'StateChangeConditions', {'Port1In', 'StopLickingReturn','Port2In', 'StopLickingReturn','Tup', 'TrialEnd'},...
    %                     'OutputActions', []); % stop licking before advancing to next trial
    %
    %     sma = AddState(sma, 'Name', 'StopLickingReturn', 'Timer', 0.01,...
    %                     'StateChangeConditions', {'Tup', 'StopLicking'},...
    %                     'OutputActions',[]); % return to stop licking
    
    sma = AddState(sma, 'Name', 'TrialEnd', 'Timer', ITI,...
        'StateChangeConditions', {'Tup', 'exit'},'OutputActions', []); % pole up and trial end
    
    
    %     BpodSystem.SoftCodeHandlerFunction = 'TestMotor_handler';
    
    SendStateMachine(sma);
    RawEvents = RunStateMachine();
end

function cmds = defineSerialCommands(TrialType)
global S
cmdNums = {1, 2, 3, 4};
LoadSerialMessages(2, cmdNums);
Npositions = S.GUI.Npositions;
centerX = S.GUI.centerX; % mm
deltaX = S.GUI.deltaX; % mm
% Npositions = 5;
% centerX = 10; % mm
% deltaX = 1; % mm
stepSize = 0.1905; % LSM type B; in microns


if mod(Npositions,2) == 1
    relPosition = ceil(Npositions/2) - 1;
else
    relPosition = (Npositions/2) - 0.5;
end

centerSteps = round(centerX/(stepSize/1000));
deltaSteps = round(deltaX/(stepSize/1000));
startSteps = centerSteps - relPosition*deltaSteps;
stopSteps = centerSteps + relPosition*deltaSteps;

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

% CommandArray = {['/1 01 move abs ' num2str(startSteps) '\r'], ...
%     ['/1 01 move abs ' num2str(stopSteps) '\r'], ...
%     ['/1 01 move rel ' num2str(deltaSteps) '\r'], ...
%     ['/1 01 move rel -' num2str(deltaSteps) '\r']};
% 
% s = serial('COM9','BaudRate',115200); % set correct Teensy COM port
% fopen(s);
% 
% for i = 1:length(CommandArray)
%     fprintf(s,CommandArray{i});
%     pause(0.1)
% end
% fclose(s);
% 
if TrialType==0
    cmds.Delta = 3;
    cmds.Startpos = 1;
elseif TrialType==1
    cmds.Delta = 4;
    cmds.Startpos =2 ;
else
    disp('!Trial type not recognized');
end






    
    
    
    
    
    
