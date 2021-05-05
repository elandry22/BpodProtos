function MasterProtocol()
global S BpodSystem

MAXTRIALS = 9999;

S = BpodSystem.ProtocolSettings;

% Setup GUI with default parameters and set callbacks
setupGUI()
BpodParameterGUI('init', S);

setupGUIcallbacks('ProtocolType', @manualChangeProtocol, 0);
setupGUIcallbacks('Autolearn', @manualChangeAutolearn, 0);
setupGUIcallbacks('Location', @manualChangeLocation, 1);
% setupGUIcallbacks('CameraTrigger', @manualChangeCameraTrigger,1);
% setupGUIcallbacks('Bitcode', @manualChangeBitcode,1);
% setupGUIcallbacks('MaskingFlash', @manualChangeMaskingFlash,1);
% setupGUIcallbacks('SGLxTrigger', @manualChangeSGLxTrigger,1);
% setupGUIcallbacks('Stimulation', @manualChangeStimulation,1);

setToAutolearn();

BpodSystem.Data.dataToPlotStr = {'Reversal'; 'Autowater'; 'Autolearn'; 'Early'; 'Left'; 'Right'; 'Hit'; 'Error'};
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
BpodSystem.Data.TrialParams = cell(MAXTRIALS,1);

behavioralPerformance('init', [])
myYesNoPerfOutcomePlot('init', []);


% Pause the protocol before starting
BpodSystem.Status.Pause = 1;
HandlePauseCondition;

TrialTypes = NaN*ones(1, MAXTRIALS);

for TrialNum = 1:MAXTRIALS
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin

    TrialParams = setTrialParameters();

    TrialTypes(TrialNum) = trialSelection(TrialNum); %0's (right/RightToLeft) or 1's (left/LeftToRight)
    myYesNoPerfOutcomePlot('next_trial', TrialNum, TrialTypes(TrialNum));
    
    [sma, TrialParams] = getStateMatrix(TrialTypes(TrialNum),TrialNum,TrialParams);
    
    dispTrialInfo(TrialNum, TrialTypes, TrialParams);
    
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
        processTrialOutcome(RawEvents, TrialTypes, TrialParams, TrialNum)%, spontaneousPeriod, soundTaskPeriod);
        SaveBpodSessionData(); % Saves the field BpodSystem.Data to the current data file
        BpodSystem.ProtocolSettings = S;
        SaveBpodProtocolSettings();
    end
    
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
end



function dispTrialInfo(TrialNum, TrialTypes, params)
global S
disp(['Starting trial ',num2str(TrialNum)])
disp(['     Protocol Type: ', S.GUIMeta.ProtocolType.String{S.GUI.ProtocolType}])
disp(['     TrialType:     ', num2str(TrialTypes(TrialNum))])
if isempty(params.stimState)
    disp(['     StimState:     '])
else
    disp(['     StimState:     ', params.stimState{1}])
end

disp(['     ITI:           ', num2str(params.ITI), ' seconds'])
disp(['     Nlicks:        ', num2str(params.Nlicks)]);



function setToAutolearn()
global S
if ~isempty(S.ProtocolHistory)% start each day on autolearn
    S.ProtocolHistory(end+1,1) = 2; % corresponds to autolearn protocol #
    S.GUI.Autolearn = 1;
    mySet('Autolearn',S.GUI.Autolearn, 'Value');
end











function processTrialOutcome(RawEvents, TrialTypes, TrialParams, TrialNum)%, spontaneousPeriod, soundTaskPeriod)
global BpodSystem S

if ~isempty(fieldnames(RawEvents)) % If trial data was returned
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    BpodSystem.Data.TrialSettings(TrialNum) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data.TrialTypes(TrialNum) = TrialTypes(TrialNum); % Adds the trial type of the current trial to data
    BpodSystem.Data.TrialParams{TrialNum} = TrialParams;

    try
        behavioralPerformance('update', TrialNum);
    catch
        disp('!! Error calculating performance')
    end
    
    try
        myYesNoPerfOutcomePlot('update', TrialNum, TrialTypes(TrialNum));
    catch
        disp('!! Error plotting performance');
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

locationNum = S.GUI.Location;
if ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Box'))
    mySet('CameraTrigger',0,'Value');
    mySet('CameraTrigger','Off','Enable');
    
    mySet('Bitcode',0,'Value');
    mySet('Bitcode','Off','Enable');
        
    mySet('MaskingFlash',0,'Value');
    mySet('MaskingFlash','Off','Enable');
   
    mySet('SGLxTrigger',0,'Value');
    mySet('SGLxTrigger','Off','Enable');
    
    mySet('Stimulation',0,'Value');
    mySet('Stimulation','Off','Enable');
elseif ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Rig'))
    mySet('CameraTrigger',1,'Value');
    mySet('CameraTrigger','On','Enable');
    
    mySet('Bitcode',1,'Value');
    mySet('Bitcode','On','Enable');
        
    mySet('MaskingFlash',1,'Value');
    mySet('MaskingFlash','On','Enable');
   
    mySet('SGLxTrigger',1,'Value');
    mySet('SGLxTrigger','On','Enable');
    
    mySet('Stimulation',1,'Value');
    mySet('Stimulation','On','Enable');
end



% function manualChangeCameraTrigger(hObject, ~, ~)
% global S;
% CameraTrigger = get(hObject,'Value');
% S.GUI.CameraTrigger =  CameraTrigger;
% mySet('CameraTrigger',S.GUI.CameraTrigger,'Value');
% 
% function manualChangeBitcode(hObject, ~, ~)
% global S;
% Bitcode = get(hObject,'Value');
% S.GUI.Bitcode =  Bitcode;
% mySet('Bitcode',S.GUI.Bitcode,'Value');
% 
% function manualChangeMaskingFlash(hObject, ~, ~)
% global S;
% MaskingFlash = get(hObject,'Value');
% S.GUI.MaskingFlash =  MaskingFlash;
% mySet('MaskingFlash',S.GUI.MaskingFlash,'Value');
% 
% function manualChangeSGLxTrigger(hObject, ~, ~)
% global S;
% SGLxTrigger = get(hObject,'Value');
% S.GUI.SGLxTrigger =  SGLxTrigger;
% mySet('SGLxTrigger',S.GUI.SGLxTrigger,'Value');
% 
% function manualChangeStimulation(hObject, ~, ~)
% global S;
% Stimulation = get(hObject,'Value');
% S.GUI.Stimulation =  Stimulation;
% mySet('Stimulation',S.GUI.Stimulation,'Value');



function setupGUIcallbacks(fieldname, func, execute)
global S BpodSystem

p = cellfun(@(x) strcmp(x,fieldname),BpodSystem.GUIData.ParameterGUI.ParamNames);
set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'callback',{func, S});

if execute
    feval(func, BpodSystem.GUIHandles.ParameterGUI.Params(p), [], []);
end



function mySet(parameterName, parameterValue, type)
global BpodSystem;
p = find(cellfun(@(x) strcmp(x,parameterName),BpodSystem.GUIData.ParameterGUI.ParamNames));

switch type
    case 'Value'
        set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'Value',parameterValue);
    case 'String'
        set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'String',num2str(parameterValue));
    case 'Enable'
        set(BpodSystem.GUIHandles.ParameterGUI.Params(p), 'Enable', parameterValue)

end




