function [sma, params] = getStateMatrix_soundTask2AFC(params, trialType, TrialNum)
global S 

actions = getActions(trialType, params.Nlicks);
outputs = getOutputs(trialType, params);

sma = NewStateMatrix(); % Assemble state matrix
sma = setTimers(sma, params); % set up timers for trial start and stimulation
sma = addTrialStartStates(sma, params.bit, TrialNum); % Location dependent starting states

sma = AddState(sma, 'Name', 'InitialState', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup','SamplePeriod'},...
        'OutputActions', []);

if S.GUI.ProtocolType==3 % enforce delay and sample
    sma = AddState(sma, 'Name', 'SamplePeriod', 'Timer', S.GUI.SamplePeriod,...
        'StateChangeConditions', {'Port1In','EarlyLickSample','Port2In','EarlyLickSample','Tup', 'DelayPeriod'},...
        'OutputActions', outputs.SoundOutput);
    sma = AddState(sma, 'Name', 'EarlyLickSample', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'EarlyLickSampleReturn'},...
        'OutputActions', []); % if lick during sample, time out for duration of sample period
    sma = AddState(sma, 'Name', 'EarlyLickSampleReturn', 'Timer',S.GUI.SamplePeriod,...
        'StateChangeConditions', {'Port1In','EarlyLickSample','Port2In','EarlyLickSample','Tup', 'DelayPeriod'},...
        'OutputActions', []); % send to delay period
    sma = AddState(sma, 'Name', 'DelayPeriod', 'Timer', S.GUI.DelayPeriod,...
        'StateChangeConditions', {'Port1In','EarlyLickDelay','Port2In','EarlyLickDelay','Tup', 'GoCue'},...
        'OutputActions', outputs.DelayOutput); % if lick during delay, restart delay
    sma = AddState(sma, 'Name', 'EarlyLickDelay', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'DelayPeriod'},...
        'OutputActions', []); % if lick during delay, restart delay
    
elseif S.GUI.ProtocolType==2 % enforce sample
    sma = AddState(sma, 'Name', 'SamplePeriod', 'Timer', S.GUI.SamplePeriod,...
        'StateChangeConditions', {'Port1In','EarlyLickSample','Port2In','EarlyLickSample','Tup', 'DelayPeriod'},...
        'OutputActions', outputs.SoundOutput); % stimulus
    sma = AddState(sma, 'Name', 'EarlyLickSample', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'EarlyLickSampleReturn'},...
        'OutputActions', []); % if lick during sample, restart sample
    sma = AddState(sma, 'Name', 'EarlyLickSampleReturn', 'Timer',S.GUI.SamplePeriod,...
        'StateChangeConditions', {'Port1In','EarlyLickSample','Port2In','EarlyLickSample','Tup', 'DelayPeriod'},...
        'OutputActions', []); % send to delay period
    sma = AddState(sma, 'Name', 'DelayPeriod', 'Timer', S.GUI.DelayPeriod,...
        'StateChangeConditions', {'Tup', 'GoCue'},...
        'OutputActions', outputs.DelayOutput);
    
elseif S.GUI.ProtocolType==1 % no early lick punishment
    sma = AddState(sma, 'Name', 'SamplePeriod', 'Timer', S.GUI.SamplePeriod,...
        'StateChangeConditions', {'Tup', 'DelayPeriod'},...
        'OutputActions', outputs.SoundOutput); % stimulus
    sma = AddState(sma, 'Name', 'DelayPeriod', 'Timer', S.GUI.DelayPeriod,...
        'StateChangeConditions', {'Tup', 'GoCue'},...
        'OutputActions', outputs.DelayOutput);
end


sma = AddState(sma, 'Name', 'GoCue', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', actions.ActionAfterCue},...
    'OutputActions', outputs.CueOutput); % answer or free reward


for i = 1:params.Nlicks
    sma = AddState(sma, 'Name', ['WaitForLick' num2str(i)], 'Timer', S.GUI.AnswerPeriod,...
        'StateChangeConditions', {'Port1In', actions.LeftLickAction{i}, 'Port2In', actions.RightLickAction{i}, 'Tup', 'NoResponse'},...
        'OutputActions', []); % wait for response
end


sma = AddState(sma, 'Name', 'GiveLeftDropShort', 'Timer', outputs.WaterValveTime*S.GUI.AutoWaterScale,...
    'StateChangeConditions', {'Tup', 'WaitForLick1'},...
    'OutputActions', outputs.LeftWaterOutput); % free reward left
sma = AddState(sma, 'Name', 'GiveRightDropShort', 'Timer', outputs.WaterValveTime*S.GUI.AutoWaterScale,...
    'StateChangeConditions', {'Tup', 'WaitForLick1'},...
    'OutputActions', outputs.RightWaterOutput); % free reward right


sma = AddState(sma, 'Name', 'Reward', 'Timer', outputs.WaterValveTime,...
    'StateChangeConditions', {'Tup', 'RewardConsumption'},...
    'OutputActions', outputs.RewardOutput); % turn on water
