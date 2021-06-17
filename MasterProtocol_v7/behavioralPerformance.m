function behavioralPerformance(Action, TrialNum)
global BpodSystem S

% executed once at beginning of session
% then once at the end of each trial

switch Action
    
    case 'init'

        % initialize TrialData
        initTrialDataFields();
        
        % initialize performance data
        initStats();
        
    case 'update'
        
        if ~isempty(BpodSystem.Data.TrialTypes)
            
            % initialize output variables
            initTrialData(TrialNum);
            
            if isfield(BpodSystem.Data,'GUISettings') && ~isempty(BpodSystem.Data.GUISettings(TrialNum)) && isfield(BpodSystem.Data,'TrialTypes')
                % determine trial type
                updateTrialType(TrialNum);
                
                % correct, incorrect, or no response
                updateTrialOutcome(TrialNum);
                
                % make protocol type easily accessible
                saveProtocolType(TrialNum);
                
                saveStats(TrialNum);
                
                switch S.GUI.ProtocolType
                    
                    case {1, 2, 3} % 2AFC steps 1-3
                        
                        % plot all 2AFC variables
                        update2AFCvariables(TrialNum);
                        
                    case 4 % cue type
                        
                        % determine cue type
                        updateSpontaneousVariables(TrialNum);
                        
                    case 5 % lick sequence
                        
                        updateSequenceVariables(TrialNum);
                end
            end
            
        else
            disp('!! behavioralPerformance: trialTypes empty, performance not determined')
        end
        
        
end

% INIT FUNCTIONS

function initTrialDataFields()
global BpodSystem
MAXTRIALS = 9999;

BpodSystem.Data.ProtocolHistory = NaN.*zeros(MAXTRIALS,1);

BpodSystem.Data.TrialData.Right = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.TrialData.Left = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.TrialData.Early = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.TrialData.Autolearn = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.TrialData.Autowater = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.TrialData.Reversal = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.TrialData.Hit = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.TrialData.Error = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.TrialData.NoResponse = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.TrialData.WaterDrop = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.TrialData.None = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.TrialData.GoCue = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.TrialData.LickedLeft = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.TrialData.LickedRight = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.TrialData.Licked = NaN.*zeros(MAXTRIALS,1);


function initStats()
global BpodSystem
MAXTRIALS = 9999;

BpodSystem.Data.Stats.All = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.Stats.Recent = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.Stats.R = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.Stats.L = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.Stats.NoResponse = NaN.*zeros(MAXTRIALS,1);



function initTrialData(TrialNum)
global BpodSystem

BpodSystem.Data.TrialData.Right(TrialNum) = 0;
BpodSystem.Data.TrialData.Left(TrialNum) = 0;
BpodSystem.Data.TrialData.Hit(TrialNum) = 0;
BpodSystem.Data.TrialData.Error(TrialNum) = 0;
BpodSystem.Data.TrialData.NoResponse(TrialNum) = 0;
BpodSystem.Data.TrialData.Early(TrialNum) = -1;
BpodSystem.Data.TrialData.Autolearn(TrialNum) = 1;
BpodSystem.Data.TrialData.Autowater(TrialNum) = 0;
BpodSystem.Data.TrialData.Reversal(TrialNum) = 0;
BpodSystem.Data.TrialData.WaterDrop(TrialNum) = 0;
BpodSystem.Data.TrialData.None(TrialNum) = 0;
BpodSystem.Data.TrialData.GoCue(TrialNum) = 0;
BpodSystem.Data.TrialData.Licked(TrialNum) = 0;
BpodSystem.Data.TrialData.LickedLeft(TrialNum) = 0;


% UPDATE FUNCTIONS


function updateTrialType(TrialNum)
global BpodSystem

if BpodSystem.Data.TrialTypes(TrialNum) == 1 % left trial
    BpodSystem.Data.TrialData.Left(TrialNum) = 1;
elseif BpodSystem.Data.TrialTypes(TrialNum) == 0 % right trial
    BpodSystem.Data.TrialData.Right(TrialNum) = 1;
end


function update2AFCvariables(TrialNum)

% determine if mouse licked early, if early lick enforced
updateTrialEarlyLick(TrialNum);

% determine if autolearn on
updateTrialAutolearn(TrialNum);

% determine if autowater on
updateTrialAutowater(TrialNum);

% determine if reversal on
updateTrialReversal(TrialNum);



function updateSpontaneousVariables(TrialNum)

% determine cue type
updateCueType(TrialNum)


function updateSequenceVariables(TrialNum)

% determine if mouse licked early
updateTrialEarlyLick(TrialNum);

% determine if autowater on
updateTrialAutowater(TrialNum);



function updateTrialEarlyLick(TrialNum)
global BpodSystem S

if S.GUI.ProtocolType==3
    
    if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.EarlyLickSample(1))
        BpodSystem.Data.TrialData.Early(TrialNum) = 1;
    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.EarlyLickDelay(1))
        BpodSystem.Data.TrialData.Early(TrialNum) = 1;
    else
        BpodSystem.Data.TrialData.Early(TrialNum) = 0; % not early
    end
        
elseif S.GUI.ProtocolType==2
    
    if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.EarlyLickSample(1))
        BpodSystem.Data.TrialData.Early(TrialNum) = 1; % early
    else
        BpodSystem.Data.TrialData.Early(TrialNum) = 0; % not early
    end
   
