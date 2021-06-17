function params = setTrialParameters()
% sets Nlicks, ITI, determines if stim is given, selects stim delay and
% state
global S BpodSystem

params.Nlicks = getNLicks();

if S.GUI.ITI_Type == 1
    params.ITI = exprnd(S.GUI.ITI);
elseif S.GUI.ITI_Type == 2
    params.ITI = S.GUI.ITI;
end

params.giveStim = false;
params.stimNum = 0;
if S.GUI.Stimulation
    params.giveStim = rand(1)<S.GUI.StimProbability;
end


if params.giveStim
    % stimNum gets used throughout protocol
    stimParams = BpodSystem.Data.SessionMeta.wavParams(end).stim;
    
    params.stimNum = randsample(numel(stimParams.num),1);
    params.stimDur = stimParams.dur{params.stimNum};
    params.stimAmp = stimParams.amp{params.stimNum};
    params.stimLoc = stimParams.loc{params.stimNum};
    
    % stimDel gets used in the delay of the global timer in setTimer
    % function in getStateMatrix
    pickDel = randsample(numel(stimParams.del),1);
    params.stimDel = stimParams.del{pickDel};
    
    % stimState gets used in getOutputs function in getStateMatrix to
    % determine which state to trigger the global timer
    pickState = randsample(numel(stimParams.state),1);
    params.stimState = stimParams.state{pickState};    
    
end

end % setTrialParameters

%% Helper Functions

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
end % getNLicks