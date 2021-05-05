function sma = getWaterCalibrationStateMatrix(outputs, NDROPS, DELAY)
global S


scaling = 0;

switch S.GUIMeta.LickPort.String{S.GUI.LickPort}
    case 'Left'
        scaling = S.GUI.LeftPortScale;
    case 'Right'
        scaling = S.GUI.RightPortScale;
end



sma = NewStateMatrix(); % Assemble state matrix

sma = AddState(sma, 'Name', 'TrigTrialStart', 'Timer', 2,...
    'StateChangeConditions', {'Tup', 'Drop1_Openvalve'},...
    'OutputActions', {});

for i_drop = 1:NDROPS-1
    sma = AddState(sma, 'Name', ['Drop',num2str(i_drop),'_Openvalve'], 'Timer', S.GUI.WaterValveTime*scaling,...
        'StateChangeConditions', {'Tup', ['Drop',num2str(i_drop),'_Closevalve']},...
        'OutputActions', outputs.WaterOutput);
    sma = AddState(sma, 'Name', ['Drop',num2str(i_drop),'_Closevalve'], 'Timer', DELAY,...
        'StateChangeConditions', {'Tup', ['Drop',num2str(i_drop+1),'_Openvalve']},...
        'OutputActions', {});
end

sma = AddState(sma, 'Name', ['Drop',num2str(NDROPS),'_Openvalve'], 'Timer', S.GUI.WaterValveTime*scaling,...
    'StateChangeConditions', {'Tup', 'TrialEnd'},...
    'OutputActions', outputs.WaterOutput);

sma = AddState(sma, 'Name', 'TrialEnd', 'Timer', 0.05,...
    'StateChangeConditions', {'Tup', 'exit'},...
    'OutputActions', {});