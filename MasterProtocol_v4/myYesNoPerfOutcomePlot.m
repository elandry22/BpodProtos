function myYesNoPerfOutcomePlot(Action, TrialNum, TrialType)%, spontaneousPeriod, soundTaskPeriod)
% (GUIHandles, Action, Data)
global BpodSystem S

YesNoParams.Ylim = [0.75 4.25];
YesNoParams.ticks = [1 1.5 2 2.5 3.25 4];
YesNoParams.tickLabels = {'Reversal', 'Antibias', 'Autowater', 'Early', 'Left', 'Right'};

TotalPerfParams.Ylim = [0 1.05];
TotalPerfParams.Xlim = [0 700];
TotalPerfParams.ticks = [0.0 0.25 0.5 0.75 1.0];
TotalPerfParams.tickLabels = {'0 %', '25 %', '50 %', '75 %', '100 %'};


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
            
            % determine if correct and change marker properties
            plotTrialOutcome(TrialNum, plotInfo, plotColors, YesNoHandle);
            
            % update performance strings
            updateStatsText(TrialNum);
            
            % update total performance plot
            updateTotalPerfPlot(TotalPerfHandle, TotalPerfParams, plotColors);
            
            switch S.GUI.ProtocolType
                
                case {1, 2, 3} % 2AFC steps 1-3
                    
                    % plot early trial info
                    plotTrialEarly(TrialNum, plotInfo, plotColors, YesNoHandle);
                    
                    % plot autowater
                    plotTrialAutowater(TrialNum, plotInfo, plotColors, YesNoHandle);
                    
                    % plot autolearn info
                    plotTrialAutolearn(TrialNum, plotInfo, plotColors, YesNoHandle);
                    
                    % plot reversal
                    plotTrialReversal(TrialNum, plotInfo, plotColors, YesNoHandle);
                    
                case 4 % spontaneous
                    
                    % plot protocol type
                    plotCueType(TrialNum, plotInfo, plotColors, YesNoHandle);
         
                case 5 % lick sequence
                    
                    % plot early trial info
                    plotTrialEarly(TrialNum, plotInfo, plotColors, YesNoHandle);
                    
                    % plot autowater
                    plotTrialAutowater(TrialNum, plotInfo, plotColors, YesNoHandle);
                    
            end
            
        end
        
    case 'next_trial'
        
        YesNoHandle = BpodSystem.GUIHandles.YesNoPerfOutcomePlot;
        TextBoxHandle = BpodSystem.GUIHandles.DisplayNTrials;
        nTrialsToShow = str2double(get(TextBoxHandle, 'string'));
        
        plotNextTrial(TrialNum, TrialType, YesNoHandle, nTrialsToShow);
      
end






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

BpodSystem.ProtocolFigures.YesNoPerfOutcomePlotFig = figure('Position', [400 200 1320 500],...
    'Name','Outcome plot','NumberTitle','off','MenuBar','none','Resize','off','Color',[0.8 0.8 0.8]);
BpodSystem.GUIHandles.YesNoPerfOutcomePlot = axes('Position', [.12 .525 .65 .45]);%[.12 .25 .65 .7]
uicontrol('Style','text','String','nTrials','Position',[10 465 40 15]);%[10 315 40 15]
BpodSystem.GUIHandles.DisplayNTrials = uicontrol('Style','edit','string','80','Position',[10 440 40 20]);%[10 390 40 20]
BpodSystem.GUIHandles.TotalPerfPlot = axes('Position', [0.12 0.125 0.65 0.25]);


function initYesNoPlot(YesNoHandle, YesNoParams)

axes(YesNoHandle);
hold(YesNoHandle, 'on');

set(YesNoHandle,'TickDir', 'out','YLim', YesNoParams.Ylim, ...
    'YTick', YesNoParams.ticks, 'YTickLabel', YesNoParams.tickLabels, 'FontSize', 20);
xlim(YesNoHandle, [0 81])



function initTotalPerfPlot(TotalPerfHandle, TotalPerfParams)

axes(TotalPerfHandle);
set(TotalPerfHandle,'XLim', TotalPerfParams.Xlim, 'YLim', TotalPerfParams.Ylim, ...
    'YTick', TotalPerfParams.ticks,'YTickLabel', TotalPerfParams.tickLabels, 'FontSize', 20);



function initPerfText(TextLocation)

