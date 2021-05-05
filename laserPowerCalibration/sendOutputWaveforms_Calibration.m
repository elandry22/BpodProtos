function trigProfNum = sendOutputWaveforms_Calibration(port)
global S
% saves params to S.wav

W = BpodWavePlayer(port);
W.SamplingRate = 10000;
W.TriggerProfileEnable = 'On';

params = [];

%Message #1 is cancel
serialMsgs{1} = 'X';


%Setup Stimulation waveform
duration = S.GUI.laserOnTime*W.SamplingRate;

xwav = zeros(1,duration); %does not change for "Origin" laser location
ywav = zeros(1,duration);

params.stim.num = [2:4];
params.stim.amp = S.GUI.outputVoltage;
params.stim.dur = duration;

distML = S.GUI.distML;
distAP = S.GUI.distAP;
angleCorFactor = S.GUI.angleCorFactor;

if strcmp(S.GUIMeta.laserLocation.String{S.GUI.laserLocation}, 'Bilateral')
    scanFreq = 40; %Hz
    tptsDwell = floor(W.SamplingRate.*(1./scanFreq)./2); % divide by scan freq and num positions
    
    xwav = [distML*ones(1,tptsDwell),-1*distML*ones(1,tptsDwell)];
    ywav = [distAP*ones(1,tptsDwell),distAP*ones(1,tptsDwell)*(1+tan(angleCorFactor))];
    
    numRepeats = floor(duration/numel(xwav));
    modRepeats = mod(duration,numel(xwav));
    
    xwav = repmat(xwav,1,numRepeats);
    xwav = [xwav, xwav(1:modRepeats)];
    
    ywav = repmat(ywav,1,numRepeats);
    ywav = [ywav, ywav(1:modRepeats)];
    
elseif strcmp(S.GUIMeta.laserLocation.String{S.GUI.laserLocation}, 'Bi_Scan')
    scanFreq = 40; %Hz
    tptsDwell = floor(W.SamplingRate.*(1./scanFreq)./2); % divide by scan freq and num positions
    
    xwav = [linspace(distML,-1*distML,tptsDwell), linspace(-1*distML,distML,tptsDwell)];
    ywav = [linspace(distAP,distAP*(1+tan(angleCorFactor)),tptsDwell),...
        linspace(distAP*(1+tan(angleCorFactor)),distAP,tptsDwell)];
    
    numRepeats = floor(duration/numel(xwav));
    modRepeats = mod(duration,numel(xwav));
    
    xwav = repmat(xwav,1,numRepeats);
    xwav = [xwav, xwav(1:modRepeats)];
    
    ywav = repmat(ywav,1,numRepeats);
    ywav = [ywav, ywav(1:modRepeats)];
    
elseif strcmp(S.GUIMeta.laserLocation.String{S.GUI.laserLocation}, 'Unilateral')
    scanFreq = 40; %Hz
    tptsDwell = floor(W.SamplingRate.*(1./scanFreq)); % divide by scan freq and num positions
    
    xwav = [distML*ones(1,tptsDwell)];
    ywav = [distAP*ones(1,tptsDwell)];
    
    numRepeats = floor(duration/numel(xwav));
    modRepeats = mod(duration,numel(xwav));
    
    xwav = repmat(xwav,1,numRepeats);
    xwav = [xwav, xwav(1:modRepeats)];
    
    ywav = repmat(ywav,1,numRepeats);
    ywav = [ywav, ywav(1:modRepeats)];
end


voltsPerMilimeter = 0.188;
xwav = xwav*voltsPerMilimeter;
ywav = ywav*voltsPerMilimeter;

params.stim.xpos = xwav;
params.stim.ypos = ywav;

params.stim.freq = 0;

params.stim.BNCchan.laser = 2;
params.stim.BNCchan.x = 4;
params.stim.BNCchan.y = 8;


loadStimWave_Calibration(W, params.stim, 1)
loadGalvoWaves_Calibration(W, params.stim, 1)

trigProfNum = params.stim.num(1);
W.TriggerProfiles(trigProfNum, :) = [0 params.stim.num];
serialMsgs{trigProfNum} = ['P' trigProfNum-1];


LoadSerialMessages('WavePlayer1', serialMsgs);
S.wavParams = params;



