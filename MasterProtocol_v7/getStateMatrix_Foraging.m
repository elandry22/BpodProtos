function [sma, params] = getStateMatrix_Foraging(params, trialType, trialNum)
global S BpodSystem

%% OUTLINE
% 3 lickports, 1 active per block 

% automate autowater (10 trials of autowater with each new trialType)

%% STATE MATRIX

ports = getPorts(S.GUI.numLickPorts,trialTypes);

actions = getActions();
outputs = getOutputs(trialType);

sma = NewStateMatrix();
sma = setTimers(sma, params); % set up timers for trial start and stimulation
sma = addTrialStartStates(sma, params.bit, trialNum); % location dependent starting states

sma = AddState(sma, 'Name', 'InitialState', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'PreSample'},...
    'OutputActions', []);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % PRE SAMPLE AND PRE SAMPLE STOP LICKING STATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sma = AddState(sma, 'Name', 'PreSample', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup','StopLickingPreSample'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'StopLickingPreSample', 'Timer', 0.99,...
    'StateChangeConditions', {'Port1In', 'StopLickingReturnPreSample',...
                              'Port2In', 'StopLickingReturnPreSample',...
                              'Port4In', 'StopLickingReturnPreSample',...
                              'Tup','Sample'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'StopLickingReturnPreSample', 'Timer', 0.1,...
    'StateChangeConditions', {'Tup','StopLickingPreSample'},...
    'OutputActions', []); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % SAMPLE AND SAMPLE STOP LICKING STATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sma = AddState(sma, 'Name', 'Sample', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup','StopLickingSample'},...
    'OutputActions', outputs.SampleOutput);

sma = AddState(sma, 'Name', 'StopLickingSample', 'Timer', 3,...
    'StateChangeConditions', {'Port1In', 'StopLickingReturnSample', ...
                              'Port2In', 'StopLickingReturnSample', ...
                              'Port4In', 'StopLickingReturnSample', ...
                              'Tup','GoCue'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'StopLickingReturnSample', 'Timer', 0.1,...
    'StateChangeConditions', {'Tup','StopLickingSample'},...
    'OutputActions', []); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % GO CUE STATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sma = AddState(sma, 'Name', 'GoCue', 'Timer', 0.01,... 
    'StateChangeConditions', {'Tup', actions.ActionAfterCue},...
    'OutputActions', outputs.CueOutput);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % AUTOWATER STATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sma = AddState(sma, 'Name', 'GiveAutoWater', 'Timer', outputs.ActiveResponseTime*S.GUI.AutoWaterScale,...
    'StateChangeConditions', {'Tup', 'AnswerPeriod'},...
    'OutputActions', outputs.ActiveResponse); % free reward left

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % ANSWERPERIOD STATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sma = AddState(sma, 'Name', 'AnswerPeriod', 'Timer', S.GUI.AnswerPeriod,...
    'StateChangeConditions', {ports.activePort,'LickedActive', ...
                              ports.inactivePort(1),'LickedInactive', ...
                              ports.inactivePort(2),'LickedInactive', ...
                              'Tup','NoResponse'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'LickedActive', 'Timer', outputs.ActiveResponseTime,...
    'StateChangeConditions', {'Tup', 'Reward'}, ...
    'OutputActions', outputs.ActiveResponse);

sma = AddState(sma, 'Name', 'LickedInactive', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'StopLicking'}, ...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'Reward', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'StopLicking'},...
    'OutputActions', []);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % STOP LICKING AFTER ANSWER PERIOD STATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stop licking after answer period, keeps Bpod from reacting to inactive port2
sma = AddState(sma, 'Name', 'StopLicking', 'Timer', S.GUI.StopLickingPeriod,...
    'StateChangeConditions', {'Port1In', 'StopLickingReturn', ...
                              'Port2In', 'StopLickingReturn', ...
                              'Port4In', 'StopLickingReturn', ...
                              'Tup','ITI'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'StopLickingReturn', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup','StopLicking'},...
    'OutputActions', []); 

sma = AddState(sma, 'Name', 'NoResponse', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'ITI', 'Timer', params.ITI,...
    'StateChangeConditions', {'Tup', 'TrialEnd'},...
    'OutputActions', []);

% states that can't be reached, for posterity for reading Bpod data
% (expPipeline.m)

sma = AddState(sma, 'Name', 'EarlyLickSample', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'TrialEnd'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'EarlyLickDelay', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'TrialEnd'},...
    'OutputActions', []);

sma = addTrialEndStates(sma);


end % getStateMatrix_Foraging

%% HELPER FUNCTIONS

function actions = getActions()
    global S
    
    actions.ActionAfterCue = 'AnswerPeriod';
    if S.GUI.Autowater == 1 % give small drop of free water on L
        actions.ActionAfterCue = 'GiveAutoWater';
    end

end % getActions

function outputs = getOutputs(trialType)
    global S
    
    % for 1 lick port, outputs.RightResponse cleared at end of function
    outputs.CenterWaterOutput = {'ValveState',2^0}; 
    outputs.RightWaterOutput = {'ValveState',2^1}; 
    outputs.LeftWaterOutput = {'ValveState',2^3}; % this is new lickport
    
    outputs.CueOutput = {'PWM4', 255};
    outputs.SampleOutput = {'PWM2', 255};
    
    switch trialType
        case 1
            outputs.ActiveResponse = outputs.CenterWaterOutput;
            outputs.ActiveResponseTime = S.GUI.WaterValveTime*S.GUI.CenterPortScale;
            outputs.AutoWaterTime = S.GUI.AutoWaterScale*S.GUI.CenterPortScale;
        case 2
            outputs.ActiveResponse = outputs.RightWaterOutput;
            outputs.ActiveResponseTime = S.GUI.WaterValveTime*S.GUI.RightPortScale;
        case 3
            outputs.ActiveResponse = outputs.LeftWaterOutput;
            outputs.ActiveResponseTime = S.GUI.WaterValveTime*S.GUI.LeftPortScale;
    end
        
    % add BNCState 2 at go cue for any cue for analysis
    if ~isempty(outputs.CueOutput)
        outputs.CueOutput = [outputs.CueOutput, 'BNCState',2];
    else
        outputs.CueOutput = {'BNCState', 2};
    end

end % getOutputs 

function ports = getPorts(numPorts, trialType)
    ports.activePort = ['Port' num2str(trialType) 'In'];
    availPorts = 1:numPorts;
    inactivePorts = find(availPorts~=trialType);
    for i = 1:numel(inactivePorts)
        ports.inactivePorts(i) = ['Port' inactivePorts(i) 'In'];
    end
end % getPorts










