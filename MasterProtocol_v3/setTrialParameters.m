function params = setTrialParameters()
global S

if ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'EphysRig1'))
    params.wav = S.wavParams; % set S.wavParams during sendOutputWaveforms,
    % run at beginning of session or if Stimulation box gets checked during
    % session
end

params.ITI = exprnd(S.GUI.ITI);
params.Nlicks = getNLicks();

params.giveStim = false;
if S.GUI.Stimulation
    params.giveStim = rand(1)<S.GUI.StimProbability;
end

% params.trialStim.state = {};
% params.trialStim.wavIndex = [];
% 
% if params.giveStim
%     possibleStates = unique(params.wav.stim.state);% params.wav.stim.possibleTrigStates;
%     params.trialStim.state = datasample(possibleStates, 1); % randomly sample from possible stim states
%     
%     sameStateIndices = find(strcmp(params.trialStim.state,params.wav.stim.state));
%     delayIndex = floor(rand(1)*numel(sameStateIndices));
%     params.trialStim.wavIndex = sameStateIndices(1) + delayIndex;
% end

if params.giveStim
    params.stimNum = randsample(numel(params.wav.stim.num),1);
else
    params.stimNum = 0;
end

%params.stimState



function Nlicks = getNLicks()
global S

if S.GUI.MinLicksForReward>=S.GUI.MaxLicksForReward
    Nlicks = S.GUI.MinLicksForReward;
else
    Nlicks = randsample(S.GUI.MinLicksForReward:S.GUI.MaxLicksForReward, 1);
end

if isnan(Nlicks)
    Nlicks = 1;
    disp('!! input finite number of licks')
end