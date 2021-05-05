function setupGUI_laserPowerCalibration()

global S

if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.outputVoltage = 0.01;
    S.GUI.laserOnTime = 5;
    S.GUI.laserOffTime = 0;
    S.GUI.angleCorFactor = 0;
    
    S.GUIMeta.laserLocation.Style = 'popupmenu';
    S.GUIMeta.laserLocation.String = {'Origin','Bilateral','Bi_Scan','Unilateral'};
    S.GUI.laserLocation = 1;
    S.GUI.distAP = 0;
    S.GUI.distML = 0;
    
    
end



