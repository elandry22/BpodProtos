function [sma, params] = getStateMatrix_LickSequencev2(params, TrialType, TrialNum)
global S BpodSystem 

NumPositions = S.GUI.NumPositions;
% SerialPort = S.GUI.SerialPort; % Module 2 for motor control

actions = getActions(params.Nlicks);
outputs = getOutputs(TrialType);

sma = NewStateMatrix();
sma = setTimers(sma, params);
sma = addTrialStartStates(sma, params.bit, TrialNum);

sma = AddState(sma, 'Name', 'InitialState', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'GoToStartPos'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'GoToStartPos', ...
    'Timer', 0.001,...
    'StateChangeConditions', {'Tup','PreGoCue'},...
    'OutputActions', {'BNCState', 1});

sma = AddState(sma, 'Name', 'PreGoCue', 'Timer', 2,...
                'StateChangeConditions', {'Port1In', 'StopLickingBefore', 'Tup', 'GoCue'},...
                'OutputActions', {'BNCState', 2}); % masking flash

% sma = AddState(sma, 'Name', 'PreGoCue', 'Timer', 1.5,...
%                 'StateChangeConditions', {'Tup', 'GoCue'},...
%                 'OutputActions', []);

sma = AddState(sma, 'Name', 'StopLickingBefore', 'Timer', S.GUI.StopLickingPeriod,...
    'StateChangeConditions', {'Port1In', 'StopLickingBeforeReturn','Tup', 'GoCue'},...
    'OutputActions', []); % stop licking before advancing to next trial

sma = AddState(sma, 'Name', 'StopLickingBeforeReturn', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'StopLickingBefore'},...
    'OutputActions',[]); % return to stop licking

sma = AddState(sma, 'Name', 'GoCue', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', actions.ActionAfterCue},...
    'OutputActions', outputs.CueOutput);

sma = AddState(sma, 'Name', 'GiveLeftDropShort', 'Timer', S.GUI.WaterValveTime*S.GUI.AutoWaterScale,...
    'StateChangeConditions', {'Tup', 'Position1'},...
    'OutputActions', outputs.LeftWaterOutput);


if NumPositions ~= 1
    sma = AddState(sma, 'Name', 'Position1', 'Timer', S.GUI.AnswerPeriod,...
        'StateChangeConditions', {'Port1In', 'Pause1', 'Tup', 'TimeOut'},...
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
        'OutputActions', outputs.PauseOutput); % BNCState 2 if MaskingFlash on
    

    sma = AddState(sma, 'Name', ['MoveTo', num2str(i+1)], 'Timer', 0.001, ...
                'StateChangeConditions',  {'Tup', ['Position', num2str(i+1)]},...
                'OutputActions', {'BNCState',1}); 
            
%     sma = AddState(sma, 'Name', ['interbit' num2str(i)], 'Timer', 0.01,...
%                 'StateChangeConditions', {'Tup', ['Position' num2str(i+1)]},...
%                 'OutputActions', {'BNCState', 0});
        
end

sma = AddState(sma, 'Name', ['Position', num2str(NumPositions)], 'Timer', S.GUI.AnswerPeriod, ...
    'StateChangeConditions', {'Port1In', 'Reward', 'Tup', 'NoResponse'}, ...
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
    'StateChangeConditions', {'Tup', 'TimeOut'},...
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


function actions = getActions(Nlicks)
    global S 

    actions.LeftLickAction = cell(Nlicks, 1);

    for i = 1:Nlicks-1
        actions.LeftLickAction{i} = ['WaitForLick' num2str(i+1)];
    end

    actions.LeftLickAction{end} = 'Reward';

    actions.ActionAfterCue = 'Position1';

    if S.GUI.Autowater == 1 % give small drop of free water on L
        actions.ActionAfterCue = 'GiveLeftDropShort';
    end


function outputs = getOutputs(trialType)
    global S

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
    
    outputs.PauseOutput = [];
    if S.GUI.MaskingFlash
        outputs.PauseOutput = {'BNCState', 2};
    end
    
   
    





