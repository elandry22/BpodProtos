function [next_trial] = trialSelection(TrialNum)
global BpodSystem S;

if S.GUI.ProtocolType < 4
    if ~isempty(BpodSystem.Data.TrialTypes)
        %behavioralPerformance('update', TrialNum);
        MaxSame = S.GUI.MaxSame;
        LeftTrialProb = S.GUI.LeftTrialProb;
        %TrialNum = BpodSystem.Data.nTrials;
        lastTrialNum = TrialNum - 1;
        lastTrialType = BpodSystem.Data.TrialTypes(lastTrialNum);
        lastOtherTrialType = find(BpodSystem.Data.TrialTypes(1:lastTrialNum) ~= lastTrialType, 1, 'last'); % returns last index of trial of other type
        if isempty(lastOtherTrialType)
            lastOtherTrialType=0; % designate if no trials of other type
        end
        NumCurrType = lastTrialNum - lastOtherTrialType;
        
        CurrNumCorrect = sum(BpodSystem.Data.dataToPlot.Hit(lastOtherTrialType+1:lastTrialNum));
        
        switch S.GUI.Autolearn
            
            case 1  % Autolearn 'On'
                if CurrNumCorrect >= MaxSame
                    next_trial = not(lastTrialType);
                else
                    next_trial = lastTrialType;
                end
                
            case 2  % Autolearn 'Off'
                
                if NumCurrType >= MaxSame
                    next_trial = not(lastTrialType);
                else
                    if rand(1) <= LeftTrialProb
                        next_trial = 1;
                    else
                        next_trial = 0;
                    end
                end
                
            case 3  % Autolearn 'antiBias'
                
                next_trial = getAntibiasTrial(lastTrialNum, LeftTrialProb, lastOtherTrialType, lastTrialType);
                
        end
        
    else
        next_trial = round(rand(1));
    end
    
    if next_trial == 1
        BpodSystem.Data.dataToPlot.Left(TrialNum) = 1;
    elseif next_trial == 0
        BpodSystem.Data.dataToPlot.Right(TrialNum) = 1;
    else
        disp('trialSelection: next trial type not designated')
    end

elseif S.GUI.ProtocolType == 4
    next_trial = round(rand(1));
end





function next_trial = getAntibiasTrial(lastTrialNum, LeftTrialProb, lastOtherTrialType, lastTrialType)
global BpodSystem S

MaxSame = S.GUI.MaxSame;

leftBad = 0;
rightBad = 0;

correct_R_history = (BpodSystem.Data.dataToPlot.Hit==1 & BpodSystem.Data.dataToPlot.Right==1); % vector containing 1s on correct left trials
correct_L_history = (BpodSystem.Data.dataToPlot.Hit==1 & BpodSystem.Data.dataToPlot.Left==1); % vector containing 1s on correct right trials
incorrect_R_history = (BpodSystem.Data.dataToPlot.Error==1 & BpodSystem.Data.dataToPlot.Right==1); % vector containing 1s on incorrect left `trials
incorrect_L_history = (BpodSystem.Data.dataToPlot.Error==1 & BpodSystem.Data.dataToPlot.Left==1); % vector containing 1s on incorrect right trials

if lastTrialNum > 20
    percent_R_corr = sum(correct_R_history(lastTrialNum-19:lastTrialNum)) / (sum(correct_R_history(lastTrialNum-19:lastTrialNum))+sum(correct_L_history(lastTrialNum-19:lastTrialNum)) );
    % proportion of correct trials that were right
    percent_L_incorr = sum(incorrect_L_history(lastTrialNum-19:lastTrialNum)) / (sum(incorrect_R_history(lastTrialNum-19:lastTrialNum))+sum(incorrect_L_history(lastTrialNum-19:lastTrialNum)) );
    % proportion of incorrect trials that were
    % left
    newLeftTrialProb = percent_R_corr/2 + percent_L_incorr/2;%generate left trial prob
else
    newLeftTrialProb = LeftTrialProb;
end

if isnan(newLeftTrialProb)
    newLeftTrialProb = LeftTrialProb;
end

if MaxSame <= lastTrialNum && (lastTrialNum-lastOtherTrialType) >= MaxSame && lastTrialNum > 20
    next_trial = not(lastTrialType); % if MaxSame applies AND there's been a string of MaxSame trials of one type, force change
else
    if rand(1)<=newLeftTrialProb
        next_trial = 1;
    else
        next_trial = 0;
    end
    % antibias using parameters from GUI
    if S.GUI.Max_incorrect_Left>=1 || S.GUI.Max_incorrect_Right>=1
        max_inc_left=floor(S.GUI.Max_incorrect_Left);
        min_cor_left=floor(S.GUI.Min_correct_Left);
        max_inc_right=floor(S.GUI.Max_incorrect_Right);
        min_cor_right=floor(S.GUI.Min_correct_Right);
        if sum(BpodSystem.Data.dataToPlot.Left==1) >= 11 && sum(BpodSystem.Data.dataToPlot.Right==1) >= 11
            if sum(correct_L_history==1) > 1 && sum(correct_R_history==1) > 1
                pastTrialsL = max(10, max_inc_left+min_cor_left);
                pastTrialsR = max(10, max_inc_right+min_cor_right);
                
                recent_L_history = correct_L_history(BpodSystem.Data.dataToPlot.Left==1); % outcomes of left trials
                recent_L_history = recent_L_history(end-pastTrialsL:end); % look at last pastTrialsL trials
                char_recent_L_history = char(double(recent_L_history')); % turn to character vector for use in "contains" function
                
                recent_R_history = correct_R_history(BpodSystem.Data.dataToPlot.Right==1);
                recent_R_history = recent_R_history(end-pastTrialsR:end);
                char_recent_R_history = char(double(recent_R_history'));
                
                inc_patternL = char(zeros(1, max_inc_left));% create character vector of max_inc_left 0's
                inc_patternR = char(zeros(1, max_inc_right));% create character vector of max_inc_right 0's
                
                if ~isempty(strfind(char_recent_L_history, inc_patternL)) % use this syntax for compatability with older versions of matlab
                    if sum(recent_L_history==1) < min_cor_left
                        next_trial=1; % if max_inc_left occur in a row in the last pastTrialsL, force left trial
                        leftBad=1;
                    end
                end
                
                if ~isempty(strfind(char_recent_R_history, inc_patternR)) % use this syntax for compatability with older versions of matlab
                    if sum(recent_R_history==1) < min_cor_right
                        next_trial=0; % if max_inc_right occur in a row in the last pastTrialsR, force right trial
                        rightBad=1;
                    end
                end
                
                if leftBad==1 && rightBad==1
                    if rand(1) <= newLeftTrialProb
                        next_trial = 1; % if both bad, choose using newLeftTrialProb
                    end
                end
            end
        end
    end
end
