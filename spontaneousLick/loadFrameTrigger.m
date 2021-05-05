function loadFrameTrigger(port, params) 
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
    
    clear W
    
    W = BpodWavePlayer(port);
    W.SamplingRate = 10000; 
    
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

    
    LoadSerialMessages('WavePlayer1', {['P' params.BNCchan params.waveNum-1], 'X'});
    % LoadSerialMessages(serial port, {messages})
    % {message1, message2}
    %   [command, BNC channel#, message#(zero indexed)/wavenumber(one indexed)]
    %   ['P' 1 1] 
    %       [Play, channel 1 of analog output module, zero-indexed index of waveform used in LoadWaveform]
    %   'X' stop
    

