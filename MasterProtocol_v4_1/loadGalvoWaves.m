function loadGalvoWaves(W, params, i, angleCorFactor)
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

dt = 1/W.SamplingRate;
tend = params.dur{i}+params.rampDur;

time = 0:dt:tend-dt;

% makes wave of length params.dur{i}+params.rampDur
% accomodates for ramp down of stim
numRepeats = floor(numel(time)/numel(params.xpos{i}));
modRepeats = mod(numel(time),numel(params.xpos{i}));

xWav = repmat(params.xpos{i},1,numRepeats);
xWav = [xWav, params.xpos{i}(1:modRepeats)];

yWav = repmat(params.ypos{i},1,numRepeats);
yWav = [yWav, params.ypos{i}(1:modRepeats)];


W.loadWaveform(params.num{i}(2), xWav); 
W.loadWaveform(params.num{i}(3), yWav); 


%   loadWaveform(wavenumber, waveform)
%       wavenumber can be 1-64