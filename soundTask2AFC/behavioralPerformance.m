function behavioralPerformance(Action, TrialNum, spontaneousPeriod, soundTaskPeriod)
global BpodSystem S
MAXTRIALS = 9999;

switch Action
    
    case 'init'

        % initialize dataToPlot
        initDataToPlot();
        
        % initialize performance data
        initStatPlot();
        
        BpodSystem.Data.dataToPlotStr = {'Reversal'; 'Autowater'; 'Autolearn'; 'Early'; 'Left'; 'Right'; 'Hit'; 'Error'}; 
        BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
        BpodSystem.Data.Nlicks = NaN.*zeros(MAXTRIALS,1);
        
    case 'initNewPeriod'
        if S.GUI.ProtocolType < 4
            Period = soundTaskPeriod;
        elseif S.GUI.ProtocolType == 4
            Period = spontaneousPeriod;
        end
        initStatPlotNewPeriod(Period);
        
    case 'update'
        
        if ~isempty(BpodSystem.Data.TrialTypes)
            
            % initialize output variables
            initDataToPlot_Update(TrialNum, spontaneousPeriod, soundTaskPeriod);
            
            if isfield(BpodSystem.Data.TrialSettings(TrialNum),'GUI') && ~isempty(BpodSystem.Data.TrialSettings(TrialNum).GUI) && BpodSystem.Data.TrialSettings(TrialNum).GUI.ProtocolType>=2 && isfield(BpodSystem.Data,'TrialTypes') %isfield(Data.RawEvents.Trial{TrialNum}.States,'Reward')
                if S.GUI.ProtocolType < 4
                    
                    % determine if mouse licked early, if early lick enforced
                    getTrialEarlyLick(TrialNum);
                    
                    % determine if autolearn on
                    getTrialAutolearn(TrialNum);
                    
                    % determine if autowater on
                    getTrialAutowater(TrialNum);
                    
                    % determine if reversal on
                    getTrialReversal(TrialNum);
                end
                % determine trial type
                getTrialType(TrialNum, spontaneousPeriod, soundTaskPeriod);
                
                % correct, incorrect, or no response
                getTrialOutcome(TrialNum, spontaneousPeriod, soundTaskPeriod);  %
                
                % make protocol type easily accessible
                saveProtocolType(TrialNum);
                
                savePeriod(TrialNum, spontaneousPeriod, soundTaskPeriod);
                
            end
            
        else

            disp('!! behavioralPerformance: trialTypes empty, performance not determined')
        end
        
        
end


function initDataToPlot()
global BpodSystem
MAXTRIALS = 9999;

BpodSystem.Data.ProtocolHistory = NaN.*zeros(MAXTRIALS,1);

BpodSystem.Data.dataToPlot.Right = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Left = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Early = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Autolearn = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Autowater = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Reversal = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Hit = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Error = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.NoResponse = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.WaterDrop = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.None = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.GoCue = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Licked = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.LickedLeft = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.LickedRight = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.NoResponseSpontaneous = NaN.*zeros(MAXTRIALS,1);


function initStatPlot()
global BpodSystem
MAXTRIALS = 9999;

BpodSystem.Data.Stats.All = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.Stats.Recent = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.Stats.R = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.Stats.L = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.Stats.NoResponse = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.Stats.NoResponseSpontaneous = NaN.*zeros(MAXTRIALS,1);

function initStatPlotNewPeriod(Period)
global BpodSystem S
MAXTRIALS = 9999;

if S.GUI.ProtocolType ~= 4
    BpodSystem.Data.Stats.(['ST' num2str(Period)]).All = NaN.*zeros(MAXTRIALS,1);
    BpodSystem.Data.Stats.(['ST' num2str(Period)]).Recent = NaN.*zeros(MAXTRIALS,1);
    BpodSystem.Data.Stats.(['ST' num2str(Period)]).R = NaN.*zeros(MAXTRIALS,1);
    BpodSystem.Data.Stats.(['ST' num2str(Period)]).L = NaN.*zeros(MAXTRIALS,1);
    BpodSystem.Data.Stats.(['ST' num2str(Period)]).NoResponse = NaN.*zeros(MAXTRIALS,1);
elseif S.GUI.ProtocolType == 4
    BpodSystem.Data.Stats.(['S' num2str(Period)]).NoResponse = NaN.*zeros(MAXTRIALS,1);
end


function initDataToPlot_Update(TrialNum, spontaneousPeriod, soundTaskPeriod)
global BpodSystem S

