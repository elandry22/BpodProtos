function behavioralPerformance(Action, TrialNum)
global BpodSystem
MAXTRIALS = 9999;

switch Action
    
    case 'init'

        % initialize dataToPlot
        initDataToPlot();
        
        % initialize performance data
        initPerfPlot();
        
        BpodSystem.Data.dataToPlotStr = {'Reversal'; 'Autowater'; 'Autolearn'; 'Early'; 'Left'; 'Right'; 'Hit'; 'Error'}; 
        BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
        BpodSystem.Data.Nlicks = NaN.*zeros(MAXTRIALS,1);
        
    case 'update'
        
        if ~isempty(BpodSystem.Data.TrialTypes)
            
            % initialize output variables
            initDataToPlot_Update(TrialNum);
            
            if isfield(BpodSystem.Data.TrialSettings(TrialNum),'GUI') && ~isempty(BpodSystem.Data.TrialSettings(TrialNum).GUI) && BpodSystem.Data.TrialSettings(TrialNum).GUI.ProtocolType>=2 && isfield(BpodSystem.Data,'TrialTypes') %isfield(Data.RawEvents.Trial{TrialNum}.States,'Reward')
                % determine trial type
                getTrialType(TrialNum);
                
                % correct, incorrect, or no response
                getTrialOutcome(TrialNum);
                
                % determine if mouse licked early, if early lick enforced
                getTrialEarlyLick(TrialNum);
                
                % determine if autolearn on
                getTrialAutolearn(TrialNum);
                
                % determine if autowater on
                getTrialAutowater(TrialNum);
                
                % determine if reversal on
                getTrialReversal(TrialNum);
                
            end
            
        else
            %BpodSystem.Data.dataToPlot(TrialNum) = [];?? 
            disp('!! behavioralPerformance: trialTypes empty, performance not determined')
        end
        
        
end


function initDataToPlot()
global BpodSystem
MAXTRIALS = 9999;

BpodSystem.Data.dataToPlot.Right = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Left = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Early = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Autolearn = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Autowater = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Reversal = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Hit = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Error = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.NoResponse = NaN.*zeros(MAXTRIALS,1);


function initPerfPlot()
global BpodSystem
MAXTRIALS = 9999;

BpodSystem.Data.Perf.All = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.Perf.Recent = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.Perf.R = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.Perf.L = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.Perf.NoResponse = NaN.*zeros(MAXTRIALS,1);


function initDataToPlot_Update(TrialNum)
global BpodSystem

BpodSystem.Data.dataToPlot.Right(TrialNum) = 0;
BpodSystem.Data.dataToPlot.Left(TrialNum) = 0;
BpodSystem.Data.dataToPlot.Hit(TrialNum) = 0;
BpodSystem.Data.dataToPlot.Error(TrialNum) = 0;
BpodSystem.Data.dataToPlot.NoResponse(TrialNum) = 0;
BpodSystem.Data.dataToPlot.Early(TrialNum) = -1;
BpodSystem.Data.dataToPlot.Autolearn(TrialNum) = 1;
BpodSystem.Data.dataToPlot.Autowater(TrialNum) = 0;
BpodSystem.Data.dataToPlot.Reversal(TrialNum) = 0;


function getTrialType(TrialNum)
global BpodSystem

if BpodSystem.Data.TrialTypes(TrialNum) == 0 % right trial
    BpodSystem.Data.dataToPlot.Right(TrialNum) = 1;
elseif BpodSystem.Data.TrialTypes(TrialNum) == 1 % left trial
    BpodSystem.Data.dataToPlot.Left(TrialNum) = 1;
end


function getTrialOutcome(TrialNum)
global BpodSystem

if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.Reward(1)) % if reached reward state
    BpodSystem.Data.dataToPlot.Hit(TrialNum) = 1;
elseif ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.TimeOut(1)) % if reached timeout state
    BpodSystem.Data.dataToPlot.Error(TrialNum) = 1;
elseif ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.NoResponse(1)) % if reached no response
    BpodSystem.Data.dataToPlot.NoResponse(TrialNum) = 1;
end


function getTrialEarlyLick(TrialNum)
global BpodSystem

if isfield(BpodSystem.Data.RawEvents.Trial{TrialNum}.States,'EarlyLickDelay')
    if (isfield(BpodSystem.Data.RawEvents.Trial{TrialNum}.States,'EarlyLickSample') && ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.EarlyLickSample(1))) || ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.EarlyLickDelay(1))
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
