function sma = setTimers(sma, params)

global S

locationNum = S.GUI.Location;

if ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Box'))
    
    sma = AddState(sma, 'Name', 'TrialStart', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'bit1'},...
        'OutputActions', []);
    
elseif ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Rig'))
    
    if S.GUI.SGLxTrigger
        sma = SetGlobalTimer(sma, 'TimerID', 1, 'Duration', 60, ...
            'OnsetDelay', 0, 'Channel', 'BNC1', 'OnsetValue', 1, 'OffsetValue', 0);
    end
    
    if S.GUI.CameraTrigger
        if params.giveStim
            wavIndex = params.stimNum;
            sma = SetGlobalTimer(sma, 'TimerID', 2, 'Duration', 60, 'OnsetDelay', 0, ...
                'Channel', 'WavePlayer1', 'OnMessage', params.wav.stim.num{wavIndex}(1),...
                'OffMessage', 1, 'Loop', 0, 'SendGlobalTimerEvents', 0);
        else
            sma = SetGlobalTimer(sma, 'TimerID', 2, 'Duration', 60, 'OnsetDelay', 0, ...
                'Channel', 'WavePlayer1', 'OnMessage', 2,...
                'OffMessage', 1, 'Loop', 0, 'SendGlobalTimerEvents', 0);
        end
    end
    
%     if S.GUI.MaskingFlash
% %         sma = SetGlobalTimer(sma, 'TimerID', 3, 'Duration', 60, 'OnsetDelay', 0, ...
% %             'Channel', 'WavePlayer1', 'OnMessage', 3, 'OffMessage', 1, ...
% %             'Loop', 0, 'SendGlobalTimerEvents', 0);
%     end
%     
%     if params.giveStim
% %         wavIndex = params.stimNum;
% %         
% % %         sma = SetGlobalTimer(sma, 'TimerID', 4, 'Duration', 60,...
% % %             'OnsetDelay', params.wav.stim.del{wavIndex}, 'Channel', 'WavePlayer1', ...
% % %             'OnMessage', params.wav.stim.num{wavIndex}(1), 'OffMessage', 1,...
% % %             'Loop', 0, 'SendGlobalTimerEvents', 0);
% %         
% %         sma = SetGlobalTimer(sma, 'TimerID', 4, 'Duration', 60,...
% %             'OnsetDelay', 0, 'Channel', 'WavePlayer1', ...
% %             'OnMessage', 10, 'OffMessage', 1,...
% %             'Loop', 0, 'SendGlobalTimerEvents', 0);
% %         
%     end
    
end