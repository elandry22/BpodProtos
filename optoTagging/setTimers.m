function sma = setTimers(sma, params)

global S


% gets triggered in 'TrigSGLX' state
% puts SpikeGLX in mode to record input
sma = SetGlobalTimer(sma, 'TimerID', 1, 'Duration', 1.1*S.GUI.stimDur, ...
    'OnsetDelay', 0, 'Channel', 'BNC1', 'OnsetValue', 1, 'OffsetValue', 0);


wavIndex = params.stimNum;

sma = SetGlobalTimer(sma, 'TimerID', 2, 'Duration', 60,...
    'OnsetDelay', params.stimDel, 'Channel', 'WavePlayer1', ...
    'OnMessage', params.wav.stim.num{wavIndex}(1), 'OffMessage', 1,...
    'Loop', 0, 'SendGlobalTimerEvents', 1);
    


