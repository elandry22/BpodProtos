function myYesNoPerfOutcomePlot(Action, TrialNum, spontaneousPeriod, soundTaskPeriod)
% (GUIHandles, Action, Data)
global BpodSystem S

YesNoParams.Ylim = [0.75 4.25];
YesNoParams.ticks = [1 1.5 2 2.5 3.25 4];
YesNoParams.tickLabels = {'Reversal', 'Antibias', 'Autowater', 'Early', 'Left', 'Right'};

TotalPerfParams.Ylim = [0 1.05];
TotalPerfParams.Xlim = [0 700];
TotalPerfParams.ticks = [0.0 0.25 0.5 0.75 1.0];

for i=1:length(TotalPerfParams.ticks)
    TotalPerfParams.tickLabels(i) = {[num2str(TotalPerfParams.ticks(i)*100), '%']};
end

switch Action
    case 'init'
        
        TextLocation = initTextLocation();
        initFigures();
        
        YesNoHandle = BpodSystem.GUIHandles.YesNoPerfOutcomePlot;
        TotalPerfHandle = BpodSystem.GUIHandles.TotalPerfPlot;
        
        initYesNoPlot(YesNoHandle, YesNoParams);
        initTotalPerfPlot(TotalPerfHandle, TotalPerfParams);
        initPerfText(TextLocation);
        
    case 'update'
        
        YesNoHandle = BpodSystem.GUIHandles.YesNoPerfOutcomePlot;
        TotalPerfHandle = BpodSystem.GUIHandles.TotalPerfPlot;
        TextBoxHandle = BpodSystem.GUIHandles.DisplayNTrials;
        nTrialsToShow = str2double(get(TextBoxHandle, 'string'));
        
        hold(YesNoHandle, 'on');
        
        % Save CurrentTrial information to plot
        plotInfo = saveTrialInfo(TrialNum);
        plotColors = setColors();
        
        if TrialNum<1
            TrialNum = 1;
        end
        
        % recompute xlim
        rescaleX(YesNoHandle, TrialNum, nTrialsToShow);
        
        % plot currentTrial info
        if ~isempty(BpodSystem.Data.TrialTypes)
            
            if S.GUI.ProtocolType < 4
                
                % determine if correct and change marker properties
                plotTrialOutcome(TrialNum, plotInfo, plotColors, YesNoHandle);
                
                % plot early trial info
                plotTrialEarly(TrialNum, plotInfo, plotColors, YesNoHandle);
                
                % plot autowater
                plotTrialAutowater(TrialNum, plotInfo, plotColors, YesNoHandle);
                
                % plot autolearn info
                plotTrialAutolearn(TrialNum, plotInfo, plotColors, YesNoHandle);
                
                % plot reversal
                plotTrialReversal(TrialNum, plotInfo, plotColors, YesNoHandle);
                
                % update performance strings
                updatePerfText(TrialNum, spontaneousPeriod, soundTaskPeriod)
                
                % update total performance plot
                updateTotalPerfPlot(TotalPerfHandle, TotalPerfParams, plotColors);
            
            elseif S.GUI.ProtocolType == 4
                
                % determine if correct and change marker properties
                plotTrialOutcome(TrialNum, plotInfo, plotColors, YesNoHandle);
                
                % plot protocol type
                plotProtocolType(TrialNum, plotInfo, plotColors, YesNoHandle);
                
                % update performance strings
                updatePerfText(TrialNum, spontaneousPeriod, soundTaskPeriod)
                
                % update total performance plot
                updateTotalPerfPlot(TotalPerfHandle, TotalPerfParams, plotColors);
                
            end
            
        end
        
    case 'next_trial'
        
        YesNoHandle = BpodSystem.GUIHandles.YesNoPerfOutcomePlot;
        TextBoxHandle = BpodSystem.GUIHandles.DisplayNTrials;
        nTrialsToShow = str2double(get(TextBoxHandle, 'string'));
        
        if S.GUI.ProtocolType < 4
            plotNextTrial(TrialNum, YesNoHandle, nTrialsToShow);
        end
        
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rescaleX(AxesHandle, CurrentTrial, nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial + 1 - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);


