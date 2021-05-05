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
global S

dt = 1/W.SamplingRate;
tend = params.dur{i}+params.rampDur;

time = 0:dt:tend-dt;
ramp = (time - tend)./(params.dur{i}-tend);
ramp(time<params.dur{i}) = 1;
powerOutput = params.amp{i}.*(0.5+0.5*cos(2*pi*time*params.freq));
powerOutput = powerOutput.*ramp;


power =   [0 0.69 1.33 3.13 6.02 11.92 17.35 23  28]*(2.37/6.02); %in mW last term is power at 1 V
voltage = [0 0.1  0.2  0.5  1.0  2.0   3.0   4.0 5.0]; % in V

laserInputVoltage = interp1(power, voltage, powerOutput);

% if params.del{i} ~= 0
%     stimDelayZeros = zeros(1,params.del{i}.*W.SamplingRate);
%     laserInputVoltage = [stimDelayZeros, laserInputVoltage];
% end
% 
% 
% 
% preStimTime = 0.02 + + S.GUI.SamplePeriod;
% preStimZeros = zeros(1,preStimTime.*W.SamplingRate);
% 
% if strcmp(params.state{i}, 'GoCue')
%     moreZeros = zeros(1,S.GUI.DelayPeriod.*W.SamplingRate);
%     preStimZeros = [preStimZeros, moreZeros];
% end

preStimZeros = zeros(1, round(params.del{i}.*W.SamplingRate));



laserInputVoltage = [preStimZeros, laserInputVoltage];

W.loadWaveform(params.num{i}(1), laserInputVoltage); 
%   loadWaveform(wavenumber, waveform)
%       wavenumber can be 1-64

    


