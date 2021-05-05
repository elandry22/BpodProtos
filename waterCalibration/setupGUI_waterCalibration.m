function setupGUI_waterCalibration()

global S

if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    
    S.GUIMeta.LickPort.Style = 'popupmenu';
    S.GUIMeta.LickPort.String = {'Left', 'Right'};
    S.GUI.LickPort = 1;

    S.GUI.WaterValveTime = 0.025;	  % in sec SET-UP SPECIFIC
    S.GUI.LeftPortScale = 1;
    S.GUI.RightPortScale = 1;
    
end