function TextLocation = initTextLocation()
TextLocation = zeros(3,4);

PerfXleft = 1030; % from left
PerfXlengthL = 160;
PerfXlengthR = 280 - PerfXlengthL;
PerfXright = PerfXleft + PerfXlengthL;
PerfYtop = 440; % from bottom
PerfYheight = 45;
PerfYseparation = 10;
TextLocation(1,:) = [PerfXleft, PerfYtop, PerfXlengthL, PerfYheight];
TextLocation(2,:) = [PerfXright, PerfYtop, PerfXlengthR, PerfYheight];
TextLocation(3,:) = [0, (PerfYseparation+PerfYheight), 0, 0];


function initFigures()
global BpodSystem

BpodSystem.ProtocolFigures.YesNoPerfOutcomePlotFig = figure('Position', [400 200 1320 500],'Name','Outcome plot','NumberTitle','off','MenuBar','none','Resize','off','Color',[0.8 0.8 0.8]);
BpodSystem.GUIHandles.YesNoPerfOutcomePlot = axes('Position', [.12 .525 .65 .45]);%[.12 .25 .65 .7]
uicontrol('Style','text','String','nTrials','Position',[10 465 40 15]);%[10 315 40 15]
BpodSystem.GUIHandles.DisplayNTrials = uicontrol('Style','edit','string','80','Position',[10 440 40 20]);%[10 390 40 20]
BpodSystem.GUIHandles.TotalPerfPlot = axes('Position', [0.12 0.125 0.65 0.25]);


function initYesNoPlot(YesNoHandle, YesNoParams)

axes(YesNoHandle);
hold(YesNoHandle, 'on');

set(YesNoHandle,'TickDir', 'out','YLim', YesNoParams.Ylim, 'YTick', YesNoParams.ticks, 'YTickLabel', YesNoParams.tickLabels, 'FontSize', 20);
xlim(YesNoHandle, [0 81])


%hold(TotalPerfHandle, 'on');

function initTotalPerfPlot(TotalPerfHandle, TotalPerfParams)

axes(TotalPerfHandle);

set(TotalPerfHandle,'XLim', TotalPerfParams.Xlim, 'YLim', TotalPerfParams.Ylim, 'YTick', TotalPerfParams.ticks,'YTickLabel', TotalPerfParams.tickLabels, 'FontSize', 20);



function initPerfText(TextLocation)

handles = {'All', 'Recent', 'R', 'L', 'NoResponse', 'Trials', 'Rewards'};
dispText = {'All:', 'Recent:', 'Right:', 'Left:', 'No Resp:', 'Trials:', 'Rewards:'};

createGUIHandles(handles, dispText, TextLocation);


function createGUIHandles(handles, dispText, TextLocation)
global BpodSystem

for i = 1:numel(handles)
    BpodSystem.GUIHandles.PerfStr.(handles{i}) = uicontrol('Style', 'text');
    BpodSystem.GUIHandles.Stats.(handles{i}) = uicontrol('Style', 'text');
    
    set(BpodSystem.GUIHandles.PerfStr.(handles{i}), 'HorizontalAlignment', 'Left', 'String', dispText{i}, 'FontSize', 27, 'Position', TextLocation(1,:)-(i-1).*TextLocation(3,:))
    
    set(BpodSystem.GUIHandles.Stats.(handles{i}), 'HorizontalAlignment', 'Right', 'String', 'NaN %', 'FontSize', 27, 'Position', TextLocation(2,:)-(i-1).*TextLocation(3,:))    
end


function plotInfo = saveTrialInfo(TrialNum)
global BpodSystem

