function sma = addTrialEndStates(sma,params)
global S

locationNum = S.GUI.Location;

if ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Box'))
    sma = AddState(sma, 'Name', 'TrialEnd', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', []); % pole up and trial end
    
elseif ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Rig'))
    
    outputAction = {};
 
    if S.GUI.SGLxTrigger
        outputAction(end+1:end+2) = {'GlobalTimerCancel', 1};
    end
    if S.GUI.CameraTrigger
        outputAction(end+1:end+2) = {'GlobalTimerCancel', 2};
    end
    if S.GUI.MaskingFlash
%         outputAction(end+1:end+2) = {'GlobalTimerCancel', 3};
    end
    if params.giveStim
%         outputAction(end+1:end+2) = {'GlobalTimerCancel', 4};
    end
    if isempty(outputAction)
        outputAction = [];
    end
    
    sma = AddState(sma, 'Name', 'TrialEnd', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', outputAction); % trial end
end