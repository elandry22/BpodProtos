function params = setTrialParameters()
global S

params.wav = initOutputWaveforms('COM5');
params.ITI = exprnd(S.GUI.ITI);
params.Nlicks = getNLicks();

params.stim = false;
if S.GUI.Stimulation
    params.stim = rand(1)<S.GUI.StimProbability;
end

params.stimState = '';

if params.stim
    possibleStates = params.wav.stim.possibleTrigStates;
    params.stimState = datasample(possibleStates, 1);
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