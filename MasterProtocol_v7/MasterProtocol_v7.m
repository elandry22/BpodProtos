function MasterProtocol_v7()
global S BpodSystem 

MAXTRIALS = 9999;

S = BpodSystem.ProtocolSettings;

% Setup GUI with default parameters and set callbacks
setupGUI()
BpodParameterGUI('init', S);
S.Timers = zeros(1,4);
BpodSystem.Data.nTrials = 0;

initGUIcallbacks(); 
setToAutolearn();

% Information about GUI gets saved at start up
BpodSystem.Data.SessionMeta.GUIMeta = S.GUIMeta;
BpodSystem.Data.SessionMeta.GUIPanels = S.GUIPanels;
% save version of protocol used

BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
BpodSystem.Data.TrialParams = cell(MAXTRIALS,1);

behavioralPerformance('init', [])
myYesNoPerfOutcomePlot('init', []);


% Pause the protocol before starting
BpodSystem.Status.Pause = 1;
HandlePauseCondition;

BpodSystem.Data.SessionMeta.wavParams = sendOutputWaveforms('COM5'); % send camera and stim waveforms to waveplayer
S.newWaveform = false;

TrialTypes = NaN*ones(1, MAXTRIALS);

for TrialNum = 1:MAXTRIALS
    
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin

    if S.newWaveform
        BpodSystem.Data.SessionMeta.wavParams = sendOutputWaveforms('COM5'); % send camera and stim waveforms to waveplayer
        S.newWaveform = false;
    end
    
    TrialParams = setTrialParameters();
    TrialTypes(TrialNum) = trialSelection(TrialNum); %0's (right/RightToLeft) or 1's (left/LeftToRight)
    
    myYesNoPerfOutcomePlot('next_trial', TrialNum, TrialTypes(TrialNum));
    
    [sma, TrialParams] = getStateMatrix(TrialTypes(TrialNum),TrialNum,TrialParams);
    
    dispTrialInfo(TrialNum, TrialParams);
    
    SendStateMatrix(sma);
    
    % for lick sequence task w/o Teensy (digital input from Bpod to controller)
%     if S.GUI.ProtocolType==5 % initialize motors if lick sequence task
%         disp('here')
%         initMotors(TrialTypes(TrialNum)); 
%     end
    
    try
        SendCameraMsg([5010, 5020], {'?start-capture'});
        pause(0.5); % pause to ensure camera starts before trial begins
        RawEvents = RunStateMatrix;
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



function dispTrialInfo(TrialNum, params)

disp(['Starting trial ',num2str(TrialNum)])

if params.giveStim
    disp(['     StimState:     ', params.stimState])
    disp(['     StimLoc:       ', params.wav.stim.loc{params.stimNum}])
    disp(['     Duration:      ', num2str(params.wav.stim.dur{params.stimNum}), ' seconds'])
    disp(['     Delay:         ', num2str(params.stimDel), ' seconds'])
end

disp(['     ITI:           ', num2str(params.ITI), ' seconds'])
disp(['     Nlicks:        ', num2str(params.Nlicks)]);



function setToAutolearn()
global S
% start each day on autolearn
S.GUI.Autolearn = 1;
mySet('Autolearn',S.GUI.Autolearn, 'Value');












function processTrialOutcome(RawEvents, TrialTypes, TrialParams, TrialNum)%, spontaneousPeriod, soundTaskPeriod)
global BpodSystem S

if ~isempty(fieldnames(RawEvents)) % If trial data was returned
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    BpodSystem.Data.GUISettings(TrialNum) = S.GUI;
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
            if S.GUI.CameraTrigger == 1 %~isempty(strfind(S.GUIMeta.Location.String{S.GUI.Location}, 'EphysRig1'))
                % Can only == 1 if on Ephys rig and camera trigger selected
                url_base = ['http://localhost:' num2str(port(i)) '/'];
                urlread([url_base msg{j}]);
            end
        catch
           disp(['!!  Error sending command: ' msg{j} ' to camera on port ' num2str(port(i))]);  
        end
    end
end



% % % Callback functions

function initGUIcallbacks() 
% forces pause before next trial
setupGUIcallbacks('ProtocolType', @manualChangeProtocol, 0); 
% toggles whether EphysRig specific GUI options are enabled
setupGUIcallbacks('Location', @manualChangeLocation, 1); 

% any adjustments for the waveplayer
setupGUIcallbacks('CameraTrigger', @manualChangeWaveforms,1);
setupGUIcallbacks('Stimulation', @manualChangeWaveforms,1);
setupGUIcallbacks('StimHemisphere', @manualChangeWaveforms,1);


function setupGUIcallbacks(fieldname, func, execute)
global S BpodSystem

p = cellfun(@(x) strcmp(x,fieldname),BpodSystem.GUIData.ParameterGUI.ParamNames);
set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'callback',{func, S});

if execute
    feval(func, BpodSystem.GUIHandles.ParameterGUI.Params(p), [], []);
end


function manualChangeProtocol(hObject, ~, ~)
global BpodSystem S;
protocolType = get(hObject,'Value');
S.GUI.ProtocolType = protocolType;
mySet('ProtocolType',S.GUI.ProtocolType,'Value');
% S.ProtocolHistory(end+1,:) = [S.GUI.ProtocolType];
BpodSystem.Data.ProtocolHistory(BpodSystem.Data.nTrials+1) = S.GUI.ProtocolType;
BpodSystem.Status.Pause = 1; 


function manualChangeLocation(hObject, ~, ~)
% toggles whether EphysRig specific GUI options are enabled

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
    
    mySet('StimHemisphere','Off','Enable');
    mySet('StimProbability','Off','Enable');
elseif ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Rig'))
    mySet('CameraTrigger',0,'Value');
    mySet('CameraTrigger','On','Enable');
    
    mySet('Bitcode',0,'Value');
    mySet('Bitcode','On','Enable');
        
    mySet('MaskingFlash',0,'Value');
    mySet('MaskingFlash','On','Enable');
   
    mySet('SGLxTrigger',0,'Value');
    mySet('SGLxTrigger','On','Enable');
    
    mySet('Stimulation',0,'Value');
    mySet('Stimulation','On','Enable');
    
    mySet('StimHemisphere','On','Enable');
    mySet('StimProbability','On','Enable');
    
    S.newWaveform = true;
end


function manualChangeWaveforms(hObject, ~, ~)
global S;
S.newWaveform = true;






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
