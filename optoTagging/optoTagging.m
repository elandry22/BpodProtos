function optoTagging()
global S BpodSystem

% applies 1V to analog input to laser for user specified amount of time
% repeats until user pauses protocol

S = BpodSystem.ProtocolSettings;

% Setup GUI with default parameters and set callbacks
setupGUI_optoTagging()
BpodParameterGUI('init', S);

% if any parameters are changed, Bpod creates new output waveforms
setupGUIcallbacks('PulseAmp',@manualChangeWavParam,0);
setupGUIcallbacks('PulseFreq',@manualChangeWavParam,0);
setupGUIcallbacks('PulseWidth',@manualChangeWavParam,0);
setupGUIcallbacks('ProtoDur',@manualChangeWavParam,0);
setupGUIcallbacks('ProtoDur',@updateTotalTimeDisplay,0);
setupGUIcallbacks('NumRepeats',@updateTotalTimeDisplay,0);

% Pause the protocol before starting
BpodSystem.Status.Pause = 1;
HandlePauseCondition;

disp('Starting opto tagging protocol')
GTS = tic;
disp('    Global tic started')

sendOutputWaveforms_optoTagging('COM5');
S.newWaveform = false;
% TrialParams.wav = S.wavParams;

for TrialNum = 1:S.GUI.NumRepeats
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
    if S.newWaveform
        sendOutputWaveforms_optoTagging('COM5');
        S.newWaveform = false;
    end
    
    
    [sma, BitParams] = getStateMatrix_optoTagging(TrialNum);
    
    TTS = dispTrialInfo(TrialNum, GTS);
    
    SendStateMatrix(sma);
    
    try
        if S.GUI.CameraTrigger
            SendCameraMsg([5010, 5020], {'?start-capture'});
            pause(0.5);
        end
        
        RawEvents = RunStateMatrix;		 % this step takes a long time and variable (seem to wait for GUI to update, which takes a long time)
        
        if S.GUI.CameraTrigger
            SendCameraMsg([5010, 5020], {'?stop-capture'});
        end
        
        bad = 0;
    catch 
        disp('RunStateMatrix error!!!'); % TW: The Bpod USB communication error fails here.
        bad = 1;
    end
    
    if ~bad
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        BpodSystem.Data.BitParams{TrialNum} = BitParams;
        BpodSystem.Data.GUI(TrialNum) = S.GUI;
        SaveBpodSessionData(); % Saves the field BpodSystem.Data to the current data file
        BpodSystem.ProtocolSettings = S;
        SaveBpodProtocolSettings();
        dispTrialLength(TTS)
    end
    
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
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

function updateTotalTimeDisplay(hObject, ~, ~)
global S BpodSystem;

p = find(cellfun(@(x) strcmp(x,'TotalTime'),BpodSystem.GUIData.ParameterGUI.ParamNames));
S = BpodParameterGUI('sync', S);
ttNum = S.GUI.ProtoDur*S.GUI.NumRepeats;
set(BpodSystem.GUIHandles.ParameterGUI.Params(p), 'String', [num2str(ttNum), ' s'])




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



function TTS = dispTrialInfo(TrialNum, GTS)
global S

disp(['Starting repeat ', num2str(TrialNum), '/', num2str(S.GUI.NumRepeats)])
disp(['    Trial tic start: ', num2str(toc(GTS))])
TTS = tic;


function dispTrialLength(TTS)

disp(['    Trial length: ', num2str(toc(TTS))])
