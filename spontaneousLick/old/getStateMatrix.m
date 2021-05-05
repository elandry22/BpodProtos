function [sma, params] = getStateMatrix(trialType, TrialNum)    

params.Nlicks = getNLicks(TrialNum);

actions = getActions(trialType, params.Nlicks);
outputs = getOutputs(trialType);

[sma, params] = getSpontaneousLickStateMatrix(params, outputs, actions, TrialNum);




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

outputs.LeftWaterOutput = {'ValveState',2^0, 'BNCState', 2};
outputs.RightWaterOutput = {'ValveState',2^1, 'BNCState', 2};

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
    outputs.CueOutput = {'PWM4', 255, 'BNCState',2};
elseif ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'Box'))
    outputs.CueOutput = {'BNCState',1};
end
outputs.RewardOutput = RewardOutput;




function Nlicks = getNLicks(TrialNum)
global S BpodSystem

if S.GUI.MinLicksForReward>=S.GUI.MaxLicksForReward
    Nlicks = S.GUI.MinLicksForReward;
else
    Nlicks = randsample(S.GUI.MinLicksForReward:S.GUI.MaxLicksForReward, 1);
end

BpodSystem.Data.Nlicks(TrialNum) = Nlicks;
disp(['          Must lick ' num2str(Nlicks) ' times for reward this trial']);