BpodSystem.Data.dataToPlot.Right(TrialNum) = 0;
BpodSystem.Data.dataToPlot.Left(TrialNum) = 0;
BpodSystem.Data.dataToPlot.Hit(TrialNum) = 0;
BpodSystem.Data.dataToPlot.Error(TrialNum) = 0;
BpodSystem.Data.dataToPlot.NoResponse(TrialNum) = 0;
BpodSystem.Data.dataToPlot.Early(TrialNum) = -1;
BpodSystem.Data.dataToPlot.Autolearn(TrialNum) = 1;
BpodSystem.Data.dataToPlot.Autowater(TrialNum) = 0;
BpodSystem.Data.dataToPlot.Reversal(TrialNum) = 0;
BpodSystem.Data.dataToPlot.WaterDrop(TrialNum) = 0;
BpodSystem.Data.dataToPlot.None(TrialNum) = 0;
BpodSystem.Data.dataToPlot.GoCue(TrialNum) = 0;
BpodSystem.Data.dataToPlot.Licked(TrialNum) = 0;
BpodSystem.Data.dataToPlot.LickedLeft(TrialNum) = 0;
BpodSystem.Data.dataToPlot.LickedRight(TrialNum) = 0;
BpodSystem.Data.dataToPlot.NoResponseSpontaneous(TrialNum) = 0;
if S.GUI.ProtocolType ~= 4
    BpodSystem.Data.dataToPlot.(['ST' num2str(soundTaskPeriod)]).Right(TrialNum) = 0;
    BpodSystem.Data.dataToPlot.(['ST' num2str(soundTaskPeriod)]).Left(TrialNum) = 0;
    BpodSystem.Data.dataToPlot.(['ST' num2str(soundTaskPeriod)]).Hit(TrialNum) = 0;
    BpodSystem.Data.dataToPlot.(['ST' num2str(soundTaskPeriod)]).Error(TrialNum) = 0;
    BpodSystem.Data.dataToPlot.(['ST' num2str(soundTaskPeriod)]).NoResponse(TrialNum) = 0;
elseif S.GUI.ProtocolType == 4
    BpodSystem.Data.dataToPlot.(['S' num2str(spontaneousPeriod)]).Licked(TrialNum) = 0;
    BpodSystem.Data.dataToPlot.(['S' num2str(spontaneousPeriod)]).LickedLeft(TrialNum) = 0;
    BpodSystem.Data.dataToPlot.(['S' num2str(spontaneousPeriod)]).LickedRight(TrialNum) = 0;
    BpodSystem.Data.dataToPlot.(['S' num2str(spontaneousPeriod)]).NoResponse(TrialNum) = 0;
end


function getTrialType(TrialNum, spontaneousPeriod, soundTaskPeriod)
global BpodSystem S

% if S.GUI.ProtocolType ~= 4
if BpodSystem.Data.TrialTypes(TrialNum) == 0 % right trial
    BpodSystem.Data.dataToPlot.Right(TrialNum) = 1;
    BpodSystem.Data.dataToPlot.(['ST' num2str(soundTaskPeriod)]).Right(TrialNum) = 1;
elseif BpodSystem.Data.TrialTypes(TrialNum) == 1 % left trial
    BpodSystem.Data.dataToPlot.Left(TrialNum) = 1;
    BpodSystem.Data.dataToPlot.(['ST' num2str(soundTaskPeriod)]).Left(TrialNum) = 1;
end
if S.GUI.ProtocolType == 4
    if S.GUI.CueType == 1
        BpodSystem.Data.dataToPlot.WaterDrop(TrialNum) = 1;
        BpodSystem.Data.dataToPlot.(['S' num2str(spontaneousPeriod)]).WaterDrop(TrialNum) = 1;
    elseif S.GUI.CueType == 2
        BpodSystem.Data.dataToPlot.None(TrialNum) = 1;
        BpodSystem.Data.dataToPlot.(['S' num2str(spontaneousPeriod)]).None(TrialNum) = 1;
    elseif S.GUI.CueType == 3
        BpodSystem.Data.dataToPlot.GoCue(TrialNum) = 1;
        BpodSystem.Data.dataToPlot.(['S' num2str(spontaneousPeriod)]).GoCue(TrialNum) = 1;
    end
end


function getTrialEarlyLick(TrialNum)
global BpodSystem S

