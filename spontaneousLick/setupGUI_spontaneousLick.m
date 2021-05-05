function setupGUI_spontaneousLick()

global S

if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    
    S.GUIMeta.Location.Style = 'popupmenu';
    S.GUIMeta.Location.String = {'BehaviorBox1'; 'BehaviorBox2'; 'BehaviorBox3'; 'EphysRig1'}; %Possible values: Box1, Box2, Box3, Rig1
    S.GUI.Location = 1;
    
    S.GUI.NrecentTrials = 40; % THIS IS THE PERIOD OVER WHICH ADVANCEMENT PARAMETERS ARE DETERMINED
    
    S.GUI.WaterValveTime = 0.025;	  % in sec SET-UP SPECIFIC
	S.GUI.AutoWaterScale = 0.75;          % in sec
    S.GUI.AnswerPeriod = 15;		  % in sec
    S.GUI.StopLickingPeriod = 0.5;	  % in sec
    
    S.GUIMeta.ProtocolType.Style = 'popupmenu';	 % protocol type selection
    S.GUIMeta.ProtocolType.String = {'WaterDrop','None','GoCue'};
    S.GUI.ProtocolType = 1;
    S.GUIPanels.Protocols = {'ProtocolType'};
    
    S.GUI.MaxSame = 4;
    S.GUI.LeftTrialProb = 0.5;
    S.GUIPanels.TrialParameters= {'MaxSame','LeftTrialProb'};
    
    S.ProtocolHistory = [S.GUI.ProtocolType];	  % [protocol#]
    S.LickPortMove = 0;		  % keeps track of the number of trials since the last lickport move, used by 'autoAdjustLickportPosition'
    S.GaveFreeReward = [0 0 0];  % [flag_R_water,flag_L_water,past_trials]	keeps track of the number of trials since the last FREE reward, used by 'autoReward'
end



