function sendOutputWaveforms_optoTagging(port)
global S
% saves params to S.wav

params = [];
S = BpodParameterGUI('sync', S);



W = BpodWavePlayer(port);
W.SamplingRate = 10000;
W.TriggerProfileEnable = 'On';

params = [];

%Message #1 is cancel
serialMsgs{1} = 'X';


%Setup camera trigger waveform
params.cam.freq = 400;
params.cam.BNCchan = 1;
params.cam.waveNum = 2;
params.cam.pulsewid = 0.5; %ms
params.cam.duration = S.GUI.ProtoDur; %sec
params.cam.pulseAmp = 5;
% camera wav always loaded
% added to stim trigger profile if camera trigger is on
loadSquareWave(W, params.cam)




%Setup Stimulation waveform
NSamp = S.GUI.ProtoDur*W.SamplingRate; % num time points

%does not change
xwav = zeros(1,NSamp); 
ywav = zeros(1,NSamp);

params.stim.num = [3:5];
% params.stim.amp = S.GUI.outputVoltage;
params.stim.nSamp = NSamp;

params.stim.laser.freq = S.GUI.PulseFreq; % Hz
params.stim.laser.BNCchan = 2;
params.stim.laser.waveNum = params.stim.num(1);
params.stim.laser.pulsewid = S.GUI.PulseWidth; %ms
params.stim.laser.duration = S.GUI.ProtoDur; %sec
params.stim.laser.pulseAmp = S.GUI.PulseAmp; %V

params.stim.xpos = xwav;
params.stim.ypos = ywav;

params.stim.BNCchan.cam = 1;
params.stim.BNCchan.laser = 2;
params.stim.BNCchan.x = 4;
params.stim.BNCchan.y = 8;

loadSquareWave(W, params.stim.laser)
loadGalvoWaves_optoTagging(W, params.stim)

trigProfNum = params.stim.num(1);
W.TriggerProfiles(trigProfNum, :) = [0 params.stim.num];
serialMsgs{trigProfNum} = ['P' trigProfNum-1]; % zero indexed here

if S.GUI.CameraTrigger
    W.TriggerProfiles(trigProfNum, :) = [params.cam.waveNum params.stim.num];
end


LoadSerialMessages('WavePlayer1', serialMsgs);
S.wavParams = params;



