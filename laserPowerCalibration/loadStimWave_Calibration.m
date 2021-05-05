function loadStimWave_Calibration(W, params, i) 
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

laserInputVoltage = params.amp.*ones(1,params.dur);

W.loadWaveform(params.num(1), laserInputVoltage);
%   loadWaveform(wavenumber, waveform)
%       wavenumber can be 1-64

    


