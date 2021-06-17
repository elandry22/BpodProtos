function sma = setTimers(sma, params)

global S

locationNum = S.GUI.Location;

S.Timers = zeros(1,4);


if ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Rig'))
    
    if S.GUI.SGLxTrigger
        
        sma = SetGlobalTimer(sma, 'TimerID', 1, 'Duration', 60, ...
            'OnsetDelay', 0, 'Channel', 'BNC1', 'OnsetValue', 1, 'OffsetValue', 0);
        S.Timers(1) = 1;
        
    end
    
    if S.GUI.CameraTrigger
        
        sma = SetGlobalTimer(sma, 'TimerID', 2, 'Duration', 60, 'OnsetDelay', 0, ...
            'Channel', 'WavePlayer1', 'OnMessage', 2,...
            'OffMessage', 1, 'Loop', 0, 'SendGlobalTimerEvents', 1);
        S.Timers(2) = 1;
    end
    
%     if S.GUI.MaskingFlash
% %         sma = SetGlobalTimer(sma, 'TimerID', 3, 'Duration', 60, 'OnsetDelay', 0, ...
% %             'Channel', 'WavePlayer1', 'OnMessage', 3, 'OffMessage', 1, ...
% %             'Loop', 0, 'SendGlobalTimerEvents', 0);
% %         S.Timers(3) = 1;
%     end
    
    if params.giveStim
        wavIndex = params.stimNum;
        
        sma = SetGlobalTimer(sma, 'TimerID', 4, 'Duration', 60,...
            'OnsetDelay', params.stimDel, 'Channel', 'WavePlayer1', ...
            'OnMessage', params.wav.stim.num{wavIndex}(1), 'OffMessage', 1,...
            'Loop', 0, 'SendGlobalTimerEvents', 1);
        S.Timers(4) = 1;
    
    end
    
end