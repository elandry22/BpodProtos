function setupGUI()

global S

if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    % Location
    S.GUIMeta.Location.Style = 'popupmenu';
    S.GUIMeta.Location.String = {'BehaviorBox1'; 'BehaviorBox2'; 'BehaviorBox3'; 'EphysRig1'}; %Possible values: Box1, Box2, Box3, Rig1
    S.GUI.Location = 1;
    
    % Protocol
    S.GUIMeta.ProtocolType.Style = 'popupmenu';	 % protocol type selection
    S.GUIMeta.ProtocolType.String = {'NoAutoAssist_step1', 'SampleEnforce_step2', ...
        'SampleDelayEnforce_step3','SpontaneousLick','LickSequence', ...
        'BlockPosition','Foraging'};
    S.GUI.ProtocolType = 3;
    S.GUIPanels.Protocol= {'ProtocolType'};
    
    % Trial Parameters
    S.GUI.NrecentTrials = 40; 
    S.GUI.WaterValveTime = 0.025;	  % in sec SET-UP SPECIFIC
	S.GUI.AutoWaterScale = 0.75;      % in sec
    S.GUI.LeftPortScale = 1;
    S.GUI.RightPortScale = 1;
    S.GUI.SamplePeriod = 1.3;		  % in sec
    S.GUI.DelayPeriod = 0.3;		  % in sec
    S.GUI.AnswerPeriod = 3;		      % in sec
    S.GUI.ConsumptionPeriod = 1.5;	  % in sec
    S.GUI.StopLickingPeriod = 1.5;	  % in sec
    S.GUI.TimeOut = 0.1;			  % in sec
    S.GUI.LeftTrialProb = 0.5;
    S.GUIMeta.ITI_Type.Style = 'popupmenu';
    S.GUIMeta.ITI_Type.String = {'ExpRand', 'Static'};
    S.GUI.ITI_Type = 2;
    S.GUI.ITI = 0.05;
    S.GUI.MinLicksForReward = 1;
    S.GUI.MaxLicksForReward = 1;
    S.GUIPanels.TrialParameters = {'NrecentTrials','WaterValveTime',...
        'AutoWaterScale','LeftPortScale','RightPortScale','SamplePeriod',...
        'DelayPeriod','AnswerPeriod','ConsumptionPeriod','StopLickingPeriod',...
        'TimeOut','LeftTrialProb','ITI_Type','ITI','MinLicksForReward',...
        'MaxLicksForReward'};
    
    
    % spontaneous options
    S.GUIMeta.NumLickPorts.Style = 'popupmenu';
    S.GUIMeta.NumLickPorts.String = {'1', '2'};
    S.GUI.NumLickPorts = 2;
    S.GUIMeta.SpontCueType.Style = 'popupmenu';
    S.GUIMeta.SpontCueType.String = {'WaterDrop', 'None', 'GoCue'};
    S.GUI.SpontCueType = 1;
    S.GUIPanels.Spontaneous = {'NumLickPorts', 'SpontCueType'};
    
    % Lick sequence options
    S.GUIMeta.Direction.Style = 'popupmenu';
    S.GUIMeta.Direction.String = {'LearnAlternating', 'Alternating', 'Random', 'LeftToRight', 'RightToLeft'};
    S.GUI.Direction = 1;
    S.GUI.MotorPauseTime = 0.03;
    S.GUI.PositionLickTime = 0.150;
    S.GUIMeta.NumPositions.Style = 'popupmenu';
    S.GUIMeta.NumPositions.String = {'1', '2', '3', '4', '5'};
    S.GUI.NumPositions = 5;
    S.GUI.centerX = 23; % absolute center horizontal motor position (mm)
    S.GUI.deltaX = 1; % distance between positions (mm)
    S.GUI.cx = 0;
    S.GUI.cy = 0;
    S.GUI.deltaTheta = 20; % angle (degrees) of displacement per lick port position
    S.GUI.arcRadius = 2.2; % arc radius (mm) that lick ports will follow 
    S.GUI.SerialPort = 2; % Motor controlled by Module 2
    S.GUIPanels.LickSequence = {'Direction', 'NumPositions', 'MotorPauseTime', 'PositionLickTime', 'centerX', 'deltaX', 'cx', 'cy', 'deltaTheta', 'arcRadius', 'SerialPort'};
    
    % BlockPosition options
    S.GUI.cx = 0;
    S.GUI.cy = 0;
    S.GUI.blocksize = 25;
    S.GUI.deltaTheta = 35; % angle (degrees) of displacement per lick port position
    S.GUI.arcRadius = 2.2; % arc radius (mm) that lick ports will follow 
    S.GUI.SerialPort = 2; % Motor controlled by Module 2
%     S.GUIPanels.BlockPosition = {'blocksize','cx', 'cy', 'deltaTheta', 'arcRadius', 'SerialPort'};
    S.GUIPanels.BlockPosition = {};
    
    % Foraging Task options
    S.GUI.numLickPorts = 3;
    S.GUI.blockSize = 25;
    S.GUIPanels.Foraging = {'numLickPorts','blockSize'};

    % Session Parameters
    S.GUIMeta.Autowater.Style = 'popupmenu';	 % give free water on every trial?
    S.GUIMeta.Autowater.String = {'On', 'Off'};
    S.GUI.Autowater = 2;
    S.GUIPanels.SessionParameters= {'Location','Autowater'};
    
    % Trial Selection
    S.GUIMeta.Autolearn.Style = 'popupmenu';	 % trial type selection
    S.GUIMeta.Autolearn.String = {'On', 'Off', 'antiBias', 'PeriodicHelp'};
    S.GUI.Autolearn = 1;
    S.GUI.MaxSame = 4;
    S.GUI.Min_correct_Right = 2;
    S.GUI.Max_incorrect_Right = 2;
    S.GUI.Min_correct_Left = 2;
    S.GUI.Max_incorrect_Left = 2;
    S.GUIPanels.TrialSelection = {'Autolearn','MaxSame','Min_correct_Right','Max_incorrect_Right','Min_correct_Left','Max_incorrect_Left'};
    
    % Waveform Options
    S.GUIMeta.CameraTrigger.Style = 'checkbox';
    S.GUI.CameraTrigger = 0;
    S.GUIMeta.Bitcode.Style = 'checkbox';
    S.GUI.Bitcode = 0;
    S.GUIMeta.MaskingFlash.Style = 'checkbox';
    S.GUI.MaskingFlash = 0;
    S.GUIMeta.SGLxTrigger.Style = 'checkbox';
    S.GUI.SGLxTrigger = 0;
    S.GUIMeta.Stimulation.Style = 'checkbox';
    S.GUI.Stimulation = 0;
    S.GUIMeta.StimHemisphere.Style = 'popupmenu';
    S.GUIMeta.StimHemisphere.String = {'Unilateral', 'Bilateral','Both'};
    S.GUI.StimHemisphere = 2;
    S.GUI.StimProbability = 0.1;
    S.GUIPanels.WaveformOptions = {'CameraTrigger', 'Bitcode', 'MaskingFlash', 'SGLxTrigger', 'Stimulation', 'StimHemisphere', 'StimProbability'};
    
    
    
    %S.ProtocolHistory = [S.GUI.ProtocolType];	  % [protocol#]
    %S.LickPortMove = 0;		  % keeps track of the number of trials since the last lickport move, used by 'autoAdjustLickportPosition'
end




