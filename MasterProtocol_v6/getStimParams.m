function stim = getStimParams(W)
global S
num = {}; % indices of each waveform, used for serial message index
amp = {}; del = {}; dur = {};
loc = {};
xWav = {}; yWav = {};
stimWav = {};

voltsPerMilimeter = 0.188;
angleCorFactor = -0.15;%0.1331;

scanFreq = 40; %Hz, galvo scanning frequency
stimFreq = 0; %Hz, sinusoidal stimulation oscillation frequency

% [1 0 0 0] - ALM left
% [0 1 0 0] - ALM right
% [0 0 1 0] - M1TJ right
% [0 0 0 1] - M1TJ left
allLoc =      {'ALM_Uni', 'M1TJ_Uni', 'Both_Uni', 'ALM_Bi',  'M1TJ_Bi', 'Both_Bi'};
allStimLoc =  {[1 0 0 0]; [0 0 0 1];  [1 0 0 1];  [1 1 0 0]; [0 0 1 1]; [1 1 1 1]};

switch S.GUIMeta.StimHemisphere.String{S.GUI.StimHemisphere}
    case 'Unilateral'
        allStimLoc = allStimLoc(1:3);% unilateral ALM/M1TJ/both
        allLoc = allLoc(1:3);
    case 'Bilateral'
        allStimLoc = allStimLoc(4);% bilateral ALM/M1TJ/both
        allLoc = allLoc(4);% ([4:6] for all bilateral locations
    case 'Both'
%         allStimLoc = allStimLoc([1 4]); %uni and bi ALM
%         allLoc = allLoc([1 4]);
        allStimLoc = allStimLoc(6);%bi ALM
        allLoc = allLoc(6);
end

travelTime = 0.003;

allpow = {5, 10, 15}; % power gets multiplied later based on # and which locations
alldur = {0.7}; % linear ramp gets added later, delay time-0.2=0.7
alldel = {0}; % delays
% allstate = {'GoCue'};
allstate = {'GoCue'};


cnt = 10;
for i = 1:numel(allpow)
    for j = 1:numel(allStimLoc)
        for k = 1:numel(alldur)
            
            num{end+1} = cnt:cnt+2;
            
%             amp{end+1} = allpow{i}.*numel(allxpos{j});%k
%             pow{end+1} = allpow{i}; % for display purposes
%             xpos{end+1} = makeWav(allxpos{j}, voltsPerMilimeter);
%             ypos{end+1} = makeWav(allypos{j}, voltsPerMilimeter);
%             loc{end+1} = allLoc{j}; % for display purposes
%             dur{end+1} = alldur{k};

            if strcmp(allLoc{j},'ALM_Uni') || strcmp(allLoc{j},'M1TJ_Uni') % hard coded for 2020-07-30
                amp{end+1} = allpow{i};
            elseif strcmp(allLoc{j}, 'ALM_Bi') || strcmp(allLoc{j}, 'M1TJ_Bi') || strcmp(allLoc{j}, 'Both_Uni')
                amp{end+1} = allpow{i}*2;
            elseif strcmp(allLoc{j}, 'Both_Bi')
                amp{end+1} = allpow{i}*4;
            end
            
            dur{end+1} = alldur{k};
%             del{end+1} = alldel;
%             durIndex{end+1} = k;

            [xWavShort, yWavShort] = makeGalvoWav(travelTime, W, allStimLoc{j}, scanFreq, voltsPerMilimeter, angleCorFactor);
            stimWavShort = makeStimWav(travelTime, W, allStimLoc{j}, alldur{k}, amp{end}, scanFreq);
            
            loc{end+1} = allLoc{j}; % for display purposes
            % would be nice to put this in its own function
            stimSamples = alldur{k}*W.SamplingRate;
            numRepeats = floor(stimSamples/numel(xWavShort));
            modRepeats = mod(stimSamples,numel(xWavShort));

            % makes wave with length alldur{k}
            if modRepeats>0 % if not whole number of repetitions
                xWav{end+1} = [repmat(xWavShort,1,numRepeats), xWavShort(1:modRepeats)];
                yWav{end+1} = [repmat(yWavShort,1,numRepeats), yWavShort(1:modRepeats)];
                stimWav{end+1} = [repmat(stimWavShort,1,numRepeats), stimWavShort(1:modRepeats)];
            else
                xWav{end+1} = repmat(xWavShort,1,numRepeats);
                yWav{end+1} = repmat(yWavShort,1,numRepeats);
                stimWav{end+1} = repmat(stimWavShort,1,numRepeats);
            end
            % ramp & stimFreq get implemented when loaded onto waveplayer
            % in sendOutputWaveforms
            
            
            cnt = cnt+3;
        end
    end
end




stim.num = num;
stim.amp = amp;
stim.dur = dur;
% stim.durIndex = durIndex;
stim.xpos = xWav;
stim.ypos = yWav;
stim.loc = loc;
stim.pow = stimWav;

stim.del = alldel;
stim.state = allstate;

stim.rampDur = 0.2;
stim.stimFreq = stimFreq;


function wv = makeStimWav(travelTime, W, loc, dur, amp, scanFreq)
% loc is vector of 1s and 0s for stim locations
% 
% spotTime = 1/stimFreq/4;
% dwellTime = spotTime - travelTime;
% tptsTravel = ceil(travelTime*W.SamplingRate);
% tptsDwell = floor(dwellTime*W.SamplingRate);

tptsDwell = floor(W.SamplingRate.*(1./scanFreq)./sum(loc));

wv = [];
for i=1:4
    
    if ~loc(i)
        continue;
    end
%     if i < 4
%         nextLoc = loc(i+1);
%     else
%         nextLoc = loc(1);
%     end
%     travelStim = [loc(i)*[1 1], zeros(1,tptsTravel-4), nextLoc*[1 1]];
%     wv = [wv loc(i)*ones(1,tptsDwell) travelStim];
    wv = [wv ones(1,tptsDwell)];

end
wv = amp*wv;

% stimSamples = dur*W.SamplingRate;
% numRepeats = floor(stimSamples/numel(wv));
% modRepeats = mod(stimSamples,numel(wv));
% 
% if modRepeats>0
%     wv = [repmat(wv,1,numRepeats), wv(1:modRepeats)];
% else
%     wv = wv(xWav,1,numRepeats);
% end



function [xpos, ypos] = makeGalvoWav(travelTime, W, loc, scanFreq, voltsPerMilimeter, angleCorFactor)

% AP, lat
% 
% ALMl = [2.5; 1.5];
% ALMr = [2.5; -1.5];
ALMl = [2.5; 2.5];
ALMr = [2.5; -2.5];
M1TJr = [1.5; -2.5];
M1TJl = [1.5; 2.5];
mmLoc = [ALMl, ALMr, M1TJr, M1TJl];

% mmLoc(1,1) = AP position of ALMl, controlled by y galvo
% mmLoc(2,1) = ML position of ALMl, controlled by x galvo


% spotTime = 1/stimFreq/4;
% dwellTime = spotTime - travelTime;
% tptsTravel = ceil(travelTime*W.SamplingRate);
% tptsDwell = floor(dwellTime*W.SamplingRate);

tptsDwell = floor(W.SamplingRate.*(1./scanFreq)./sum(loc));

xpos = []; ypos = [];
for i = 1:4
%     xpos = [xpos, mmLoc(1, loc(i))*ones(1, tptsDwell),...
%         linspace(mmLoc(1, loc(i)), mmLoc(1, loc(i+1)), tptsTravel)];
    if ~loc(i)
        continue;
    end
    
    % code for swelling on points
%     xpos = [xpos, mmLoc(2, i)*ones(1, tptsDwell)];
%     xpos = [xpos, linspace(xpos(end),mmLoc(2, i), tptsDwell)];
%     if mmLoc(2,i)>0
%         ypos = [ypos, mmLoc(1, i)*ones(1, tptsDwell)];
%     else
%         ypos = [ypos, mmLoc(1, i)*ones(1, tptsDwell)*(1+tan(angleCorFactor))];
%     end

    % code for scanning between points
    if sum(loc)==1
        xpos = [xpos, mmLoc(2, i)*ones(1, tptsDwell)];
    
        if mmLoc(2,i)>0
            ypos = [ypos, mmLoc(1,i)*ones(1,tptsDwell)];
        else
            ypos = [ypos, mmLoc(1,i)*ones(1,tptsDwell)*(1+tan(angleCorFactor))];
        end
    else
        locIX = find(loc); % indices of stim locations
        % locIX < i gives logical vector same length as locIX
        % e.g. loc = [1 1 1 1]
        % locIX = [1 2 3 4]
        % for i = 3 -> locIX<i -> [1 1 0 0]
        % prevLoc = max(locIX([1 1 0 0])) 
        % if i == 1, prevLoc is empty
        
        prevLoc = max(locIX(locIX<i)); % finds max location less than i
        if isempty(prevLoc) % if i smaller than all locIX
            prevLoc = max(locIX);
        end
        % linspace from prev ML pos to current ML pos
        xpos = [xpos, linspace(mmLoc(2, prevLoc),mmLoc(2,i),tptsDwell)];
    
        
        % if ML value is negative for a location mmLoc(2,i), AP value gets
        % adjusted mmLoc(1,i)
        adjNextLoc = mmLoc(1,i);
        if mmLoc(2,i)<0 % only if next ML val is negative, otherwise no change
            adjNextLoc = mmLoc(1,i)*(1+tan(angleCorFactor));
        end
    
        adjPrevLoc = mmLoc(1,prevLoc);
        if mmLoc(2,prevLoc)<0 % only if prev ML val is negative, otherwise no change
            adjPrevLoc = mmLoc(1,prevLoc)*(1+tan(angleCorFactor));
        end
        % linspace from prev AP pos to current AP pos
        ypos = [ypos, linspace(adjPrevLoc, adjNextLoc, tptsDwell)];

    end
        
end

xpos = xpos*voltsPerMilimeter;
ypos = ypos*voltsPerMilimeter;
