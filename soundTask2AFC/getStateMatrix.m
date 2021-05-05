function [sma, params] = getStateMatrix(trialType, TrialNum, ITI, Nlicks)    
global S

if S.GUI.ProtocolType < 4
    
    params.Nlicks = Nlicks;
    params.ITI = NaN;
    
    actions = getActions(trialType, params.Nlicks);
    outputs = getOutputs(trialType);
    
    [sma, params] = getSoundTaskStateMatrix(params, outputs, actions, TrialNum);
    
elseif S.GUI.ProtocolType == 4
    
    outputs = getOutputsSpontaneous(trialType);
    
    [sma, params] = getSpontaneousLickStateMatrix(outputs, TrialNum, ITI);
    params.Nlicks = 1;
    params.ITI = ITI;
end





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






function outputs = getOutputs(trialType)
global S

outputs.LeftWaterOutput = {'ValveState',2^0};
outputs.RightWaterOutput = {'ValveState',2^1};

switch trialType % Determine trial-specific state matrix fields
    case 1  % lick left
        SoundChannel = 'PWM1';
        RewardOutput = outputs.LeftWaterOutput;
    case 0  % lick right
        SoundChannel = 'PWM2';
        RewardOutput = outputs.RightWaterOutput;
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
    outputs.CueOutput = {'PWM4', 255, 'BNCState', 2};
elseif ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'Box'))
    outputs.CueOutput = {'PWM4', 255, 'BNCState', 2};%{'BNCState',1};
end
outputs.RewardOutput = RewardOutput;







function outputs = getOutputsSpontaneous(trialType)
global S

outputs.LeftWaterOutput = {'ValveState',2^0}; % BNC state 2??
outputs.RightWaterOutput = {'ValveState',2^1};


if S.GUI.CueType==1 % WaterDrop
    switch trialType
        case 1 % left
            CueOutput = outputs.LeftWaterOutput;
        case 0 % right
            CueOutput = outputs.RightWaterOutput;
    end
    %outputs.Response = [];
    outputs.LeftResponse = [];
    outputs.RightResponse = [];
end

if S.GUI.CueType==2 % None
    CueOutput = [];
    %outputs.Response = [outputs.WaterOutput];
    outputs.LeftResponse = outputs.LeftWaterOutput;
    outputs.RightResponse = outputs.RightWaterOutput;
end


% outputs.SoundOutput = {SoundChannel,255};
if ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'EphysRig1'))
    
    if S.GUI.CueType==3 % GoCue
        CueOutput = {'PWM4', 255};
        %outputs.Response = [outputs.WaterOutput];
        outputs.LeftResponse = outputs.LeftWaterOutput;
        outputs.RightResponse = outputs.RightWaterOutput;
    end
    
    if ~isempty(CueOutput)
        outputs.CueOutput = [CueOutput, 'BNCState',2];
    else
        outputs.CueOutput = {'BNCState', 2};
    end
    
elseif ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'Box'))
    
    if S.GUI.CueType==3 % GoCue
        CueOutput = {'BNCState',1};
        %outputs.Response = outputs.WaterOutput;
        outputs.LeftResponse = outputs.LeftWaterOutput;
        outputs.RightResponse = outputs.RightWaterOutput;
    end
    
    outputs.CueOutput = CueOutput;
end


