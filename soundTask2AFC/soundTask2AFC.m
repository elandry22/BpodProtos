function soundTask2AFC()
global S BpodSystem

MAXTRIALS = 9999;

S = BpodSystem.ProtocolSettings;

% Setup GUI with default parameters and set callbacks
setupGUI_soundTask()
BpodParameterGUI('init', S);
setupGUIcallbacks('ProtocolType', @manualChangeProtocol);
setupGUIcallbacks('Autolearn', @manualChangeAutolearn);
setupGUIcallbacks('Location', @manualChangeLocation);

setToAutolearn();

TrialTypes = [];
behavioralPerformance('init', [])
myYesNoPerfOutcomePlot('init', []);
initOutputWaveforms();

% Pause the protocol before starting
BpodSystem.Status.Pause = 1;
HandlePauseCondition;

spontaneousPeriod = 0;
soundTaskPeriod = 0;
if S.GUI.ProtocolType==4
    spontaneousPeriod = 1;
    Scounted = 0;
elseif S.GUI.ProtocolType < 4
    soundTaskPeriod = 1;
    STcounted = 0;
end

for TrialNum = 1:MAXTRIALS
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
    if TrialNum > 1 && S.GUI.ProtocolType == 4 && BpodSystem.Data.ProtocolHistory(TrialNum-1)~=4
        spontaneousPeriod = spontaneousPeriod + 1;
        behavioralPerformance('initNewPeriod', TrialNum, spontaneousPeriod, soundTaskPeriod);
        Scounted = 1; STcounted = 1;
    end
    
    if TrialNum > 1 && S.GUI.ProtocolType ~= 4 && BpodSystem.Data.ProtocolHistory(TrialNum-1) == 4
        soundTaskPeriod = soundTaskPeriod + 1;
        behavioralPerformance('initNewPeriod', TrialNum, spontaneousPeriod, soundTaskPeriod);
        Scounted = 1; STcounted = 1;
    end
    
    if spontaneousPeriod == 1 && Scounted == 0
        behavioralPerformance('initNewPeriod', TrialNum, spontaneousPeriod, soundTaskPeriod);
        Scounted = 1;
    elseif soundTaskPeriod == 1 && STcounted == 0
        behavioralPerformance('initNewPeriod', TrialNum, spontaneousPeriod, soundTaskPeriod);
        STcounted = 1;
    end
    
    ITI = exprnd(S.GUI.ITI);
    Nlicks = getNlicks(TrialNum);
    
    TrialTypes(TrialNum) = trialSelection(TrialNum); %0's (right) or 1's (left)
    
    [sma, TrialParams] = getStateMatrix(TrialTypes(TrialNum),TrialNum,ITI,Nlicks);
    
    myYesNoPerfOutcomePlot('next_trial', TrialNum)

    
    if S.GUI.ProtocolType < 4
        disp(['Starting trial ',num2str(TrialNum),' TrialType: ' num2str(TrialTypes(TrialNum))])
        disp(['     Must lick ' num2str(Nlicks) ' times for reward this trial']);
    elseif S.GUI.ProtocolType == 4
        disp(['Starting trial ',num2str(TrialNum),' Spontaneous trial. Cue type: ', S.GUIMeta.CueType.String{S.GUI.CueType}])
        disp(['     ITI: ', num2str(ITI), ' seconds']);
    end
    
    SendStateMatrix(sma);
    
    try
        SendCameraMsg([5010, 5020], {'?start-capture'});
        pause(0.2);
        RawEvents = RunStateMatrix;		 % this step takes a long time and variable (seem to wait for GUI to update, which takes a long time)
        SendCameraMsg([5010, 5020], {'?stop-capture'});

        bad = 0;
    catch 
        disp('RunStateMatrix error!!!'); % TW: The Bpod USB communication error fails here.
        bad = 1;
    end
    
    if ~bad
        processTrialOutcome(RawEvents, TrialTypes, TrialParams, TrialNum, spontaneousPeriod, soundTaskPeriod);
        SaveBpodSessionData(); % Saves the field BpodSystem.Data to the current data file
        BpodSystem.ProtocolSettings = S;
        SaveBpodProtocolSettings();
    end
    
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
end





