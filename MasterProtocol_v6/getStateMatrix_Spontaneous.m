function [sma, params] = getStateMatrix_Spontaneous(params, TrialType, TrialNum)    
global S

actions = getActions(TrialType);
outputs = getOutputs(TrialType, params);

sma = NewStateMatrix();
sma = setTimers(sma, params); % set up timers for trial start and stimulation
sma = addTrialStartStates(sma, params.bit, TrialNum); % location dependent starting states

sma = AddState(sma, 'Name', 'InitialState', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'StopLickingBeforeGoCue'},...
    'OutputActions', []);

% stop licking period before go cue
% uses delay period set in GUI
if S.GUI.NumLickPorts == 2
    sma = AddState(sma, 'Name', 'StopLickingBeforeGoCue', 'Timer', S.GUI.DelayPeriod,...
        'StateChangeConditions', {'Port1In', 'StopLickingReturnBeforeGoCue',...
        'Port2In', 'StopLickingReturnBeforeGoCue','Tup','GoCue'},...
        'OutputActions', []);
else % keeps Bpod from reacting to inactive port2
    sma = AddState(sma, 'Name', 'StopLickingBeforeGoCue', 'Timer', S.GUI.DelayPeriod,...
        'StateChangeConditions', {'Port1In', 'StopLickingReturnBeforeGoCue','Tup','GoCue'},...
        'OutputActions', []);
end

sma = AddState(sma, 'Name', 'StopLickingReturnBeforeGoCue', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup','StopLickingBeforeGoCue'},...
    'OutputActions', []); 

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
    

% these states only accessed when autowater is on
% amount of time spent in state is how long valve is open for
sma = AddState(sma, 'Name', 'GiveLeftDropShort', 'Timer', outputs.LeftValveTime*S.GUI.AutoWaterScale,...
    'StateChangeConditions', {'Tup', 'AnswerPeriod'},...
    'OutputActions', outputs.LeftWaterOutput); % free reward left
sma = AddState(sma, 'Name', 'GiveRightDropShort', 'Timer', outputs.RightValveTime*S.GUI.AutoWaterScale,...
    'StateChangeConditions', {'Tup', 'AnswerPeriod'},...
    'OutputActions', outputs.RightWaterOutput); % free reward right


if S.GUI.NumLickPorts == 2
    sma = AddState(sma, 'Name', 'AnswerPeriod', 'Timer', S.GUI.AnswerPeriod,...
        'StateChangeConditions', {'Port1In', 'LickedLeft','Port2In', 'LickedRight','Tup','NoResponse'},...% send them to stopLickingReturn? do we want them to lick at least once? should that be a parameter? or lick as many times as they want?
        'OutputActions', []);
else % keeps Bpod from reacting to inactive port2
    sma = AddState(sma, 'Name', 'AnswerPeriod', 'Timer', S.GUI.AnswerPeriod,...
        'StateChangeConditions', {'Port1In','LickedLeft','Tup','NoResponse'},...% send them to stopLickingReturn? do we want them to lick at least once? should that be a parameter? or lick as many times as they want?
        'OutputActions', []);
end


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


if S.GUI.NumLickPorts == 2
    sma = AddState(sma, 'Name', 'StopLicking', 'Timer', S.GUI.StopLickingPeriod,...
        'StateChangeConditions', {'Port1In', 'StopLickingReturn','Port2In', 'StopLickingReturn','Tup','ITI'},...
        'OutputActions', []);
else % keeps Bpod from reacting to inactive port2
    sma = AddState(sma, 'Name', 'StopLicking', 'Timer', S.GUI.StopLickingPeriod,...
        'StateChangeConditions', {'Port1In', 'StopLickingReturn','Tup','ITI'},...
        'OutputActions', []);
end

sma = AddState(sma, 'Name', 'StopLickingReturn', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup','StopLicking'},...
    'OutputActions', []); 

