function wavParams = sendOutputWaveforms(port)
global S

wavParams = [];
S = BpodParameterGUI('sync', S);

if ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'EphysRig1'))
    
    %try
        if any([S.GUI.CameraTrigger S.GUI.MaskingFlash S.GUI.Stimulation])
            W = BpodWavePlayer(port);
            W.SamplingRate = 10000;
            
            
            W.TriggerProfileEnable = 'On';

%             wavParams = [];
            serialMsgs = cell(1, 4);
            
            %Message #1 is cancel
            serialMsgs{1} = 'X';
            % % % cam stuff doesn't need to be saved each trial
            %Setup camera trigger waveform
            wavParams.cam.freq = 400;
            wavParams.cam.BNCchan = 1;
            wavParams.cam.waveNum = 2;
            wavParams.cam.pulsewid = 0.5; %ms
            wavParams.cam.duration = 20; %sec
            wavParams.cam.pulseAmp = 5;
            
            W.TriggerProfiles(1,:) = [2 0 0 0]; % [cameraBNC, stimBNC, xBNC, yBNC]
%             serialMsgs(2) = {['P' wavParams.cam.BNCchan wavParams.cam.waveNum-1]};
            serialMsgs{2} = ['P' 0]; % play profile 0 (ie W.TriggerProfiles(1,:))
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
%             for i = 1:numel(unique(cell2mat(wavParams.stim.dur)))
%                 xWavNum = 2+2*i;
%                 yWavNum = 3+2*i;
%                 W.loadWaveform(xWavNum, wavParams.stim.xpos{i})
%                 W.loadWaveform(yWavNum, wavParams.stim.ypos{i}
%             end
            
%             wavParams.stim.BNCchan.laser = 2;
%             wavParams.stim.BNCchan.x = 4;
%             wavParams.stim.BNCchan.y = 8;
            
%             wavParams.stim.tStartDel = tStartDel;
            

            for i =1:numel(wavParams.stim.num)
                loadStimWave(W, wavParams.stim, i)
                loadGalvoWaves(W, wavParams.stim, i)
                
                % trigger profiles are vectors with each index
                % corresponding to the wavenumber WN to be played on that BNC channel
                % [cameraBNC, stimBNC, xBNC, yBNC]
                if S.GUI.CameraTrigger
                    W.TriggerProfiles(wavParams.stim.num{i}(1), :) = [2 wavParams.stim.num{i}];
                else
                    W.TriggerProfiles(wavParams.stim.num{i}(1), :) = [0 wavParams.stim.num{i}];
                end
%                 serialMsgs{num{i}(1)} = ['P' num{i}(1)-1];
%                 serialMsgs(num{i}(1)) = {['P' wavParams.stim.BNCchan.laser num{i}(1)-1]};
%                 serialMsgs(num{i}(2)) = {['P' wavParams.stim.BNCchan.x num{i}(2)-1]};
%                 serialMsgs(num{i}(3)) = {['P' wavParams.stim.BNCchan.y num{i}(3)-1]};

                serialMsgs{wavParams.stim.num{i}(1)} = ['P' wavParams.stim.num{i}(1)-1]; % zero indexed for serial messages!
                % serialMsgs specifies action ('P' = play) and trigger profile
                % trigger profile is vector of length 4
                % serial messages get sent to WavePlayer after profiles for
                % all stims are set up
            end         

            Acknowledged = LoadSerialMessages('WavePlayer1', serialMsgs);
            
        end
        

        
    %catch
%         disp('Could not initialize BpodWavePlayer');
%         return;
    %end
end






