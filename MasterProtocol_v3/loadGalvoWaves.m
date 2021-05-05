function loadGalvoWaves(W, params, i)
% see BpodWiki
%   -> User Guide
%       -> Function Reference (Gen2)
%           -> serial message setup
%               -> LoadSerialMessages()
%                   see Serial Interfaces below
%           ->  Module MATLAB Plugins (USB)
%               -> BpodWavePlayer()
%                   -> loadWaveform(wavenumber, waveform)
%       -> Serial Interfaces
%           -> Analog Output Module
%               -> Bpod Wave Player
%                       has more information on LoadSerialMessages
%                       syntax
global S

dt = 1/W.SamplingRate;
tend = params.dur{i}+params.rampDur;

time = 0:dt:tend-dt;

numRepeats = floor(numel(time)/numel(params.xpos{i}));
modRepeats = mod(numel(time),numel(params.xpos{i}));

xWav = repmat(params.xpos{i},1,numRepeats);
xWav = [xWav, params.xpos{i}(1:modRepeats)];

yWav = repmat(params.ypos{i},1,numRepeats);
yWav = [yWav, params.ypos{i}(1:modRepeats)];

% if params.del{i} ~= 0
%     stimDelayZeros = zeros(1,params.del{i}.*W.SamplingRate);
%     xWav = [stimDelayZeros, xWav];
%     yWav = [stimDelayZeros, yWav];
% end
% 
% 
% 
% preStimTime = 0.02 + S.GUI.SamplePeriod;
% preStimZeros = zeros(1,preStimTime.*W.SamplingRate);
% 
% if strcmp(params.state{i}, 'GoCue')
%     moreZeros = zeros(1,S.GUI.DelayPeriod.*W.SamplingRate);
%     preStimZeros = [preStimZeros, moreZeros];
% end



preStimZeros = zeros(1, round(params.del{i}.*W.SamplingRate));



xWav = [preStimZeros, xWav];
yWav = [preStimZeros, yWav];


W.loadWaveform(params.num{i}(2), xWav); 
W.loadWaveform(params.num{i}(3), yWav); 


%   loadWaveform(wavenumber, waveform)
%       wavenumber can be 1-64