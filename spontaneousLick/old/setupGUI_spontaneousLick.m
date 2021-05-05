function setupGUI_spontaneousLick()

global S

if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    
    S.GUIMeta.Location.Style = 'popupmenu';
    S.GUIMeta.Location.String = {'BehaviorBox1'; 'BehaviorBox2'; 'BehaviorBox3'; 'EphysRig1'}; %Possible values: Box1, Box2, Box3, Rig1
    S.GUI.Location = 1;
    
    S.GUI.NrecentTrials = 40; % THIS IS THE PERIOD OVER WHICH ADVANCEMENT PARAMETERS ARE DETERMINED
    
    S.GUI.WaterValveTime = 0.025;	  % in sec SET-UP SPECIFIC
	S.GUI.AutoWaterScale = 0.75;          % in sec
    S.GUI.SamplePeriod = 1.2;		  % in sec
    S.GUI.DelayPeriod = 0.3;		  % in sec
    S.GUI.AnswerPeriod = 10;		  % in sec
    S.GUI.ConsumptionPeriod = 1.5;	  % in sec
    S.GUI.StopLickingPeriod = 1.5;	  % in sec
    S.GUI.TimeOut = 0.1;			  % in sec
    
    S.GUI.MinLicksForReward = 1;
    S.GUI.MaxLicksForReward = 1;
    
    S.GUIMeta.CueType.Style = 'popupmenu';	 % protocol type selection
    S.GUIMeta.CueType.String = {'WaterDrop','None''GoCue'};
    S.GUI.CueType = 1;
    S.GUIPanels.Protocol= {'ProtocolType'};
    
    S.GUIMeta.Antibias.Style = 'popupmenu';	 % trial type selection
    S.GUIMeta.Antibias.String = {'On' 'Off'};
    S.GUI.Antibias = 2;
    S.GUI.MaxSame = 4;
    S.GUI.LeftTrialProb = 0.5;
    S.GUI.Min_correct_Right = 2;
    S.GUI.Max_incorrect_Right = 2;
    S.GUI.Min_correct_Left = 2;
    S.GUI.Max_incorrect_Left = 2;
    S.GUIPanels.TrialParameters= {'Autolearn','MaxSame','LeftTrialProb','Min_correct_Right','Max_incorrect_Right','Min_correct_Left','Max_incorrect_Left'};
    
    S.ProtocolHistory = [S.GUI.ProtocolType];	  % [protocol#]
    S.LickPortMove = 0;		  % keeps track of the number of trials since the last lickport move, used by 'autoAdjustLickportPosition'
    S.GaveFreeReward = [0 0 0];  % [flag_R_water,flag_L_water,past_trials]	keeps track of the number of trials since the last FREE reward, used by 'autoReward'
end



