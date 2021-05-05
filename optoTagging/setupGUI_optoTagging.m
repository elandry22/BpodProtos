function setupGUI_optoTagging()

global S

if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.PulseAmp = 5; % V
    
    S.GUI.PulseFreq = 4; % Hz
    S.GUIMeta.PulseFreqUnit.Style = 'text';
    S.GUI.PulseFreqUnit = 'Hz';
    S.GUI.PulseWidth = 0.1; % ms
    S.GUIMeta.PulseWidthUnit.Style = 'text';
    S.GUI.PulseWidthUnit = 'ms';
    S.GUI.ProtoDur = 30; % s
    S.GUIMeta.ProtoDurUnit.Style = 'text';
    S.GUI.ProtoDurUnit = 's';
    S.GUI.NumRepeats = 10;
    S.GUIMeta.TotalTime.Style = 'text';
    S.GUI.TotalTime = [num2str(S.GUI.ProtoDur*S.GUI.NumRepeats), ' s'];
    
    S.GUIMeta.CameraTrigger.Style = 'checkbox';
    S.GUI.CameraTrigger = 1;
    
%     S.GUIMeta.laserLocation.Style = 'popupmenu';
%     S.GUIMeta.laserLocation.String = {'Origin','Bilateral','Bi_Scan','Unilateral'};
%     S.GUI.laserLocation = 1;
%     S.GUI.distAP = 0;
%     S.GUI.distML = 0;
    
    
end



