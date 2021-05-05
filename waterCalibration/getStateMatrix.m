function sma = getStateMatrix(NDROPS, DELAY)    

outputs = getOutputs();

sma = getWaterCalibrationStateMatrix(outputs, NDROPS, DELAY);


function outputs = getOutputs()
global S

outputs.WaterOutput = {};

switch S.GUIMeta.LickPort.String{S.GUI.LickPort}
    case 'Left'
        outputs.WaterOutput = {'ValveState',2^0};
    case 'Right'
        outputs.WaterOutput = {'ValveState',2^1};
end


