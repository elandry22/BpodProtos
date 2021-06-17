function loadSquareWave(W, params) 

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
    

    dt = 1/W.SamplingRate; %s
    pulseWid_ms = params.pulsewid; %ms
    tend = params.duration; %s
    
    time = 0:dt:tend-dt;
    sawToothWave = mod(time, 1/params.freq); % saw tooth wave with period 1/params.freq
    impulsetrain = params.pulseAmp.*(sawToothWave<pulseWid_ms/1000);
   % mod(time, pulsePer_ms) makes triangle wave at freq params.freq
   % which gets compared to pulseWid_ms/1000
   % if mod smaller than pulseWid, impulsetrain gets value of pulseAmp
    W.loadWaveform(params.waveNum, impulsetrain);
    %   loadWaveform(wavenumber, waveform)
    %       wavenumber can be 1-64



