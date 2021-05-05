function spontaneousLick()
global S BpodSystem

MAXTRIALS = 9999;

S = BpodSystem.ProtocolSettings;

% Setup GUI with default parameters and set callbacks
setupGUI_spontaneousLick()
BpodParameterGUI('init', S);
setupGUIcallbacks('ProtocolType', @manualChangeProtocol);
setupGUIcallbacks('Autolearn', @manualChangeAutolearn);

%setToAutolearn();

TrialTypes = [];
behavioralPerformance('init', [])
myYesNoPerfOutcomePlot('init', []);
initOutputWaveforms();

% Pause the protocol before starting
BpodSystem.Status.Pause = 1;
HandlePauseCondition;

for TrialNum = 1:MAXTRIALS
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
    % select trials here
    TrialTypes(TrialNum) = trialSelectionSpontaneousLick(); %0's (right) or 1's (left)
    myYesNoPerfOutcomePlot('next_trial', TrialNum)
    disp(['Starting trial ',num2str(TrialNum),' TrialType: ' num2str(TrialTypes(TrialNum))])
   
    [sma, TrialParams] = getStateMatrix(TrialTypes(TrialNum),TrialNum);
    SendStateMatrix(sma);
    
    try
        SendCameraMsg([5010, 5020], {'?start-capture'});
        RawEvents = RunStateMatrix;		 % this step takes a long time and variable (seem to wait for GUI to update, which takes a long time)
        SendCameraMsg([5010, 5020], {'?stop-capture'});

        bad = 0;
    catch 
        disp('RunStateMatrix error!!!'); % TW: The Bpod USB communication error fails here.
        bad = 1;
    end
    
    if ~bad
        processTrialOutcome(RawEvents, TrialTypes, TrialParams, TrialNum);
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
    params.duration = 10; %sec
    loadFrameTrigger('COM5', params)
end






function processTrialOutcome(RawEvents, TrialTypes, TrialParams, TrialNum)
global BpodSystem S

if ~isempty(fieldnames(RawEvents)) % If trial data was returned
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    BpodSystem.Data.TrialSettings(TrialNum) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data.TrialTypes(TrialNum) = TrialTypes(TrialNum); % Adds the trial type of the current trial to data
    BpodSystem.Data.TrialParams(TrialNum) = TrialParams;
    
    if S.GUI.ProtocolType >= 2
        try
            behavioralPerformance('update', TrialNum);
        catch
            disp('!! Error calculating performance')
        end
        
        try
            myYesNoPerfOutcomePlot('update', TrialNum);
        catch 
            disp('!! Error plotting performance'); 
        end
    end
end


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
global S;
protocolType = get(hObject,'Value');
S.GUI.ProtocolType = protocolType;
mySet('ProtocolType',S.GUI.ProtocolType,'Value');
S.ProtocolHistory(end+1,:) = [S.GUI.ProtocolType];




function manualChangeAutolearn(hObject, ~, ~)
global S;
Autolearn = get(hObject,'Value');
S.GUI.Autolearn =  Autolearn;
mySet('Autolearn',S.GUI.Autolearn,'Value');
S.ProtocolHistory(end+1,1) = [S.GUI.ProtocolType];





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