sma = AddState(sma, 'Name', 'NoResponse', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'ITI', 'Timer', params.ITI,...
    'StateChangeConditionts', {'Tup', 'TrialEnd'},...
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


function actions = getActions(trialType)
global S

switch trialType % Determine trial-specific state matrix fields
    case 1  % lick left
        
        actions.LeftLickAction = 'Reward';
        actions.RightLickAction = 'TimeOut';
        actions.ActionAfterCue = 'AnswerPeriod';
        
        if S.GUI.Autowater == 1 % give small drop of free water on L
            actions.ActionAfterCue = 'GiveLeftDropShort';
        end
        
    case 0  % lick right
        
        actions.LeftLickAction = 'Reward';
        actions.RightLickAction = 'Reward';
        actions.ActionAfterCue = 'AnswerPeriod';
        
        if S.GUI.Autowater == 1  % give small drop of free water on R
            actions.ActionAfterCue = 'GiveRightDropShort';
        end

end






function outputs = getOutputs(trialType, params)
global S
% for 1 lick port, outputs.RightResponse cleared at end of function
outputs.LeftWaterOutput = {'ValveState',2^0};
outputs.RightWaterOutput = {'ValveState',2^1};
outputs.CueOutput = [];

switch S.GUI.NumLickPorts
    
    case 1 % 1 lick port, water only comes out of left lick port, no trial types
        
        if S.GUI.SpontCueType==1 % water drop cue
            outputs.CueOutput = outputs.LeftWaterOutput;
            outputs.WaterValveTime = S.GUI.WaterValveTime*S.GUI.LeftPortScale;
            outputs.LeftResponse = [];
            outputs.RightResponse = [];
        end
        
    case 2
        
        if S.GUI.SpontCueType==1 % WaterDrop
            switch trialType
                case 1 % left
                    outputs.CueOutput = outputs.LeftWaterOutput;
                    outputs.WaterValveTime = S.GUI.WaterValveTime*S.GUI.LeftPortScale;
                case 0 % right
                    outputs.CueOutput = outputs.RightWaterOutput;
                    outputs.WaterValveTime = S.GUI.WaterValveTime*S.GUI.RightPortScale;
            end
            outputs.LeftResponse = [];
            outputs.RightResponse = [];
        end
        
end


if S.GUI.SpontCueType==2 % None
    outputs.CueOutput = [];
    outputs.LeftResponse = outputs.LeftWaterOutput;
    outputs.RightResponse = outputs.RightWaterOutput;
    outputs.LeftValveTime = S.GUI.WaterValveTime*S.GUI.LeftPortScale;
    outputs.RightValveTime = S.GUI.WaterValveTime*S.GUI.RightPortScale;
end


if ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'EphysRig1'))
    
    if S.GUI.SpontCueType==3 % GoCue
        outputs.CueOutput = {'PWM4', 255};
        outputs.LeftResponse = outputs.LeftWaterOutput;
        outputs.RightResponse = outputs.RightWaterOutput;
        outputs.LeftValveTime = S.GUI.WaterValveTime*S.GUI.LeftPortScale;
        outputs.RightValveTime = S.GUI.WaterValveTime*S.GUI.RightPortScale;
    end
    
    if params.giveStim % no option for delay for spontaneous task, so stim at go cue
%         if strcmp(params.stimState, 'GoCue')
            if ~isempty(outputs.CueOutput)
                if S.GUI.CameraTrigger
                    %outputs.CueOutput = [outputs.CueOutput, 'GlobalTimerTrig', 4];
                    outputs.CueOutput = [outputs.CueOutput,'GlobalTimerCancel', 2, 'GlobalTimerTrig', 4];
                else
                    outputs.CueOutput = [outputs.CueOutput, 'GlobalTimerTrig', 4];
                end
            else % empty cue output
                if S.GUI.CameraTrigger
                    outputs.CueOutput = {'GlobalTimerCancel',2,'GlobalTimerTrig', 4};
                else
                    outputs.CueOutput = {'GlobalTimerTrig', 4};
                end
            end
%         end
    end
    
    % add BNCState 2 at go cue for any cue for analysis
    if ~isempty(outputs.CueOutput)
        outputs.CueOutput = [outputs.CueOutput, 'BNCState',2];
    else
        outputs.CueOutput = {'BNCState', 2};
    end
    
    
elseif ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'Box'))
    
    outputs.CueOutput = [];
    
    if S.GUI.SpontCueType==3 % GoCue
        outputs.CueOutput = {'BNCState',1};
        outputs.LeftResponse = outputs.LeftWaterOutput;
        outputs.RightResponse = outputs.RightWaterOutput;
    end
    
end


if S.GUI.NumLickPorts == 1
    outputs.RightResponse = [];
end

