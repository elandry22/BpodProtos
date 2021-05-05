function loadStimWave(W, params) 
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
    tend = params.duration+params.rampDownDur;

    time = 0:dt:tend-dt;
    ramp = (time - tend)./(params.duration-tend);
    ramp(time<params.duration) = 1;
    impulsetrain = params.amplitude.*(0.5+0.5*cos(2*pi*time*params.freq));
    impulsetrain = impulsetrain.*ramp;
   
    W.loadWaveform(params.waveNum, impulsetrain);
    %   loadWaveform(wavenumber, waveform)
    %       wavenumber can be 1-64

    