sma = AddState(sma, 'Name', 'RewardConsumption', 'Timer', S.GUI.ConsumptionPeriod,...
    'StateChangeConditions', {'Tup', 'StopLicking'},...
    'OutputActions', []); % reward consumption

sma = AddState(sma, 'Name', 'TimeOut', 'Timer', S.GUI.TimeOut,...
    'StateChangeConditions', {'Tup', 'StopLicking'},...
    'OutputActions', []);%{'WavePlayer1',4});% incorrect response

sma = AddState(sma, 'Name', 'StopLicking', 'Timer', S.GUI.StopLickingPeriod,...
    'StateChangeConditions', {'Port1In', 'StopLickingReturn','Port2In', 'StopLickingReturn','Tup', 'ITI'},...
    'OutputActions', []); % stop licking before advancing to next trial
sma = AddState(sma, 'Name', 'StopLickingReturn', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'StopLicking'},...
    'OutputActions',[]); % return to stop licking

sma = AddState(sma, 'Name', 'NoResponse', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'TrialEnd'},...
    'OutputActions',[]); % no response

sma = AddState(sma, 'Name', 'ITI', 'Timer', params.ITI,...
    'StateChangeConditions', {'Tup', 'TrialEnd'},...
    'OutputActions',[]);

sma = addTrialEndStates(sma, params);




function actions = getActions(trialType, Nlicks)
global S

switch trialType % Determine trial-specific state matrix fields
    case 1  % lick left

        actions.LeftLickAction = cell(Nlicks, 1);
        actions.RightLickAction = cell(Nlicks, 1);
        
        for i = 1:Nlicks-1
            actions.LeftLickAction{i} = ['WaitForLick' num2str(i+1)];
            actions.RightLickAction{i} = 'TimeOut';
        end
        
        actions.LeftLickAction{end} = 'Reward';%want to change it to NLicks? in case anything goes wrong?
        actions.RightLickAction{end} = 'TimeOut';
        actions.ActionAfterCue = 'WaitForLick1';
        
        
        if S.GUI.Autowater == 1 % give small drop of free water on L
            actions.ActionAfterCue = 'GiveLeftDropShort';
        end
        
    case 0  % lick right

        actions.LeftLickAction = cell(Nlicks, 1);
        actions.RightLickAction = cell(Nlicks, 1);
        
        for i = 1:Nlicks-1
            actions.LeftLickAction{i} = 'TimeOut';
            actions.RightLickAction{i} = ['WaitForLick' num2str(i+1)];
        end
        
        actions.LeftLickAction{end} = 'TimeOut';
        actions.RightLickAction{end} = 'Reward'; %want to change it to NLicks? in case anything goes wrong?
        actions.ActionAfterCue = 'WaitForLick1';
        
       
        if S.GUI.Autowater == 1  % give small drop of free water on R
            actions.ActionAfterCue = 'GiveRightDropShort';
        end
end






function outputs = getOutputs(trialType, params)
global S
%params
outputs.LeftWaterOutput = {'ValveState',2^0};
outputs.RightWaterOutput = {'ValveState',2^1};

% 'PWM1' = pure tone
% 'PWM2' = white noise

switch trialType % Determine trial-specific state matrix fields
    case 1  % lick left
        SoundChannel = 'PWM1';
        RewardOutput = outputs.LeftWaterOutput;
        outputs.WaterValveTime = S.GUI.WaterValveTime*S.GUI.LeftPortScale;
    case 0  % lick right
        SoundChannel = 'PWM2';
        RewardOutput = outputs.RightWaterOutput;
        outputs.WaterValveTime = S.GUI.WaterValveTime*S.GUI.RightPortScale;
end

if S.GUI.Reversal == 2
    if strcmp(SoundChannel, 'PWM2')
        SoundChannel = 'PWM1';
    else
        SoundChannel = 'PWM2';
    end
end

outputs.SoundOutput = {SoundChannel,255};


if ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'EphysRig1'))
    outputs.CueOutput = {'PWM4', 255};
    if S.GUI.MaskingFlash
        outputs.CueOutput = [outputs.CueOutput, 'BNCState', 2];
        outputs.SoundOutput = [outputs.SoundOutput, 'BNCState', 2];
    end
elseif ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'Box'))
    outputs.CueOutput = {'BNCState', 1};
end

outputs.DelayOutput = [];
if params.giveStim
    if strcmp(params.stimState, 'GoCue')
        
        if S.GUI.CameraTrigger
            outputs.CueOutput = [outputs.CueOutput, 'GlobalTimerCancel', 2, 'GlobalTimerTrig', 4];
        else
            outputs.CueOutput = [outputs.CueOutput, 'GlobalTimerTrig', 4];
        end
           
    elseif strcmp(params.stimState, 'Delay')
        
        
        if S.GUI.CameraTrigger
            outputs.DelayOutput = {'GlobalTimerCancel', 2, 'GlobalTimerTrig', 4};
        else
            outputs.DelayOutput = {'GlobalTimerTrig', 4};
        end

    end
end


outputs.RewardOutput = RewardOutput;








