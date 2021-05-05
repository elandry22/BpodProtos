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
            
            if isfield(BpodSystem.Data.TrialSettings(TrialNum),'GUI') && ~isempty(BpodSystem.Data.TrialSettings(TrialNum).GUI) %isfield(Data.RawEvents.Trial{TrialNum}.States,'Reward')
                % correct, incorrect, or no response
                getTrialOutcome(TrialNum);
                
            end
            
        else

            disp('!! behavioralPerformance: trialTypes empty, performance not determined')
        end
        
        
end


function initDataToPlot()
global BpodSystem
MAXTRIALS = 9999;

BpodSystem.Data.dataToPlot.Right = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.Left = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.LickedRight = NaN.*zeros(MAXTRIALS,1);
BpodSystem.Data.dataToPlot.LickedLeft = NaN.*zeros(MAXTRIALS,1);
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

BpodSystem.Data.dataToPlot.WaterDrop(TrialNum) = 0;
BpodSystem.Data.dataToPlot.None(TrialNum) = 0;
BpodSystem.Data.dataToPlot.GoCue(TrialNum) = 0;
BpodSystem.Data.dataToPlot.Licked(TrialNum) = 0;
BpodSystem.Data.dataToPlot.NoResponse(TrialNum) = 0;


function getTrialType(TrialNum)
global BpodSystem

if BpodSystem.Data.TrialTypes(TrialNum) == 0 % right trial
    BpodSystem.Data.dataToPlot.Right(TrialNum) = 1;
elseif BpodSystem.Data.TrialTypes(TrialNum) == 1 % left trial
    BpodSystem.Data.dataToPlot.Left(TrialNum) = 1;
end


function getTrialOutcome(TrialNum)
global BpodSystem

if ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.Licked(1)) % if reached reward state
    BpodSystem.Data.dataToPlot.Licked(TrialNum) = 1;
elseif ~isnan(BpodSystem.Data.RawEvents.Trial{TrialNum}.States.NoResponse(1)) % if reached no response
    BpodSystem.Data.dataToPlot.NoResponse(TrialNum) = 1;
end

