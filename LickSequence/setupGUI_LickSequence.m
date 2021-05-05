function setupGUI_LickSequence()

global S
S = struct;

if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.centerX = 25; % absolute center horizontal motor position (mm)
    S.GUI.deltaX = 10; % distance between positions (mm)
    S.GUI.SerialPort = 2; % Motor controlled by Module 2
    S.GUI.Npositions = 5; % Number of positions in Sequence
    S.GUI.NTrials = 2; % total number of trials
    S.GUI.ResponseTime = 10; % no response time
    S.GUI.RewardDelay = 0.25; % Reward Delay 0.25 sec in paper
    S.GUI.StopLickingPeriod = 1; % wait time after last lick to change state
    S.GUI.ITImu = 1; % mu = 6 seconds for paper
end

