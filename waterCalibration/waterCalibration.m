function waterCalibration()
global S BpodSystem

MAXTRIALS = 9999;
NDROPS = 100;
DELAY = 0.05; % in sec

S = BpodSystem.ProtocolSettings;

% Setup GUI with default parameters and set callbacks
setupGUI_waterCalibration()
BpodParameterGUI('init', S);

setupGUIcallbacks('LickPort', @manualChangeLickPort);

% Pause the protocol before starting
BpodSystem.Status.Pause = 1;
HandlePauseCondition;

for TrialNum = 1:MAXTRIALS
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
    disp([S.GUIMeta.LickPort.String(S.GUI.LickPort) ' lick port test'])
    disp(['        Water valve time: ' num2str(S.GUI.WaterValveTime)])
    disp(['        Left port scale: ' num2str(S.GUI.LeftPortScale)])
    disp(['        Right port scale: ' num2str(S.GUI.RightPortScale)])
   
    sma = getStateMatrix(NDROPS,DELAY);
    SendStateMatrix(sma);
    
    try
        RawEvents = RunStateMatrix;		 % this step takes a long time and variable (seem to wait for GUI to update, which takes a long time)

        bad = 0;
    catch 
        disp('RunStateMatrix error!!!'); % TW: The Bpod USB communication error fails here.
        bad = 1;
    end
    
    if ~bad
        SaveBpodSessionData(); % Saves the field BpodSystem.Data to the current data file
        BpodSystem.ProtocolSettings = S;
        SaveBpodProtocolSettings();
    end
    
    BpodSystem.Status.Pause = 1;  % pause after every calibration
    
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
end




function manualChangeLickPort(hObject, ~, ~)
global S;
LickPort = get(hObject,'Value');
S.GUI.ProtocolType = LickPort;
mySet('ProtocolType',S.GUI.LickPort,'Value');


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