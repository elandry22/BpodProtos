function sma = addTrialEndStates(sma,params)
global S BpodSystem

locationNum = S.GUI.Location;
% BpodSystem.StateMatrix.GlobalTimers
if ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Box'))
    sma = AddState(sma, 'Name', 'TrialEnd', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', []); % pole up and trial end
    
elseif ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Rig'))
    
%     outputAction = {};

sma = AddState(sma, 'Name', 'TrialEnd', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'TrialEnd1'},...
    'OutputActions', []);
    
    for i = 1:length(S.Timers)
        outputAction = [];
        if S.Timers(i)
%             outputAction(end+1:end+2) = {'GlobalTimerCancel', i};
            
            outputAction = {'GlobalTimerCancel', i};
%             sma = AddState(sma, 'Name', ['TrialEnd', num2str(i)], 'Timer', 0.01,...
%                 'StateChangeConditions', {'Tup', 'exit'},...
%                 'OutputActions', outputAction); % trial end
        end
        sma = AddState(sma, 'Name', ['TrialEnd', num2str(i)], 'Timer', 0.01,...
            'StateChangeConditions', {'Tup', ['TrialEnd', num2str(i+1)]},...
            'OutputActions', outputAction); % trial end
    end
 
%     if exist(S.Timers.t1, 'var')
%         outputAction(end+1:end+2) = {'GlobalTimerCancel', 1};
%     end
%     if exist(S.Timers.t2, 'var')%S.GUI.CameraTrigger
%         outputAction(end+1:end+2) = {'GlobalTimerCancel', 2};
%     end
%     if exist(S.Timers.t3, 'var')%S.GUI.MaskingFlash
%         outputAction(end+1:end+2) = {'GlobalTimerCancel', 3};
%     end
%     if exist(S.Timers.t4, 'var')%params.giveStim
%         outputAction(end+1:end+2) = {'GlobalTimerCancel', 4};
%     end
%     if isempty(outputAction)
%         outputAction = [];
        sma = AddState(sma, 'Name', ['TrialEnd', num2str(length(S.Timers)+1)], 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', []); % trial end
%     end
    
    
end