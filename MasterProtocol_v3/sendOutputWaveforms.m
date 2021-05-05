function sendOutputWaveforms(port)
global S
% saves params to S.wav







if ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'EphysRig1'))
    
    %try
        if any([S.GUI.CameraTrigger S.GUI.MaskingFlash S.GUI.Stimulation])
            W = BpodWavePlayer(port);
            W.SamplingRate = 10000;
            W.TriggerProfileEnable = 'On';

            params = [];
            serialMsgs = cell(1, 4);
            
            %Message #1 is cancel
            serialMsgs{1} = 'X';
            
            %Setup camera trigger waveform
            params.cam.freq = 400;
            params.cam.BNCchan = 1;
            params.cam.waveNum = 2;
            params.cam.pulsewid = 0.5; %ms
            params.cam.duration = 20; %sec
        
            W.TriggerProfiles(1,:) = [2 0 0 0];
%             serialMsgs(2) = {['P' params.cam.BNCchan params.cam.waveNum-1]};
            serialMsgs{2} = ['P' 0];
            loadSquareWave(W, params.cam)
            
            
            %Setup masking flash waveform
            params.mask.freq = 10;
            params.mask.BNCchan = 2;
            params.mask.waveNum = 3;
            params.mask.pulsewid = 50; %ms
            params.mask.duration = 20; %sec
            %     W.LoopDuration(params.mask.BNCchan) = 2;
            %     W.LoopMode{params.mask.BNCchan} = 'On';
%             serialMsgs(3) = {['P' params.mask.BNCchan params.mask.waveNum-1]};
%             loadSquareWave(W, params.mask)
            
            
            %Setup Stimulation waveform
            num = {}; % indices of each waveform, used for serial message index
            amp = {}; del = {}; dur = {}; xpos = {}; ypos = {}; state = {};
            
            xwav = zeros(1,20);%[linspace(-2.5, 2.5, 10) linspace(2.5, -2.5, 10)]*0.188;  %0.188 V/mm
            ywav = xwav.*tan(0.1331);
            
            
            tStartDel = 0.01 + 0.01 + 0.01*25 + 0.01;
            
            
            
            num{end+1} = [10:12];
            amp{end+1} = 1.2;%6;
            del{end+1} = tStartDel+S.GUI.SamplePeriod+0.0; 
            dur{end+1} = 0.4;
            xpos{end+1} = xwav;
            ypos{end+1} = ywav;
            state(end+1) = {'Delay'};
            
            
            num{end+1} = [13:15]; 
            amp{end+1} = 1.2;%6; 
            del{end+1} = tStartDel+S.GUI.SamplePeriod+0.3; 
            dur{end+1} = 0.4; 
            xpos{end+1} = xwav; 
            ypos{end+1} = ywav; 
            state(end+1) = {'Delay'};
            
            
            num{end+1} = [16:18]; 
            amp{end+1} = 1.2;%6; 
            del{end+1} = tStartDel+S.GUI.SamplePeriod+S.GUI.DelayPeriod+0.0; 
            dur{end+1} = 1.0;   
            xpos{end+1} = xwav; 
            ypos{end+1} = ywav; 
            state(end+1) = {'GoCue'};
            
            
            num{end+1} = [19:21]; 
            amp{end+1} = 1.2;%6; 
            del{end+1} = tStartDel+S.GUI.SamplePeriod+S.GUI.DelayPeriod+0.5; 
            dur{end+1} = 1.0;   
            xpos{end+1} = xwav; 
            ypos{end+1} = ywav; 
            state(end+1) = {'GoCue'};
            
            
            params.stim.num = num;
            params.stim.amp = amp;
            params.stim.del = del;
            params.stim.dur = dur;
            params.stim.xpos = xpos;
            params.stim.ypos = ypos;
            params.stim.state = state;
            params.stim.rampDur = 0.2;
            params.stim.freq = 0;
            
            params.stim.BNCchan.laser = 2;
            params.stim.BNCchan.x = 4;
            params.stim.BNCchan.y = 8;
            
            params.stim.tStartDel = tStartDel;
            
            for i =1:numel(num)
                loadStimWave(W, params.stim, i)
                loadGalvoWaves(W, params.stim, i)
                
                W.TriggerProfiles(num{i}(1), :) = [2 num{i}];
                serialMsgs{num{i}(1)} = ['P' num{i}(1)-1];
%                 serialMsgs(num{i}(1)) = {['P' params.stim.BNCchan.laser num{i}(1)-1]};
%                 serialMsgs(num{i}(2)) = {['P' params.stim.BNCchan.x num{i}(2)-1]};
%                 serialMsgs(num{i}(3)) = {['P' params.stim.BNCchan.y num{i}(3)-1]};
            end         
%             ResetSerialMessages;
%             serialMsgs = cell(1, 10);
%             serialMsgs{10} = ['P' 9];
%             serialMsgs = serialMsgs(1:10);
%             serialMsgs{2} = [];
            Acknowledged = LoadSerialMessages('WavePlayer1', serialMsgs)
            S.wavParams = params;
        end
        

        
    %catch
%         disp('Could not initialize BpodWavePlayer');
%         return;
    %end
end
