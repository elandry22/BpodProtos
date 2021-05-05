function sma = addTrialStartStates(sma, bitparams, TrialNum)

sma = setTimers(sma);
sma = addBitcodeStates(sma, bitparams, TrialNum);




function sma = setTimers(sma)
global S

locationNum = S.GUI.Location;

if ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Box'))
    
    sma = AddState(sma, 'Name', 'TrialStart', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'bit1'},...
        'OutputActions', []);
    
elseif ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Rig'))
    SGLxTriggerOutput = [];
    CameraTriggerOutput = [];
    MaskingFlashTriggerOutput = [];
    
    
    if S.GUI.SGLxTrigger
        sma = SetGlobalTimer(sma, 'TimerID', 1, 'Duration', 60, ...
            'OnsetDelay', 0, 'Channel', 'BNC1', 'OnsetValue', 1, 'OffsetValue', 0);
        SGLxTriggerOutput = {'GlobalTimerTrig',1};
    end
    
    if S.GUI.CameraTrigger
        sma = SetGlobalTimer(sma, 'TimerID', 2, 'Duration', 1, 'OnsetDelay', 0, ...
            'Channel', 'WavePlayer1', 'OnMessage', 2, 'OffMessage', 1,...
            'Loop', 1, 'SendGlobalTimerEvents', 0);
        CameraTriggerOutput = {'GlobalTimerTrig',2};
    end
    
    if S.GUI.MaskingFlash
        sma = SetGlobalTimer(sma, 'TimerID', 3, 'Duration', 60, 'OnsetDelay', 0, ...
            'Channel', 'WavePlayer1', 'OnMessage', 3, ...
            'Loop', 0, 'SendGlobalTimerEvents', 0);
        MaskingFlashTriggerOutput = {'GlobalTimerTrig',3};
    end
    
    if S.GUI.Stimulation
        sma = SetGlobalTimer(sma, 'TimerID', 4, 'Duration', 60, 'OnsetDelay', 0, ...
            'Channel', 'WavePlayer1', 'OnMessage', 4, ...
            'Loop', 0, 'SendGlobalTimerEvents', 0);
    end
    
    sma = AddState(sma, 'Name', 'TrialStart', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'TrigSGLX'},...
        'OutputActions', []);
    sma = AddState(sma, 'Name', 'TrigSGLX', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'TrigCamera'},...
        'OutputActions', SGLxTriggerOutput);
    sma = AddState(sma, 'Name', 'TrigCamera', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'TrigMaskingFlash'},...
        'OutputActions', CameraTriggerOutput);
    sma = AddState(sma, 'Name', 'TrigMaskingFlash', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'bit1'},...
        'OutputActions', MaskingFlashTriggerOutput);
end





function sma = addBitcodeStates(sma, bitparams, TrialNum)
global S

locationNum = S.GUI.Location;

if S.GUI.Bitcode
    Nbits = bitparams.Nrand+bitparams.Ntrial+1;
    
    decTrialCode = TrialNum;
    decRandCode = bitparams.randNum;
    
    binTrialCode = dec2bin(decTrialCode, bitparams.Ntrial);
    binRandCode = dec2bin(decRandCode, bitparams.Nrand);
    binCode = ['1' binRandCode binTrialCode];
    
    
    %Setup the states for the bitcode
    for i = 1:Nbits
        bncstate = (binCode(i)=='1')*2;  %2 because BNC channel 2
        sma = AddState(sma, 'Name', ['bit' num2str(i)], 'Timer', bitparams.bitTime,...
            'StateChangeConditions', {'Tup', ['interbit' num2str(i)]},...
            'OutputActions', {'BNCState', bncstate});
        
        if i<Nbits
            sma = AddState(sma, 'Name', ['interbit' num2str(i)], 'Timer', bitparams.interBitTime,...
                'StateChangeConditions', {'Tup', ['bit' num2str(i+1)]},...
                'OutputActions', {'BNCState', 0});
        end
    end
    
    sma = AddState(sma, 'Name', ['interbit' num2str(Nbits)], 'Timer', bitparams.interBitTime,...
        'StateChangeConditions', {'Tup', 'InitialState'},...
        'OutputActions', {'BNCState', 0});
else
    
    sma = AddState(sma, 'Name', 'bit1', 'Timer', 0.1,...
        'StateChangeConditions', {'Tup', 'InitialState'},...
        'OutputActions', []);
end



% if ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Box'))
%     
% 
%     
% elseif ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Rig'))
% 
% end

