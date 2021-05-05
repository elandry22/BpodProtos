function params = initOutputWaveforms(port)
global S

params = [];

serialMsgs = cell(1, 4);
try
    if any([S.GUI.CameraTrigger S.GUI.MaskingFlash S.GUI.Stimulation])
        W = BpodWavePlayer(port);
        W.SamplingRate = 10000;
    end
catch
    disp('Could not initialize BpodWavePlayer');
    return;
end
serialMsgs{1} = 'X';
%Setup camera trigger waveform
if S.GUI.CameraTrigger
    params.cam.freq = 400;
    params.cam.BNCchan = 1;
    params.cam.waveNum = 2;
    params.cam.pulsewid = 0.5; %ms
    params.cam.duration = 1; %sec
    
    serialMsgs(2) = {['P' params.cam.BNCchan params.cam.waveNum-1]};
    loadSquareWave(W, params.cam)
end

%Setup masking flash waveform
if S.GUI.MaskingFlash
    params.mask.freq = 10;
    params.mask.BNCchan = 2;
    params.mask.waveNum = 3;
    params.mask.pulsewid = 50; %ms
    params.mask.duration = 1; %sec
%     W.LoopDuration(params.mask.BNCchan) = 2;
%     W.LoopMode{params.mask.BNCchan} = 'On';
    serialMsgs(3) = {['P' params.mask.BNCchan params.mask.waveNum-1]};
    loadSquareWave(W, params.mask)
end

%Setup Stimulation waveform
if S.GUI.Stimulation
    params.stim.freq = 0;
    params.stim.BNCchan = 4;
    params.stim.waveNum = 4;
    params.stim.duration = 0.4; %sec
    params.stim.delay = 0; %sec
    params.stim.rampDownDur = 0.2; %sec
    params.stim.amplitude = 1; %v
    params.stim.possibleTrigStates = {'Delay'; 'GoCue'};
    
    serialMsgs(4) = {['P' params.stim.BNCchan params.stim.waveNum-1]};
    loadStimWave(W, params.stim)
end


LoadSerialMessages('WavePlayer1', serialMsgs);
