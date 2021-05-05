function laserPowerCalibration()
global S BpodSystem

% applies 1V to analog input to laser for user specified amount of time
% repeats until user pauses protocol

MAXTRIALS = 9999;

S = BpodSystem.ProtocolSettings;

% Setup GUI with default parameters and set callbacks
setupGUI_laserPowerCalibration()
S.GUI.angleCorFactor = 0;
BpodParameterGUI('init', S);

% if any parameters are changed, Bpod creates new output waveforms
setupGUIcallbacks('outputVoltage',@manualChangeWavParam,0);
setupGUIcallbacks('laserOnTime',@manualChangeWavParam,0);
setupGUIcallbacks('laserOffTime',@manualChangeWavParam,0);
setupGUIcallbacks('angleCorFactor',@manualChangeWavParam,0);
setupGUIcallbacks('laserLocation', @manualChangeWavParam, 0);
setupGUIcallbacks('distAP',@manualChangeWavParam,0);
setupGUIcallbacks('distML',@manualChangeWavParam,0);


% Pause the protocol before starting
BpodSystem.Status.Pause = 1;
HandlePauseCondition;

disp('Starting laser power calibration protocol')

trigProfNum = sendOutputWaveforms_Calibration('COM5');
S.newWaveform = false;
TrialParams.wav = S.wavParams;

for TrialNum = 1:MAXTRIALS
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
    if S.newWaveform
        trigProfNum = sendOutputWaveforms_Calibration('COM5');
        S.newWaveform = false;
    end
    
    
    sma = getStateMatrix_laserPowerCalibration(trigProfNum);
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
    
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
end



function setupGUIcallbacks(fieldname, func, execute)
global S BpodSystem

p = cellfun(@(x) strcmp(x,fieldname),BpodSystem.GUIData.ParameterGUI.ParamNames);
set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'callback',{func, S});

if execute
    feval(func, BpodSystem.GUIHandles.ParameterGUI.Params(p), [], []);
end



function manualChangeWavParam(hObject, ~, ~)
global S;
S.newWaveform = true;