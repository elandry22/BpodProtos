function [next_trial] = trialSelectionSpontaneousLick(TrialNum)
global BpodSystem S;

protoType = S.GUI.ProtocolType;

if ~isempty(strfind(S.GUIMeta.ProtocolType.String{protoType}, 'WaterDrop'))
    if ~isempty(BpodSystem.Data.TrialTypes)
        %behavioralPerformance('update', TrialNum);
        MaxSame = S.GUI.MaxSame;
        LeftTrialProb = S.GUI.LeftTrialProb;
        
        lastTrialNum = TrialNum - 1;
        lastTrialType = BpodSystem.Data.TrialTypes(lastTrialNum);
        lastOtherTrialType = find(BpodSystem.Data.TrialTypes(1:lastTrialNum) ~= lastTrialType, 1, 'last'); % returns last index of trial of other type
        if isempty(lastOtherTrialType)
            lastOtherTrialType=0; % designate if no trials of other type
        end
        
        NumCurrType = lastTrialNum - lastOtherTrialType;
        
        if NumCurrType >= MaxSame
            next_trial = not(lastTrialType);
        else
            if rand(1) <= LeftTrialProb
                next_trial = 1;
            else
                next_trial = 0;
            end
        end
        
        
        
    else
        next_trial = round(rand(1));
    end
else
    next_trial = [];
end

if next_trial == 1
    BpodSystem.Data.dataToPlot.Left(TrialNum) = 1;
elseif next_trial == 0
    BpodSystem.Data.dataToPlot.Right(TrialNum) = 1;
elseif ~isempty(next_trial)
    disp('!! trialSelection: next trial type not designated')
end