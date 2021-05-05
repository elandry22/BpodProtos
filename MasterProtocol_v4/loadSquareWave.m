function loadSquareWave(W, params) 
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
    pulseWid_ms = params.pulsewid;
    tend = params.duration;
    pulseAmp = 5;
    
    pulsePer_ms = 1000*(1/params.freq);
    time = 0:dt:tend-dt;
    impulsetrain = pulseAmp.*(mod(time, pulsePer_ms/1000)<pulseWid_ms/1000);
   
    W.loadWaveform(params.waveNum, impulsetrain);
    %   loadWaveform(wavenumber, waveform)
    %       wavenumber can be 1-64