plotInfo.Right = BpodSystem.Data.dataToPlot.Right(TrialNum);
plotInfo.Left = BpodSystem.Data.dataToPlot.Left(TrialNum);
plotInfo.Hit = BpodSystem.Data.dataToPlot.Hit(TrialNum);
plotInfo.Error = BpodSystem.Data.dataToPlot.Error(TrialNum);
plotInfo.NoResponse = BpodSystem.Data.dataToPlot.NoResponse(TrialNum);
plotInfo.Early = BpodSystem.Data.dataToPlot.Early(TrialNum);
plotInfo.Autolearn = BpodSystem.Data.dataToPlot.Autolearn(TrialNum);
plotInfo.Autowater = BpodSystem.Data.dataToPlot.Autowater(TrialNum);
plotInfo.Reversal = BpodSystem.Data.dataToPlot.Reversal(TrialNum);
plotInfo.WaterDrop = BpodSystem.Data.dataToPlot.WaterDrop(TrialNum);
plotInfo.None = BpodSystem.Data.dataToPlot.None(TrialNum);
plotInfo.GoCue = BpodSystem.Data.dataToPlot.GoCue(TrialNum);
plotInfo.Licked = BpodSystem.Data.dataToPlot.Licked(TrialNum);
plotInfo.LickedLeft = BpodSystem.Data.dataToPlot.LickedLeft(TrialNum);
plotInfo.LickedRight = BpodSystem.Data.dataToPlot.LickedRight(TrialNum);
plotInfo.NoResponseSpontaneous = BpodSystem.Data.dataToPlot.NoResponseSpontaneous(TrialNum);





function plotColors = setColors()
plotColors.Correct = [50/255 205/255 50/255];
plotColors.Error = [255/255 85/255 60/255];
plotColors.NoResponse = 'k';
plotColors.Early = [0.93 0.57 0.13];
plotColors.Autolearn = [0 0.75 0.75];
plotColors.Antibias = [0 0 0.5];
plotColors.Autowater = [30/255 144/255 255/255];
plotColors.Reversal = [199/255 21/255 133/255];
plotColors.All = 'k';
plotColors.Recent = [0.5 0.5 0.5];
plotColors.Right = [0 102/256 204/256];
plotColors.Left = [256/256 0/256 25.6/256];
plotColors.WaterDrop = plotColors.Autowater;
plotColors.None = plotColors.Autolearn;
plotColors.GoCue = plotColors.Reversal;




function plotTrialOutcome(TrialNum, plotInfo, plotColors, YesNoHandle)
global S

MarkerEdge = 'w'; MarkerFace = 'w';
y = [];

if plotInfo.Hit == 1 % if correct
    MarkerEdge = plotColors.Correct; MarkerFace = MarkerEdge;
elseif plotInfo.Error == 1 % if wrong
    MarkerEdge = plotColors.Error; MarkerFace = MarkerEdge;
elseif plotInfo.NoResponse == 1 % if no response
    MarkerEdge = plotColors.NoResponse; MarkerFace = 'w';
end

if S.GUI.ProtocolType < 4
    if plotInfo.Right == 1
        y = 4;%find(contains(BpodSystem.Data.dataToPlotStr, 'Right')); % index of cell array corresponding to Right
    elseif plotInfo.Left == 1
        y = 3.25;%find(contains(BpodSystem.Data.dataToPlotStr, 'Left')); % index of cell array corresponding to Left
    end
end

if S.GUI.ProtocolType == 4
    if plotInfo.LickedRight == 1
        y = 4;
    elseif plotInfo.LickedLeft == 1
        y = 3.25;
    end
    if S.GUI.CueType == 1
        if plotInfo.Right == 1
            y = 4;
        elseif plotInfo.Left == 1
            y = 3.25;
        end
    end
end