if S.GUI.ProtocolType==3
    
    if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.EarlyLickSample(1)) || ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.EarlyLickDelay(1))
        BpodSystem.Data.dataToPlot.Early(TrialNum) = 1; % early
    else
        BpodSystem.Data.dataToPlot.Early(TrialNum) = 0; % not early
    end
        
elseif S.GUI.ProtocolType==2
    
    if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.EarlyLickSample(1))
        BpodSystem.Data.dataToPlot.Early(TrialNum) = 1; % early
    else
        BpodSystem.Data.dataToPlot.Early(TrialNum) = 0; % not early
    end
    
end


function getTrialAutolearn(TrialNum)
global BpodSystem

if BpodSystem.Data.TrialSettings(TrialNum).GUI.Autolearn == 2
    BpodSystem.Data.dataToPlot.Autolearn(TrialNum) = 0; % autolearn off
elseif BpodSystem.Data.TrialSettings(TrialNum).GUI.Autolearn == 3
    BpodSystem.Data.dataToPlot.Autolearn(TrialNum) = 2; % antibias on
end


function getTrialAutowater(TrialNum)
global BpodSystem

if BpodSystem.Data.TrialSettings(TrialNum).GUI.Autowater == 1
    BpodSystem.Data.dataToPlot.Autowater(TrialNum) = 1; % autowater on
end


function getTrialReversal(TrialNum)
global BpodSystem

if BpodSystem.Data.TrialSettings(TrialNum).GUI.Reversal == 2 % reversal on
    BpodSystem.Data.dataToPlot.Reversal(TrialNum) = 1;
end


function getTrialOutcome(TrialNum, spontaneousPeriod, soundTaskPeriod)
global BpodSystem S

if S.GUI.ProtocolType < 4
    
    if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.Reward(1)) % if reached reward state
        BpodSystem.Data.dataToPlot.Hit(TrialNum) = 1;
        BpodSystem.Data.dataToPlot.(['ST' num2str(soundTaskPeriod)]).Hit(TrialNum) = 1;
    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.TimeOut(1)) % if reached timeout state
        BpodSystem.Data.dataToPlot.Error(TrialNum) = 1;
        BpodSystem.Data.dataToPlot.(['ST' num2str(soundTaskPeriod)]).Error(TrialNum) = 1;
    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.NoResponse(1)) % if reached no response
        BpodSystem.Data.dataToPlot.NoResponse(TrialNum) = 1;
        BpodSystem.Data.dataToPlot.(['ST' num2str(soundTaskPeriod)]).NoResponse(TrialNum) = 1;
    end
    
elseif S.GUI.ProtocolType == 4
    
    if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.LickedLeft(1)) % if reached licked left state
        BpodSystem.Data.dataToPlot.LickedLeft(TrialNum) = 1;
        BpodSystem.Data.dataToPlot.(['S' num2str(spontaneousPeriod)]).LickedLeft(TrialNum) = 1;
    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.LickedRight(1)) % if reached licked right state
        BpodSystem.Data.dataToPlot.LickedRight(TrialNum) = 1;
        BpodSystem.Data.dataToPlot.(['S' num2str(spontaneousPeriod)]).LickedRight(TrialNum) = 1;
    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.NoResponse(1)) % if reached no response
        BpodSystem.Data.dataToPlot.NoResponseSpontaneous(TrialNum) = 1;
        BpodSystem.Data.dataToPlot.(['S' num2str(spontaneousPeriod)]).NoResponse(TrialNum) = 1;
    end

    if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.Reward(1)) % if reached reward state
        BpodSystem.Data.dataToPlot.Hit(TrialNum) = 1;
        BpodSystem.Data.dataToPlot.(['S' num2str(spontaneousPeriod)]).Hit(TrialNum) = 1;
    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.NoResponse(1)) % if reached no response
        BpodSystem.Data.dataToPlot.NoResponse(TrialNum) = 1;
        BpodSystem.Data.dataToPlot.(['S' num2str(spontaneousPeriod)]).NoResponse(TrialNum) = 1;
    end
    
end


function saveProtocolType(TrialNum)
global BpodSystem S

BpodSystem.Data.ProtocolHistory(TrialNum) = S.GUI.ProtocolType;

function savePeriod(TrialNum, spontaneousPeriod, soundTaskPeriod)
global BpodSystem

BpodSystem.Data.spontaneousPeriod(TrialNum) = spontaneousPeriod;
BpodSystem.Data.soundTaskPeriod(TrialNum) = soundTaskPeriod;