function setToAutolearn()
global S
if ~isempty(S.ProtocolHistory)% start each day on autolearn
    S.ProtocolHistory(end+1,1) = 2; % corresponds to autolearn protocol #
    S.GUI.Autolearn = 1;
    mySet('Autolearn',S.GUI.Autolearn, 'Value');
end





function initOutputWaveforms()
global S
%Setup camera trigger waveform

if ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'EphysRig1'))
    params.freq = 400;
    params.BNCchan = 1;
    params.waveNum = 1;
    params.pulsewid = 0.5; %ms
    params.duration = 60; %sec
    loadFrameTrigger('COM5', params)
end






function processTrialOutcome(RawEvents, TrialTypes, TrialParams, TrialNum, spontaneousPeriod, soundTaskPeriod)
global BpodSystem S

if ~isempty(fieldnames(RawEvents)) % If trial data was returned
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    BpodSystem.Data.TrialSettings(TrialNum) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data.TrialTypes(TrialNum) = TrialTypes(TrialNum); % Adds the trial type of the current trial to data
    BpodSystem.Data.TrialParams(TrialNum) = TrialParams;

    try
        behavioralPerformance('update', TrialNum, spontaneousPeriod, soundTaskPeriod);
    catch
        disp('!! Error calculating performance')
    end
    
    try
        myYesNoPerfOutcomePlot('update', TrialNum, spontaneousPeriod, soundTaskPeriod);
    catch
        disp('!! Error plotting performance');
    end
    
end


function Nlicks = getNLicks(TrialNum)
global S BpodSystem

if S.GUI.MinLicksForReward>=S.GUI.MaxLicksForReward
    Nlicks = S.GUI.MinLicksForReward;
else
    Nlicks = randsample(S.GUI.MinLicksForReward:S.GUI.MaxLicksForReward, 1);
end

if isnan(Nlicks)
    Nlicks = 1;
    disp('!! input finite number of licks')
end

BpodSystem.Data.Nlicks(TrialNum) = Nlicks;




function SendCameraMsg(port, msg)
global S

for i = 1:numel(port)
    for j = 1:numel(msg)
        try
            if ~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'EphysRig1'))
                url_base = ['http://localhost:' num2str(port(i)) '/'];
                urlread([url_base msg{j}]);
            end
        catch
           disp(['!!  Error sending command: ' msg{j} ' to camera on port ' num2str(port(i))]);  
        end
    end
end






function manualChangeProtocol(hObject, ~, ~)
global BpodSystem S;
protocolType = get(hObject,'Value');
S.GUI.ProtocolType = protocolType;
mySet('ProtocolType',S.GUI.ProtocolType,'Value');
S.ProtocolHistory(end+1,:) = [S.GUI.ProtocolType];
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp('~~~~~~~~~~~~~~~Check lick port position!~~~~~~~~~~~~~~~~~~~~~~~~~'); 
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
BpodSystem.Status.Pause = 1; 
HandlePauseCondition;




function manualChangeAutolearn(hObject, ~, ~)
global S;
Autolearn = get(hObject,'Value');
S.GUI.Autolearn =  Autolearn;
mySet('Autolearn',S.GUI.Autolearn,'Value');
S.ProtocolHistory(end+1,1) = [S.GUI.ProtocolType];



function manualChangeLocation(hObject, ~, ~)
global S;
Location = get(hObject,'Value');
S.GUI.Location =  Location;
mySet('Location',S.GUI.Location,'Value');




function setupGUIcallbacks(fieldname, func)
global S BpodSystem

p = cellfun(@(x) strcmp(x,fieldname),BpodSystem.GUIData.ParameterGUI.ParamNames);
set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'callback',{func, S});




function mySet(parameterName, parameterValue, type)
global BpodSystem;
p = find(cellfun(@(x) strcmp(x,parameterName),BpodSystem.GUIData.ParameterGUI.ParamNames));

switch type
    case 'Value'
        set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'Value',parameterValue);
    case 'String'
        set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'String',num2str(parameterValue));
end