if ~isempty(y)
    plot(YesNoHandle, TrialNum, y, 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdge', MarkerEdge, 'MarkerFace', MarkerFace);
end

function plotTrialEarly(TrialNum, plotInfo, plotColors, YesNoHandle)
MarkerEdge = 'w'; MarkerFace = 'w';

if plotInfo.Early == 1 % if early lick enforced and licked early
    MarkerEdge = plotColors.Early; MarkerFace = MarkerEdge;
elseif plotInfo.Early == 0 % if early lick enforced and did not lick early
    MarkerEdge = plotColors.Early; MarkerFace = 'w';
end
y = 2.5;%find(contains(BpodSystem.Data.dataToPlotStr, 'Early'));

plot(YesNoHandle, TrialNum, y, 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdge', MarkerEdge, 'MarkerFace', MarkerFace);


function plotTrialAutowater(TrialNum, plotInfo, plotColors, YesNoHandle)
MarkerEdge = 'w'; MarkerFace = 'w';

if plotInfo.Autowater == 0 % if autowater off
    MarkerEdge = plotColors.Autowater; MarkerFace = 'w';
elseif plotInfo.Autowater == 1 % if autowater on
    MarkerEdge = plotColors.Autowater; MarkerFace = MarkerEdge;
end
y = 2;%find(contains(BpodSystem.Data.dataToPlotStr, 'Autowater'));

plot(YesNoHandle, TrialNum, y, 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdge', MarkerEdge, 'MarkerFace', MarkerFace);


function plotTrialAutolearn(TrialNum, plotInfo, plotColors, YesNoHandle)
MarkerEdge = 'w'; MarkerFace = 'w';

if plotInfo.Autolearn == 0 % if autolearn off
    MarkerEdge = plotColors.Autolearn; MarkerFace = 'w';
elseif plotInfo.Autolearn == 1 % if autolearn on
    MarkerEdge = plotColors.Autolearn; MarkerFace = MarkerEdge;
elseif plotInfo.Autolearn == 2 % if antibias on
    MarkerEdge = plotColors.Antibias; MarkerFace = MarkerEdge;
end
y = 1.5;%find(contains(BpodSystem.Data.dataToPlotStr, 'Autolearn'));

plot(YesNoHandle, TrialNum, y, 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdge', MarkerEdge, 'MarkerFace', MarkerFace);


function plotTrialReversal(TrialNum, plotInfo, plotColors, YesNoHandle)
MarkerEdge = 'w'; MarkerFace = 'w';

if plotInfo.Reversal == 0 % if autowater off
    MarkerEdge = plotColors.Reversal; MarkerFace = 'w';
elseif plotInfo.Reversal == 1 % if autowater on
    MarkerEdge = plotColors.Reversal; MarkerFace = MarkerEdge;
end
y = 1;%find(contains(BpodSystem.Data.dataToPlotStr, 'Reversal'));

plot(YesNoHandle, TrialNum, y, 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdge', MarkerEdge, 'MarkerFace', MarkerFace);


function plotProtocolType(TrialNum, plotInfo, plotColors, YesNoHandle)
MarkerEdge = 'w'; MarkerFace = 'w';
y = [];

if plotInfo.WaterDrop == 1
    MarkerEdge = plotColors.WaterDrop; MarkerFace = MarkerEdge;
    y = 2;
elseif plotInfo.None == 1
    MarkerEdge = plotColors.None; MarkerFace = MarkerEdge;
    y = 1.5;
elseif plotInfo.GoCue == 1
    MarkerEdge = plotColors.GoCue; MarkerFace = MarkerEdge;
    y = 1;
end

if plotInfo.NoResponseSpontaneous == 1
    MarkerFace = 'w';
end

if ~isempty(y)
    plot(YesNoHandle, TrialNum, y, 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdge', MarkerEdge, 'MarkerFace', MarkerFace);
end


function updatePerfText(TrialNum, spontaneousPeriod, soundTaskPeriod)
global BpodSystem S

if S.GUI.ProtocolType < 4
    
    setStatsAll(TrialNum, soundTaskPeriod);
    
    Nrecent = S.GUI.NrecentTrials;
    
    setStatsRecent(TrialNum, soundTaskPeriod, Nrecent);
    
    setStatsRight(TrialNum, soundTaskPeriod);
    
    setStatsLeft(TrialNum, soundTaskPeriod);
    
    setStatsNoResponse(TrialNum, soundTaskPeriod);
    rewards = sum(sum([BpodSystem.Data.dataToPlot.Hit==1, BpodSystem.Data.dataToPlot.Licked==1]));
    
    set(BpodSystem.GUIHandles.Stats.Trials, 'String', TrialNum);
    set(BpodSystem.GUIHandles.Stats.Rewards, 'String', num2str(rewards));
elseif S.GUI.ProtocolType == 4
    
    setStatsNoResponse(TrialNum, spontaneousPeriod);
    BpodSystem.Data.Stats.NoResponseSpontaneous(TrialNum) = sum(BpodSystem.Data.dataToPlot.NoResponseSpontaneous==1)/TrialNum;
    rewards = sum(sum([BpodSystem.Data.dataToPlot.Hit==1, BpodSystem.Data.dataToPlot.Licked==1]));
    set(BpodSystem.GUIHandles.Stats.Trials, 'String', TrialNum);
    set(BpodSystem.GUIHandles.Stats.Rewards, 'String', num2str(rewards));


end


function setStatsAll(TrialNum, soundTaskPeriod)
global BpodSystem

if sum(BpodSystem.Data.dataToPlot.NoResponse==0) > 0
    BpodSystem.Data.Stats.All(TrialNum) = sum(BpodSystem.Data.dataToPlot.Hit==1)/sum(BpodSystem.Data.dataToPlot.NoResponse==0);
    BpodSystem.Data.Stats.(['ST', num2str(soundTaskPeriod)]).All(TrialNum) = sum(BpodSystem.Data.dataToPlot.(['ST', num2str(soundTaskPeriod)]).Hit==1)/sum(BpodSystem.Data.dataToPlot.(['ST', num2str(soundTaskPeriod)]).NoResponse==0);
    set(BpodSystem.GUIHandles.Stats.All, 'String', [num2str(round(BpodSystem.Data.Stats.(['ST', num2str(soundTaskPeriod)]).All(TrialNum)*100,0)),' %']);
end


function setStatsRecent(TrialNum, soundTaskPeriod, Nrecent)
global BpodSystem

if TrialNum>=Nrecent
    if sum(BpodSystem.Data.dataToPlot.NoResponse(TrialNum-(Nrecent-1):TrialNum)==0) > 0
        BpodSystem.Data.Stats.Recent(TrialNum) = sum(BpodSystem.Data.dataToPlot.Hit(TrialNum-(Nrecent-1):TrialNum)==1)/sum(BpodSystem.Data.dataToPlot.NoResponse(TrialNum-(Nrecent-1):TrialNum)==0);
        BpodSystem.Data.Stats.(['ST', num2str(soundTaskPeriod)]).Recent(TrialNum) = sum(BpodSystem.Data.dataToPlot.(['ST', num2str(soundTaskPeriod)]).Hit(TrialNum-(Nrecent-1):TrialNum)==1)/sum(BpodSystem.Data.dataToPlot.(['ST', num2str(soundTaskPeriod)]).NoResponse(TrialNum-(Nrecent-1):TrialNum)==0);   
    end
else
    if sum(BpodSystem.Data.dataToPlot.NoResponse(1:TrialNum)==0) > 0
        BpodSystem.Data.Stats.Recent(TrialNum) = sum(BpodSystem.Data.dataToPlot.Hit==1)/sum(BpodSystem.Data.dataToPlot.NoResponse(1:TrialNum)==0);
        BpodSystem.Data.Stats.(['ST', num2str(soundTaskPeriod)]).Recent(TrialNum) = sum(BpodSystem.Data.dataToPlot.(['ST', num2str(soundTaskPeriod)]).Hit==1)/sum(BpodSystem.Data.dataToPlot.(['ST', num2str(soundTaskPeriod)]).NoResponse(1:TrialNum)==0);
    end
end
set(BpodSystem.GUIHandles.Stats.Recent, 'String', [num2str(round(BpodSystem.Data.Stats.(['ST', num2str(soundTaskPeriod)]).Recent(TrialNum)*100,0)),' %']);


function setStatsRight(TrialNum, soundTaskPeriod)
global BpodSystem

if sum(BpodSystem.Data.dataToPlot.Right==1) > 0
    BpodSystem.Data.Stats.R(TrialNum) = sum(BpodSystem.Data.dataToPlot.Hit==1 & BpodSystem.Data.dataToPlot.Right==1)/sum(BpodSystem.Data.dataToPlot.Right==1 & BpodSystem.Data.dataToPlot.NoResponse==0);
    BpodSystem.Data.Stats.(['ST', num2str(soundTaskPeriod)]).R(TrialNum) = sum(BpodSystem.Data.dataToPlot.(['ST', num2str(soundTaskPeriod)]).Hit==1 & BpodSystem.Data.dataToPlot.(['ST', num2str(soundTaskPeriod)]).Right==1)/sum(BpodSystem.Data.dataToPlot.(['ST', num2str(soundTaskPeriod)]).Right==1 & BpodSystem.Data.dataToPlot.(['ST', num2str(soundTaskPeriod)]).NoResponse==0);
    
    set(BpodSystem.GUIHandles.Stats.R, 'String', [num2str(round(BpodSystem.Data.Stats.(['ST', num2str(soundTaskPeriod)]).R(TrialNum)*100,0)),' %']);
end


function setStatsLeft(TrialNum, soundTaskPeriod)
global BpodSystem

if sum(BpodSystem.Data.dataToPlot.Left==1) > 0
    BpodSystem.Data.Stats.L(TrialNum) = sum(BpodSystem.Data.dataToPlot.Hit==1 & BpodSystem.Data.dataToPlot.Left==1)/sum(BpodSystem.Data.dataToPlot.Left==1 & BpodSystem.Data.dataToPlot.NoResponse==0);
    BpodSystem.Data.Stats.(['ST', num2str(soundTaskPeriod)]).L(TrialNum) = sum(BpodSystem.Data.dataToPlot.(['ST', num2str(soundTaskPeriod)]).Hit==1 & BpodSystem.Data.dataToPlot.(['ST', num2str(soundTaskPeriod)]).Left==1)/sum(BpodSystem.Data.dataToPlot.(['ST', num2str(soundTaskPeriod)]).Left==1 & BpodSystem.Data.dataToPlot.(['ST', num2str(soundTaskPeriod)]).NoResponse==0);
    
    set(BpodSystem.GUIHandles.Stats.L, 'String', [num2str(round(BpodSystem.Data.Stats.(['ST', num2str(soundTaskPeriod)]).L(TrialNum)*100,0)),' %']);
end


function setStatsNoResponse(TrialNum, Period)
global BpodSystem S

if S.GUI.ProtocolType < 4
    BpodSystem.Data.Stats.NoResponse(TrialNum) = sum(BpodSystem.Data.dataToPlot.NoResponse==1)/TrialNum;
    BpodSystem.Data.Stats.(['ST', num2str(Period)]).NoResponse(TrialNum) = sum(BpodSystem.Data.dataToPlot.(['ST', num2str(Period)]).NoResponse==1)/sum([BpodSystem.Data.dataToPlot.(['ST', num2str(Period)]).NoResponse==1, BpodSystem.Data.dataToPlot.(['ST', num2str(Period)]).NoResponse==0]);
    set(BpodSystem.GUIHandles.Stats.NoResponse, 'String', [num2str(round(BpodSystem.Data.Stats.(['ST', num2str(Period)]).NoResponse(TrialNum)*100,0)),' %']);
elseif S.GUI.ProtocolType == 4
    BpodSystem.Data.Stats.NoResponseSpontaneous(TrialNum) = sum(BpodSystem.Data.dataToPlot.NoResponse==1)/TrialNum;
    BpodSystem.Data.Stats.(['S', num2str(Period)]).NoResponse(TrialNum) = sum(BpodSystem.Data.dataToPlot.(['S', num2str(Period)]).NoResponse==1)/sum([BpodSystem.Data.dataToPlot.(['S', num2str(Period)]).NoResponse==1, BpodSystem.Data.dataToPlot.(['S', num2str(Period)]).NoResponse==0]);
    set(BpodSystem.GUIHandles.Stats.NoResponse, 'String', [num2str(round(BpodSystem.Data.Stats.(['S', num2str(Period)]).NoResponse(TrialNum)*100,0)),' %']);
end


function updateTotalPerfPlot(TotalPerfHandle, TotalPerfParams, plotColors)
global BpodSystem

hold(TotalPerfHandle, 'off')
plot(TotalPerfHandle, 1:length(BpodSystem.Data.Stats.All), BpodSystem.Data.Stats.All, 'Color', plotColors.All, 'LineWidth', 2);
hold(TotalPerfHandle, 'on')
plot(TotalPerfHandle, 1:length(BpodSystem.Data.Stats.Recent), BpodSystem.Data.Stats.Recent, 'Color', plotColors.Recent, 'LineWidth', 1);
plot(TotalPerfHandle, 1:length(BpodSystem.Data.Stats.R), BpodSystem.Data.Stats.R, 'Color', plotColors.Right, 'LineWidth', 1.5);
plot(TotalPerfHandle, 1:length(BpodSystem.Data.Stats.L), BpodSystem.Data.Stats.L, 'Color', plotColors.Left, 'LineWidth', 1.5);
plot(TotalPerfHandle, 1:length(BpodSystem.Data.Stats.NoResponse), BpodSystem.Data.Stats.NoResponse, ':', 'Color', plotColors.NoResponse, 'LineWidth', 1.5);

set(TotalPerfHandle,'XLim', TotalPerfParams.Xlim, 'YLim', TotalPerfParams.Ylim, 'YTick', TotalPerfParams.ticks, 'YTickLabel', TotalPerfParams.tickLabels, 'FontSize', 20);
legend(TotalPerfHandle, 'Perf', 'Recent', 'Perf R', 'Perf L', 'No Resp', 'Location', 'Best');

function plotNextTrial(TrialNum, YesNoHandle, nTrialsToShow)
global BpodSystem

RightPlot = 0; LeftPlot = 0;
y = [];

if ~isempty(BpodSystem.Data.TrialTypes)
    RightPlot = BpodSystem.Data.dataToPlot.Right(TrialNum);
    LeftPlot = BpodSystem.Data.dataToPlot.Left(TrialNum);
end

% Save CurrentTrial information to plot
rescaleX(YesNoHandle, TrialNum, nTrialsToShow);

hold on
if RightPlot == 1
    y = 4;%find(contains(BpodSystem.Data.dataToPlotStr, 'Right'));
elseif LeftPlot == 1
    y = 3.25;%find(contains(BpodSystem.Data.dataToPlotStr, 'Left'));
end

if ~isempty(y)
    plot(YesNoHandle, TrialNum, y, 'Marker', 'o', 'MarkerSize', 6, 'MarkerEdge', 'k', 'MarkerFace', 'w');
    plot(YesNoHandle, TrialNum, y, 'Marker', '+', 'MarkerSize', 5.8, 'MarkerEdge', 'k', 'MarkerFace', 'none');
end
