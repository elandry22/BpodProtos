function [sma, params] = getStateMatrix(trialType, TrialNum)    



outputs = getOutputs(trialType);

[sma, params] = getSpontaneousLickStateMatrix(outputs, TrialNum);





function outputs = getOutputs(trialType)
global S

outputs.WaterOutput = {'ValveState',2^0}; % BNC state 2??
%outputs.RightWaterOutput = {'ValveState',2^1};
outputs.ResponseLeft = [];
outputs.ResponseRight = [];

if S.GUI.ProtocolType==1
    CueOutput = outputs.WaterOutput;
    outputs.Response = {};
end

if S.GUI.ProtocolType==2
    CueOutput = [];
    outputs.Response = outputs.WaterOutput;
end


% outputs.SoundOutput = {SoundChannel,255};
if ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'EphysRig1'))
    if S.GUI.ProtocolType==3
        CueOutput = {'PWM4', 255};
        outputs.Response = {outputs.WaterOutput, 'BNCState',2};
    end
    outputs.CueOutput = {CueOutput, 'BNCState',2};
elseif ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'Box'))
    if S.GUI.ProtocolType==3
        CueOutput = {'PWM4', 255};%{'BNCState',1};
        outputs.Response = outputs.WaterOutput;
    end
    outputs.CueOutput = {CueOutput};
end

% 
% 
% 
% function Nlicks = getNLicks(TrialNum)
% global S BpodSystem
% 
% if S.GUI.MinLicksForReward>=S.GUI.MaxLicksForReward
%     Nlicks = S.GUI.MinLicksForReward;
% else
%     Nlicks = randsample(S.GUI.MinLicksForReward:S.GUI.MaxLicksForReward, 1);
% end
% 
% BpodSystem.Data.Nlicks(TrialNum) = Nlicks;
% disp(['          Must lick ' num2str(Nlicks) ' times for reward this trial']);



