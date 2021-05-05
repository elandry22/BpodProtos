function myYesNoPerfOutcomePlot(Action, TrialNum)
% (GUIHandles, Action, Data)
global BpodSystem

switch Action
    case 'init'
        
        TextLocation = initTextLocation();
        initFigures();
        
        YesNoHandle = BpodSystem.GUIHandles.YesNoPerfOutcomePlot;
        TotalPerfHandle = BpodSystem.GUIHandles.TotalPerfPlot;
        
        initYesNoPlot(YesNoHandle);
        initTotalPerfPlot(TotalPerfHandle);
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
            
            % plot protocol type
            plotProtocolType(TrialNum, plotInfo, plotColors, YesNoHandle);

            % update performance strings
            updatePerfText(TrialNum)
        
            % update total performance plot
            updateTotalPerfPlot(TotalPerfHandle, plotColors);
            
        end
        
    case 'next_trial'
        
        YesNoHandle = BpodSystem.GUIHandles.YesNoPerfOutcomePlot;
        TextBoxHandle = BpodSystem.GUIHandles.DisplayNTrials;
        nTrialsToShow = str2double(get(TextBoxHandle, 'string'));
        
        plotNextTrial(TrialNum, YesNoHandle, nTrialsToShow);
        
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


function initYesNoPlot(YesNoHandle)

axes(YesNoHandle);
hold(YesNoHandle, 'on');

ticks = [1 2 3];
tickLabels = {'GoCue', 'None', 'WaterDrop'};

set(YesNoHandle,'TickDir', 'out','YLim', [0.75 4], 'YTick', ticks, 'YTickLabel', tickLabels, 'FontSize', 20);
%hold(AxesHandle, 'on');
xlim([0 81])


%hold(TotalPerfHandle, 'on');

function initTotalPerfPlot(TotalPerfHandle)

axes(TotalPerfHandle);

set(TotalPerfHandle, 'XLim', [0 300], 'FontSize', 20);



function initPerfText(TextLocation)

handles = {'NoResponse', 'Trials', 'Rewards'};
dispText = {'No Resp:', 'Trials:', 'Rewards:'};

createGUIHandles(handles, dispText, TextLocation);


function createGUIHandles(handles, dispText, TextLocation)
global BpodSystem

for i = 1:numel(handles)
    BpodSystem.GUIHandles.PerfStr.(handles{i}) = uicontrol('Style', 'text');
    BpodSystem.GUIHandles.Perf.(handles{i}) = uicontrol('Style', 'text');
    
    set(BpodSystem.GUIHandles.PerfStr.(handles{i}), 'HorizontalAlignment', 'Left', 'String', dispText{i}, 'FontSize', 27, 'Position', TextLocation(1,:)-(i-1).*TextLocation(3,:))
    set(BpodSystem.GUIHandles.Perf.(handles{i}), 'HorizontalAlignment', 'Right', 'String', 'NaN', 'FontSize', 27, 'Position', TextLocation(2,:)-(i-1).*TextLocation(3,:))    
end


function plotInfo = saveTrialInfo(TrialNum)
global BpodSystem S

ProtocolType = S.GUI.ProtocolType;

plotInfo.WaterDrop = double(ProtocolType==1);
plotInfo.None = double(ProtocolType==2);
plotInfo.GoCue = double(ProtocolType==3);
plotInfo.NoResponse = BpodSystem.Data.dataToPlot.NoResponse(TrialNum);



function plotColors = setColors()
%plotColors.Correct = [50/255 205/255 50/255];
%plotColors.Error = [255/255 85/255 60/255];
plotColors.NoResponse = 'k';
plotColors.None = [0 0.75 0.75];
plotColors.WaterDrop = [30/255 144/255 255/255];
plotColors.GoCue = [199/255 21/255 133/255];
% plotColors.Right = [0 102/256 204/256];
% plotColors.Left = [256/256 0/256 25.6/256];


function plotProtocolType(TrialNum, plotInfo, plotColors, YesNoHandle)
MarkerEdge = 'w'; MarkerFace = 'w';
y = 0;

if plotInfo.WaterDrop == 1
    MarkerEdge = plotColors.WaterDrop; MarkerFace = MarkerEdge;
    y = 1;
elseif plotInfo.None == 1
    MarkerEdge = plotColors.None; MarkerFace = MarkerEdge;
    y = 2;
elseif plotInfo.GoCue == 1
    MarkerEdge = plotColors.GoCue; MarkerFace = MarkerEdge;
    y = 3;
end

if plotInfo.NoResponse == 1
    MarkerFace = 'w';
end

plot(YesNoHandle, TrialNum, y, 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdge', MarkerEdge, 'MarkerFace', MarkerFace);



function updatePerfText(TrialNum)
global BpodSystem 
% 
% if sum(BpodSystem.Data.dataToPlot.NoResponse==0) ~= 0
%     BpodSystem.Data.Perf.All(TrialNum) = sum(BpodSystem.Data.dataToPlot.Hit==1)/sum(BpodSystem.Data.dataToPlot.NoResponse==0);
%     set(BpodSystem.GUIHandles.Perf.All, 'String', [num2str(round(BpodSystem.Data.Perf.All(TrialNum)*100,0)),' %']);
% end

BpodSystem.Data.Perf.NoResponse(TrialNum) = sum(BpodSystem.Data.dataToPlot.NoResponse==1)/TrialNum;
set(BpodSystem.GUIHandles.Perf.NoResponse, 'String', [num2str(round(BpodSystem.Data.Perf.NoResponse(TrialNum)*100,0)),' %']);

set(BpodSystem.GUIHandles.Perf.Trials, 'String', TrialNum)

set(BpodSystem.GUIHandles.Perf.Rewards, 'String', num2str(sum(BpodSystem.Data.dataToPlot.Licked==1)));


function updateTotalPerfPlot(TotalPerfHandle, plotColors)
global BpodSystem

hold(TotalPerfHandle, 'off')
plot(TotalPerfHandle, 1:length(BpodSystem.Data.Perf.NoResponse), BpodSystem.Data.Perf.NoResponse, plotColors.NoResponse, 'LineWidth', 1.5);

set(TotalPerfHandle,'XLim', [0 300], 'YLim', [0 1.05], 'YTick', [0.0 0.25 0.5 0.75 1.0],'YTickLabel', {'0%', '25%', '50%', '75%', '100%'}, 'FontSize', 20);
legend(TotalPerfHandle, 'No Resp', 'Location', 'Best');

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