elseif S.GUI.ProtocolType == 5
    
    if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.StopLickingBeforeReturn(1))
        BpodSystem.Data.TrialData.Early(TrialNum) = 1; % early
    else
        BpodSystem.Data.TrialData.Early(TrialNum) = 0; % not early
    end
    
end


function updateTrialAutolearn(TrialNum)
global BpodSystem

if BpodSystem.Data.GUISettings(TrialNum).Autolearn == 2
    BpodSystem.Data.TrialData.Autolearn(TrialNum) = 0; % autolearn off
elseif BpodSystem.Data.GUISettings(TrialNum).Autolearn == 3
    BpodSystem.Data.TrialData.Autolearn(TrialNum) = 2; % antibias on
end


function updateTrialAutowater(TrialNum)
global BpodSystem

if BpodSystem.Data.GUISettings(TrialNum).Autowater == 1
    BpodSystem.Data.TrialData.Autowater(TrialNum) = 1; % autowater on
end


function updateTrialReversal(TrialNum)
global BpodSystem

if BpodSystem.Data.GUISettings(TrialNum).Reversal == 2 % reversal on
    BpodSystem.Data.TrialData.Reversal(TrialNum) = 1;
end




function updateCueType(TrialNum)
global BpodSystem S

if S.GUI.ProtocolType == 4
    if S.GUI.SpontCueType == 1
        BpodSystem.Data.TrialData.WaterDrop(TrialNum) = 1;
    elseif S.GUI.SpontCueType == 2
        BpodSystem.Data.TrialData.None(TrialNum) = 1;
    elseif S.GUI.SpontCueType == 3
        BpodSystem.Data.TrialData.GoCue(TrialNum) = 1;
    end
end


function updateTrialOutcome(TrialNum)
global BpodSystem S

if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.Reward(1)) % if reached reward state
    BpodSystem.Data.TrialData.Hit(TrialNum) = 1;
end

if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.NoResponse(1)) % if reached no response
    BpodSystem.Data.TrialData.NoResponse(TrialNum) = 1;
end

switch S.GUI.ProtocolType % protocol specific variables on trial outcome
    case {1, 2, 3} % 2AFC
        
        if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.TimeOut(1)) % if reached timeout state
            BpodSystem.Data.TrialData.Error(TrialNum) = 1;
        end
        
    case 4 % spontaneous
        
        if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.TimeOut(1)) % if reached timeout state
            BpodSystem.Data.TrialData.Error(TrialNum) = 1;
        end
        
        % might be unnecessary
        if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.LickedLeft(1)) % if reached licked left state
            BpodSystem.Data.TrialData.LickedLeft(TrialNum) = 1;
        elseif ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.LickedRight(1)) % if reached licked right state
            BpodSystem.Data.TrialData.LickedRight(TrialNum) = 1;
        end
        
    case 5 % sequence task
        
        if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.TimeOut(1)) % if reached timeout state
            BpodSystem.Data.TrialData.Error(TrialNum) = 1;
        end
                
end


function saveProtocolType(TrialNum)
global BpodSystem S

BpodSystem.Data.ProtocolHistory(TrialNum) = S.GUI.ProtocolType;


function saveStats(TrialNum)
global BpodSystem S

if sum(BpodSystem.Data.TrialData.NoResponse==0) > 0 % if mouse responded at least once
    BpodSystem.Data.Stats.All(TrialNum) = sum(BpodSystem.Data.TrialData.Hit==1)/sum(BpodSystem.Data.TrialData.NoResponse==0);
end

Nrecent = S.GUI.NrecentTrials;

if TrialNum>=Nrecent
    if sum(BpodSystem.Data.TrialData.NoResponse(TrialNum-(Nrecent-1):TrialNum)==0) > 0 % if mouse responded at least once during last Nrecent trials
        recentHits = sum(BpodSystem.Data.TrialData.Hit(TrialNum-(Nrecent-1):TrialNum)==1);
        recentResponseTotal = sum(BpodSystem.Data.TrialData.NoResponse(TrialNum-(Nrecent-1):TrialNum)==0);
        BpodSystem.Data.Stats.Recent(TrialNum) = recentHits/recentResponseTotal;
    end
else
    if sum(BpodSystem.Data.TrialData.NoResponse==0) > 0
        recentHits = sum(BpodSystem.Data.TrialData.Hit==1);
        recentResponseTotal = sum(BpodSystem.Data.TrialData.NoResponse==0);
        BpodSystem.Data.Stats.Recent(TrialNum) = recentHits/recentResponseTotal;
    end
end

if sum(BpodSystem.Data.TrialData.Right==1) > 0
    rightHits = sum(BpodSystem.Data.TrialData.Hit==1 & BpodSystem.Data.TrialData.Right==1);
    rightTotal = sum(BpodSystem.Data.TrialData.Right==1 & BpodSystem.Data.TrialData.NoResponse==0);
    BpodSystem.Data.Stats.R(TrialNum) = rightHits/rightTotal;
end

if sum(BpodSystem.Data.TrialData.Left==1) > 0
    leftHits = sum(BpodSystem.Data.TrialData.Hit==1 & BpodSystem.Data.TrialData.Left==1);
    leftTotal = sum(BpodSystem.Data.TrialData.Left==1 & BpodSystem.Data.TrialData.NoResponse==0);
    BpodSystem.Data.Stats.L(TrialNum) = leftHits/leftTotal;    
end

if TrialNum > 0
    BpodSystem.Data.Stats.NoResponse(TrialNum) = sum(BpodSystem.Data.TrialData.NoResponse==1)/TrialNum;
end