handles = {'All', 'Recent', 'R', 'L', 'NoResponse', 'Trials', 'Rewards'};
dispText = {'All:', 'Recent:', 'Right:', 'Left:', 'No Resp:', 'Trials:', 'Rewards:'};

createGUIHandles(handles, dispText, TextLocation);


function createGUIHandles(handles, dispText, TextLocation)
global BpodSystem

for i = 1:numel(handles)
    BpodSystem.GUIHandles.PerfStr.(handles{i}) = uicontrol('Style', 'text');
    BpodSystem.GUIHandles.Stats.(handles{i}) = uicontrol('Style', 'text');
    
    set(BpodSystem.GUIHandles.PerfStr.(handles{i}), 'HorizontalAlignment', 'Left', ...
        'String', dispText{i}, 'FontSize', 27, 'Position', TextLocation(1,:)-(i-1).*TextLocation(3,:))
    
    set(BpodSystem.GUIHandles.Stats.(handles{i}), 'HorizontalAlignment', 'Right', ...
        'String', 'NaN %', 'FontSize', 27, 'Position', TextLocation(2,:)-(i-1).*TextLocation(3,:))    
end


function plotInfo = saveTrialInfo(TrialNum)
global BpodSystem

plotInfo.Right = BpodSystem.Data.TrialData.Right(TrialNum);
plotInfo.Left = BpodSystem.Data.TrialData.Left(TrialNum);
plotInfo.Hit = BpodSystem.Data.TrialData.Hit(TrialNum);
plotInfo.Error = BpodSystem.Data.TrialData.Error(TrialNum);
plotInfo.NoResponse = BpodSystem.Data.TrialData.NoResponse(TrialNum);
plotInfo.Early = BpodSystem.Data.TrialData.Early(TrialNum);
plotInfo.Autolearn = BpodSystem.Data.TrialData.Autolearn(TrialNum);
plotInfo.Autowater = BpodSystem.Data.TrialData.Autowater(TrialNum);
plotInfo.Reversal = BpodSystem.Data.TrialData.Reversal(TrialNum);
plotInfo.WaterDrop = BpodSystem.Data.TrialData.WaterDrop(TrialNum);
plotInfo.None = BpodSystem.Data.TrialData.None(TrialNum);
plotInfo.GoCue = BpodSystem.Data.TrialData.GoCue(TrialNum);
plotInfo.LickedLeft = BpodSystem.Data.TrialData.LickedLeft(TrialNum);
plotInfo.LickedRight = BpodSystem.Data.TrialData.LickedRight(TrialNum);



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
y = []; y1 = [];

if plotInfo.Hit == 1 % if correct
    MarkerEdge = plotColors.Correct; MarkerFace = MarkerEdge;
elseif plotInfo.Error == 1 % if wrong
    MarkerEdge = plotColors.Error; MarkerFace = MarkerEdge;
elseif plotInfo.NoResponse == 1 % if no response
    MarkerEdge = plotColors.NoResponse; MarkerFace = 'w';
end

switch S.GUI.ProtocolType
    case {1, 2, 3}
        
        if plotInfo.Right == 1
            y = 4;
            y1 = 3.25;
        elseif plotInfo.Left == 1
            y = 3.25;
            y1 = 4;
        end
        
    case 4
%         if plotInfo.LickedRight == 1
%             y = 4;
%         elseif plotInfo.LickedLeft == 1
%             y = 3.25;
%         end
        
        if S.GUI.SpontCueType == 1
            if plotInfo.Right == 1
                y = 4;
                y1 = 3.25;
            elseif plotInfo.Left == 1
                y = 3.25;
                y1 = 4;
            end
        end
        
    case 5
        
        if plotInfo.Right == 1
            y = 4;
            y1 = 3.25;
        elseif plotInfo.Left == 1
            y = 3.25;
            y1 = 4;
        end
        
end

