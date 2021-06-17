function wavParams = sendOutputWaveforms(port)
% Sets up and sends waveforms to waveplayer
%   -Camera trigger waveforms, laser waveforms, x galvo waveforms, and y
%    galvo waveforms
%
% Serial messages
%   -cell array
%   -send commands to the Bpod such as 'play trigger profile 3'
%       serialMsgs{12} = ['P' 3-1]
%   -INDICES FOR serialMsgs START AT 1
%   -USES TRIGGER PROFILES INDEXED FROM 0
%   -serial messages get sent to WavePlayer in LoadSerialMessages after 
%       1) waveforms are loaded
%           -loadSquareWave
%           -loadStimWave
%           -loadGalvoWaves
%       2) trigger profiles are specified
%
%
% Trigger profiles
%   -sent within a serial message
%   -allow you to send different waveforms to each BNC channel
%   -1x4 vector where each index corresponds to a BNC channel:
%       [cameraBNCchan, stimBNCchan, xGalvoBNCchan, yGalvoBNCchan]
%   -the elements put into a trigger profile are the waveNums for waveforms
%    to be played on each channel:
%       [0 15 16 17] sends nothing to the camera, waveNum 15 to the laser,
%           waveNum 16 to the x galvo, and waveNum 17 to the y galvo
%   -saved as W.TriggerProfiles(3,:) = [0 15 16 17]
%   -INDICES START AT 1
%       To play this in a serial message, subtract 1 from the profile index
%       serialMsgs{14} = ['P' 2]

global S

wavParams = [];
S = BpodParameterGUI('sync', S);

if ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'EphysRig1'))
    
    %try
        if any([S.GUI.CameraTrigger S.GUI.MaskingFlash S.GUI.Stimulation])
            W = BpodWavePlayer(port);
            W.SamplingRate = 10000;
                       
            W.TriggerProfileEnable = 'On';

            serialMsgs = cell(1, 4);
            
            %Message #1 is cancel
            serialMsgs{1} = 'X';

            % Camera trigger waveform parameters
            wavParams.cam.freq = 400;
            wavParams.cam.BNCchan = 1;
            wavParams.cam.waveNum = 2;
            wavParams.cam.pulsewid = 0.5; %ms
            wavParams.cam.duration = 20; %sec
            wavParams.cam.pulseAmp = 5;
            wavParams.cam.trigProf = 1;
            
            W.TriggerProfiles(wavParams.cam.trigProf,:) = [2 0 0 0]; 
            serialMsgs{2} = ['P' wavParams.cam.trigProf-1]; 
            loadSquareWave(W, wavParams.cam)
            
            
            %Setup masking flash waveform
%             wavParams.mask.freq = 10;
%             wavParams.mask.BNCchan = 2;
%             wavParams.mask.waveNum = 3;
%             wavParams.mask.pulsewid = 50; %ms
%             wavParams.mask.duration = 20; %sec
%             %     W.LoopDuration(wavParams.mask.BNCchan) = 2;
%             %     W.LoopMode{wavParams.mask.BNCchan} = 'On';
%             serialMsgs(3) = {['P' wavParams.mask.BNCchan wavParams.mask.waveNum-1]};
%             loadSquareWave(W, wavParams.mask)
            
            
            %Setup Stimulation waveform
            wavParams.stim = getStimParams(W);

            for i =1:numel(wavParams.stim.num)
                loadStimWave(W, wavParams.stim, i)
                loadGalvoWaves(W, wavParams.stim, i)
                
                if S.GUI.CameraTrigger
                    W.TriggerProfiles(wavParams.stim.num{i}(1), :) = [2 wavParams.stim.num{i}];
                else
                    W.TriggerProfiles(wavParams.stim.num{i}(1), :) = [0 wavParams.stim.num{i}];
                end

                serialMsgs{wavParams.stim.num{i}(1)} = ['P' wavParams.stim.num{i}(1)-1]; % zero indexed for serial messages!
                 
            end         

            Acknowledged = LoadSerialMessages('WavePlayer1', serialMsgs);
            % can be unsupressed to see in command line that waveforms were
            % successfully sent to waveplayer
        end
        
end