function loadGalvoWaves_optoTagging(W, params)
global S
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

numRepeats = floor(params.nSamp/numel(params.xpos));
modRepeats = mod(params.nSamp,numel(params.xpos));

xWav = repmat(params.xpos,1,numRepeats);
xWav = [xWav, params.xpos(1:modRepeats)];

yWav = repmat(params.ypos,1,numRepeats);
yWav = [yWav, params.ypos(1:modRepeats)];

W.loadWaveform(params.num(2), xWav)
W.loadWaveform(params.num(3), yWav)

%   loadWaveform(wavenumber, waveform)
%       wavenumber can be 1-64