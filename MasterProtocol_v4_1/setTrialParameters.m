function params = setTrialParameters()
global S

if ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'EphysRig1'))
    % set S.wavParams during sendOutputWaveforms, only exists if any
    % CameraTrigger, MaskingFlash, or Stimulation checked.
    % Saved for use during data analysis.
    
    % sendOutputWaveforms runs at beginning of session, or if Stimulation
    % box gets checked during session
    
    if isfield(S,'wavParams')
        params.wav = S.wavParams; 
    else
        params.wav = [];
    end
end

params.Nlicks = getNLicks();

if S.GUI.ITI_Type == 1
    params.ITI = exprnd(S.GUI.ITI);
elseif S.GUI.ITI_Type == 2
    params.ITI = S.GUI.ITI;
end

params.giveStim = false;
if S.GUI.Stimulation
%     params.giveStim = rand(1)<S.GUI.StimProbability;
    if mod(S.trialNum, round(1./S.GUI.StimProbability))==0
        params.giveStim = 1;
    end
    
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
    if ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'Rig'))
        % stimNum gets used throughout protocol
        params.stimNum = randsample(numel(params.wav.stim.num),1);
        
        params.stimDur = params.wav.stim.dur{params.stimNum};
        params.stimLoc = params.wav.stim.loc{params.stimNum};
        
        % stimDel gets used in the delay of the global timer in setTimer
        % function in getStateMatrix
        pickDel = randsample(numel(params.wav.stim.del),1);
        params.stimDel = params.wav.stim.del{pickDel};
        
        % stimState gets used in getOutputs function in getStateMatrix to
        % determine which state to trigger the global timer
        pickState = randsample(numel(params.wav.stim.state),1);
        params.stimState = params.wav.stim.state{pickState};
        
    elseif ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'Box3'))
        params.stimNum = 1;
        params.stimDel = 0;
        params.stimDur = 0.9;
        params.stimLoc = 'Thalamus';
        params.stimState = 'Delay';
    end
    
else
    params.stimNum = 0;
end

%params.stimState



function Nlicks = getNLicks()
global S

if S.GUI.MinLicksForReward>=S.GUI.MaxLicksForReward
    Nlicks = ceil(S.GUI.MinLicksForReward);
else
    Nlicks = randsample(ceil(S.GUI.MinLicksForReward):ceil(S.GUI.MaxLicksForReward), 1);
end

if isnan(Nlicks) || Nlicks == 0
    Nlicks = 1;
    disp('!! input finite number of licks')
end