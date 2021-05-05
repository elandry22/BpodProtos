function loadStimWave(W, params, i) 
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

ramp = (time - tend)./(params.dur{i}-tend);
ramp(time<params.dur{i}) = 1;

numRepeats = floor(numel(time)/numel(params.xpos{i}));
modRepeats = mod(numel(time),numel(params.xpos{i}));

pow = repmat(params.pow{i},1,numRepeats);
pow = [pow, params.pow{i}(1:modRepeats)];

powerOutput = pow.*(0.5+0.5*cos(2*pi*time*params.stimFreq));
powerOutput = powerOutput.*ramp;


power =   [0 0.69 1.33 3.13 6.02 11.92 17.35 23  28]*(5.20/6.02); %in mW last term is power at 1 V
voltage = [0 0.1  0.2  0.5  1.0  2.0   3.0   4.0 5.0]; % in V

laserInputVoltage = interp1(power, voltage, min(powerOutput, max(power)));


W.loadWaveform(params.num{i}(1), laserInputVoltage); 
%   loadWaveform(wavenumber, waveform)
%       wavenumber can be 1-64

    