if ~isempty(y)
    plot(YesNoHandle, TrialNum, y, 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdge', MarkerEdge, 'MarkerFace', MarkerFace);
end
if ~isempty(y1)
    plot(YesNoHandle, TrialNum, y1, 'Marker', 'o', 'MarkerSize', 7, 'MarkerEdge', 'w', 'MarkerFace', 'w');
end

function plotTrialEarly(TrialNum, plotInfo, plotColors, YesNoHandle)
MarkerEdge = 'w'; MarkerFace = 'w';

if plotInfo.Early == 1 % if early lick enforced and licked early
    MarkerEdge = plotColors.Early; MarkerFace = MarkerEdge;
elseif plotInfo.Early == 0 % if early lick enforced and did not lick early
    MarkerEdge = plotColors.Early; MarkerFace = 'w';
end

y = 2.5;

plot(YesNoHandle, TrialNum, y, 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdge', MarkerEdge, 'MarkerFace', MarkerFace);


function plotTrialAutowater(TrialNum, plotInfo, plotColors, YesNoHandle)
MarkerEdge = 'w'; MarkerFace = 'w';

if plotInfo.Autowater == 0 % if autowater off
    MarkerEdge = plotColors.Autowater; MarkerFace = 'w';
elseif plotInfo.Autowater == 1 % if autowater on
    MarkerEdge = plotColors.Autowater; MarkerFace = MarkerEdge;
end
y = 2;

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
y = 1.5;

plot(YesNoHandle, TrialNum, y, 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdge', MarkerEdge, 'MarkerFace', MarkerFace);


function plotTrialReversal(TrialNum, plotInfo, plotColors, YesNoHandle)
MarkerEdge = 'w'; MarkerFace = 'w';

if plotInfo.Reversal == 0 % if autowater off
    MarkerEdge = plotColors.Reversal; MarkerFace = 'w';
elseif plotInfo.Reversal == 1 % if autowater on
    MarkerEdge = plotColors.Reversal; MarkerFace = MarkerEdge;
end
y = 1;

plot(YesNoHandle, TrialNum, y, 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdge', MarkerEdge, 'MarkerFace', MarkerFace);


function plotCueType(TrialNum, plotInfo, plotColors, YesNoHandle)
MarkerEdge = 'w'; MarkerFace = 'w';
y = []; y1 = []; % y1 covers trial type indicator

if plotInfo.WaterDrop == 1
    MarkerEdge = plotColors.WaterDrop; MarkerFace = MarkerEdge;
    y = 2;
elseif plotInfo.None == 1
    MarkerEdge = plotColors.None; MarkerFace = MarkerEdge;
    y = 1.5;
    y1 = [3.25, 4];
elseif plotInfo.GoCue == 1
    MarkerEdge = plotColors.GoCue; MarkerFace = MarkerEdge;
    y = 1;
    y1 = [3.25, 4];
end

if plotInfo.NoResponse == 1
    MarkerFace = 'w';
end

if ~isempty(y)
    plot(YesNoHandle, TrialNum, y, 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdge', MarkerEdge, 'MarkerFace', MarkerFace);
end


function updateStatsText(TrialNum)
global BpodSystem

set(BpodSystem.GUIHandles.Stats.All, 'String', [num2str(round(BpodSystem.Data.Stats.All(TrialNum)*100,0)),' %']);
set(BpodSystem.GUIHandles.Stats.Recent, 'String', [num2str(round(BpodSystem.Data.Stats.Recent(TrialNum)*100,0)),' %']);
set(BpodSystem.GUIHandles.Stats.R, 'String', [num2str(round(BpodSystem.Data.Stats.R(TrialNum)*100,0)),' %']);
set(BpodSystem.GUIHandles.Stats.L, 'String', [num2str(round(BpodSystem.Data.Stats.L(TrialNum)*100,0)),' %']);
set(BpodSystem.GUIHandles.Stats.NoResponse, 'String', [num2str(round(BpodSystem.Data.Stats.NoResponse(TrialNum)*100,0)),' %']);

rewards = sum(BpodSystem.Data.TrialData.Hit==1);

set(BpodSystem.GUIHandles.Stats.Trials, 'String', TrialNum);
set(BpodSystem.GUIHandles.Stats.Rewards, 'String', num2str(rewards));



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



function plotNextTrial(TrialNum, TrialType, YesNoHandle, nTrialsToShow)
global S

y = [];

rescaleX(YesNoHandle, TrialNum, nTrialsToShow);

hold on


if TrialType == 0 % right
    y = 4;
elseif TrialType == 1 % left
    y = 3.25;
end

if S.GUI.ProtocolType == 4 && S.GUI.SpontCueType ~= 1
    y = [];
end

if ~isempty(y)
    plot(YesNoHandle, TrialNum, y, 'Marker', 'o', 'MarkerSize', 6, 'MarkerEdge', 'k', 'MarkerFace', 'w');
    plot(YesNoHandle, TrialNum, y, 'Marker', '+', 'MarkerSize', 5.8, 'MarkerEdge', 'k', 'MarkerFace', 'none');
end
