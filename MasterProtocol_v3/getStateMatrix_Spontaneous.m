function [sma, params] = getStateMatrix_Spontaneous(params, TrialType, TrialNum)    
global S


outputs = getOutputs(TrialType);

sma = NewStateMatrix();

sma = addTrialStartStates(sma, params.bit, TrialNum);

sma = AddState(sma, 'Name', 'InitialState', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'GoCue'},...
    'OutputActions', []);

if ~isempty(outputs.CueOutput)
    sma = AddState(sma, 'Name', 'GoCue', 'Timer', S.GUI.WaterValveTime,...
        'StateChangeConditions', {'Tup', 'AnswerPeriod'},...
        'OutputActions', outputs.CueOutput);
else
    sma = AddState(sma, 'Name', 'GoCue', 'Timer', S.GUI.WaterValveTime,...
        'StateChangeConditions', {'Tup', 'AnswerPeriod'},...
        'OutputActions', []);
end
    


sma = AddState(sma, 'Name', 'AnswerPeriod', 'Timer', S.GUI.AnswerPeriod,...
    'StateChangeConditions', {'Port1In', 'LickedLeft','Port2In', 'LickedRight','Tup','NoResponse'},...% send them to stopLickingReturn? do we want them to lick at least once? should that be a parameter? or lick as many times as they want?
    'OutputActions', []); 


if isempty(outputs.LeftResponse) || isempty(outputs.RightResponse) % could just be for outputs.LeftResponse, if outputs.LeftResponse is empty outputs.RightResponse will be empty, keep for clarity?
    sma = AddState(sma, 'Name', 'LickedLeft', 'Timer', S.GUI.WaterValveTime,...
        'StateChangeConditions', {'Tup', 'Reward'},...
        'OutputActions', []);
    sma = AddState(sma, 'Name', 'LickedRight', 'Timer', S.GUI.WaterValveTime,...
        'StateChangeConditions', {'Tup', 'Reward'},...
        'OutputActions', []);
    sma = AddState(sma, 'Name', 'Reward', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'StopLicking'},...
        'OutputActions', []);
else
    sma = AddState(sma, 'Name', 'LickedLeft', 'Timer', S.GUI.WaterValveTime,...
        'StateChangeConditions', {'Tup', 'Reward'},...
        'OutputActions', outputs.LeftResponse);
    sma = AddState(sma, 'Name', 'LickedRight', 'Timer', S.GUI.WaterValveTime,...
        'StateChangeConditions', {'Tup', 'Reward'},...
        'OutputActions', outputs.RightResponse);
    sma = AddState(sma, 'Name', 'Reward', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'StopLicking'},...
        'OutputActions', []);
end

sma = AddState(sma, 'Name', 'StopLicking', 'Timer', S.GUI.StopLickingPeriod,...
    'StateChangeConditions', {'Port1In', 'StopLickingReturn','Port2In', 'StopLickingReturn','Tup','ITI'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'StopLickingReturn', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup','StopLicking'},...
    'OutputActions', []); 

sma = AddState(sma, 'Name', 'NoResponse', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'TrialEnd'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'ITI', 'Timer', params.ITI,...
    'StateChangeConditionts', {'Tup', 'TrialEnd'},...
    'OutputActions', []);

% states that can't be reached, for posterity for reading Bpod data
% (expPipeline.m)
sma = AddState(sma, 'Name', 'TimeOut', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'TrialEnd'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'EarlyLickSample', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'TrialEnd'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'EarlyLickDelay', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'TrialEnd'},...
    'OutputActions', []);

sma = addTrialEndStates(sma);



function outputs = getOutputs(trialType)
global S

outputs.LeftWaterOutput = {'ValveState',2^0};
outputs.RightWaterOutput = {'ValveState',2^1};

switch S.GUI.NumLickPorts
    
    case 1 % 1 lick port, water only comes out of left lick port, no trial types
        
        if S.GUI.SpontCueType==1
            CueOutput = outputs.LeftWaterOutput;
            outputs.LeftResponse = [];
            outputs.RightResponse = [];
        end
        
    case 2
        
        if S.GUI.SpontCueType==1 % WaterDrop
            switch trialType
                case 1 % left
                    CueOutput = outputs.LeftWaterOutput;
                case 0 % right
                    CueOutput = outputs.RightWaterOutput;
            end
            outputs.LeftResponse = [];
            outputs.RightResponse = [];
        end
        
end


if S.GUI.SpontCueType==2 % None
    CueOutput = [];
    outputs.LeftResponse = outputs.LeftWaterOutput;
    outputs.RightResponse = outputs.RightWaterOutput;
end


if ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'EphysRig1'))
    
    if S.GUI.SpontCueType==3 % GoCue
        CueOutput = {'PWM4', 255};
        outputs.LeftResponse = outputs.LeftWaterOutput;
        outputs.RightResponse = outputs.RightWaterOutput;
    end
    
    if ~isempty(CueOutput)
        outputs.CueOutput = [CueOutput, 'BNCState',2];
    else
        outputs.CueOutput = {'BNCState', 2};
    end
    
elseif ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'Box'))
    
    if S.GUI.SpontCueType==3 % GoCue
        CueOutput = {'BNCState',1};
        outputs.LeftResponse = outputs.LeftWaterOutput;
        outputs.RightResponse = outputs.RightWaterOutput;
    end
    
    outputs.CueOutput = CueOutput;
end


if S.GUI.NumLickPorts == 1
    outputs.RightResponse = [];
end

