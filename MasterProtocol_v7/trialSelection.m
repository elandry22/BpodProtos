function next_trial = trialSelection(TrialNum)
global BpodSystem S;

% trial types
%   0 - left
%   1 - right

% trial types for block position task (mouse's orientation)
% 1 - rightmost
% 2 - right of center
% 3 - center
% 4 - left of center
% 5 - leftmost

% trial types for foraging task (mouse's orientation)
% 1 - right
% 2 - center 
% 3 - left

if TrialNum > 1
    
    MaxSame = S.GUI.MaxSame;
    LeftTrialProb = S.GUI.LeftTrialProb;
    lastTrialNum = TrialNum - 1;
    lastTrialType = BpodSystem.Data.TrialTypes(lastTrialNum);
    lastOtherTrialType = find(BpodSystem.Data.TrialTypes(1:lastTrialNum) ~= lastTrialType, 1, 'last'); % returns last index of trial of other type
    
    if isempty(lastOtherTrialType)
        lastOtherTrialType=0; % designate if no trials of other type
    end
    
    NumTrialsCurrentType = lastTrialNum - lastOtherTrialType;
    
    CurrentNumCorrect = sum(BpodSystem.Data.TrialData.Hit(lastOtherTrialType+1:lastTrialNum));
    CurrentNumIncorrect = sum(BpodSystem.Data.TrialData.Error(lastOtherTrialType+1:lastTrialNum))+sum(BpodSystem.Data.TrialData.NoResponse(lastOtherTrialType+1:lastTrialNum));
    CurrentNumNoResponse = sum(BpodSystem.Data.TrialData.NoResponse(lastOtherTrialType+1:lastTrialNum));
    
    switch S.GUI.ProtocolType
        
        case {1, 2, 3, 4} % {1, 2, 3} 2AFC and {4} spontaneous
            
            switch S.GUI.Autolearn
                
                case 1  % Autolearn 'On'
                    if CurrentNumCorrect >= MaxSame
                        next_trial = not(lastTrialType);
                    else
                        next_trial = lastTrialType;
                    end
                    
                case 2  % Autolearn 'Off'
                    
                    if NumTrialsCurrentType >= MaxSame
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
                    
                case 4 % Autolearn 'PeriodicHelp'
                    
                    if CurrentNumCorrect >= MaxSame || CurrentNumIncorrect >= 10
                        next_trial = not(lastTrialType);
                    else
                        
                        next_trial = lastTrialType;
                    end
                    
                    NoRespThreshold = 15+rand*10;
                    
%                     if CurrentNumNoResponse >= NoRespThreshold
%                         helpAutowater = helpAutowater+1;
%                         S.GUI.Autowater = 1;
%                     end
                    
            end
            
            if S.GUI.ProtocolType == 4 && S.GUI.NumLickPorts == 1 % if spontaneous w/ 1 lick port
                    next_trial = 1; % force left trial
            end
            
        case 5 % Lick Sequence

                switch S.GUI.Direction
                    case 1 % LearnAlternating
                        
                        if CurrentNumCorrect > 0 || CurrentNumIncorrect >= MaxSame
                            next_trial = not(lastTrialType);
                        else
                            next_trial = lastTrialType;
                        end
                        
                    case 2 % Alternating
                        
                        next_trial = not(lastTrialType);
                        
                    case 3 % Random
                        
                        next_trial = round(rand(1));
                        
                    case 4 % LeftToRight
                        
                        next_trial = 1;
                        
                    case 5 % RightToLeft
                        
                        next_trial = 0;
                        
                end
                         
                
    end
else
    next_trial = round(rand(1));
    
    
end


%%%%%%%%%% BLOCK POSITION TASK %%%%%%%%%%
if S.GUI.ProtocolType == 6 % block position
    
    nPositions = S.GUI.NumPositions;
    blockSize = S.GUI.blocksize;
    trialNum = TrialNum;
    trialType = BpodSystem.Data.TrialTypes;
    
    % set up block set parameter
    % this keeps track of how many times we've cycled through every
    % condition
    if trialNum == 1 
        BpodSystem.Data.blockSet = 1;
    end
    blockSet = BpodSystem.Data.blockSet;
    
   % if first trial or new block set (1,51,101,etc), choose new trial type
   if trialNum == 1 || (trialNum-1) == ((blockSet-1)*nPositions*blockSize)
       next_trial = randi(nPositions);
       
   % if new block within a block set (21,31,61,71,111,121,etc), choose new
   % trial type not already visited with current block set
   elseif mod(trialNum-1,blockSize)==0
       % if blockSet == 1, look through all prev trialTypes
       if blockSet == 1
           next = randi(nPositions);
           while ismember(next,trialType)
             next = randi(nPositions);
           end
           next_trial = next;
       % if blockSet ~= 1, look through all trialTypes of current block set
       % only
       else
           next = randi(nPositions);
           while ismember(next,trialType(((blockSet-1)*nPositions*blockSize)+1:end))
             next = randi(nPositions);
           end
           next_trial = next;
       end
       
   % if middle of block, use previous trial type
   else
       next_trial = trialType(trialNum-1);
   end
   
   % iterate blockSet
   if trialNum == (blockSet*nPositions*blockSize)
       BpodSystem.Data.blockSet = BpodSystem.Data.blockSet + 1;
   end
       
end
%%%%%%%%%% BLOCK POSITION TASK %%%%%%%%%%

%%%%%%%%%% FORAGING TASK %%%%%%%%%%
if S.GUI.ProtocolType == 7 % foraging task
    
    nPositions = S.GUI.numLickPorts;
    blockSize = S.GUI.blockSize;
    trialNum = TrialNum;
    trialType = BpodSystem.Data.TrialTypes;
    
    % set up block set parameter
    % this keeps track of how many times we've cycled through every
    % condition
    if trialNum == 1 
        BpodSystem.Data.blockSet = 1;
    end
    blockSet = BpodSystem.Data.blockSet;
    
   % if first trial or new block set (1,51,101,etc), choose new trial type
   if trialNum == 1 || (trialNum-1) == ((blockSet-1)*nPositions*blockSize)
       next_trial = randi(nPositions);
       
   % if new block within a block set (21,31,61,71,111,121,etc), choose new
   % trial type not already visited with current block set
   elseif mod(trialNum-1,blockSize)==0
       % if blockSet == 1, look through all prev trialTypes
       if blockSet == 1
           next = randi(nPositions);
           while ismember(next,trialType)
             next = randi(nPositions);
           end
           next_trial = next;
       % if blockSet ~= 1, look through all trialTypes of current block set
       % only
       else
           next = randi(nPositions);
           while ismember(next,trialType(((blockSet-1)*nPositions*blockSize)+1:end))
             next = randi(nPositions);
           end
           next_trial = next;
       end
       
   % if middle of block, use previous trial type
   else
       next_trial = trialType(trialNum-1);
   end
   
   % iterate blockSet
   if trialNum == (blockSet*nPositions*blockSize)
       BpodSystem.Data.blockSet = BpodSystem.Data.blockSet + 1;
   end
       
end
%%%%%%%%%% FORAGING TASK %%%%%%%%%%



function next_trial = getAntibiasTrial(lastTrialNum, LeftTrialProb, lastOtherTrialType, lastTrialType)
global BpodSystem S

MaxSame = S.GUI.MaxSame;

leftBad = 0;
rightBad = 0;

correct_R_history = (BpodSystem.Data.TrialData.Hit==1 & BpodSystem.Data.TrialData.Right==1); % vector containing 1s on correct left trials
correct_L_history = (BpodSystem.Data.TrialData.Hit==1 & BpodSystem.Data.TrialData.Left==1); % vector containing 1s on correct right trials
incorrect_R_history = (BpodSystem.Data.TrialData.Error==1 & BpodSystem.Data.TrialData.Right==1); % vector containing 1s on incorrect left `trials
incorrect_L_history = (BpodSystem.Data.TrialData.Error==1 & BpodSystem.Data.TrialData.Left==1); % vector containing 1s on incorrect right trials

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
        if sum(BpodSystem.Data.TrialData.Left==1) >= 11 && sum(BpodSystem.Data.TrialData.Right==1) >= 11
            if sum(correct_L_history==1) > 1 && sum(correct_R_history==1) > 1
                pastTrialsL = max(10, max_inc_left+min_cor_left);
                pastTrialsR = max(10, max_inc_right+min_cor_right);
                
                recent_L_history = correct_L_history(BpodSystem.Data.TrialData.Left==1); % outcomes of left trials
                recent_L_history = recent_L_history(end-pastTrialsL:end); % look at last pastTrialsL trials
                char_recent_L_history = char(double(recent_L_history')); % turn to character vector for use in "contains" function
                
                recent_R_history = correct_R_history(BpodSystem.Data.TrialData.Right==1);
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





