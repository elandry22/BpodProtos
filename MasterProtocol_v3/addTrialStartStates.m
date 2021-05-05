function sma = addTrialStartStates(sma, bitparams, TrialNum)
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
        SGLxTriggerOutput = {'GlobalTimerTrig',1};
    end
    
    if S.GUI.CameraTrigger
        CameraTriggerOutput = {'GlobalTimerTrig',2};
    end
    
    if S.GUI.MaskingFlash
%         MaskingFlashTriggerOutput = {'GlobalTimerTrig',3};
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

sma = addBitcodeStates(sma, bitparams, TrialNum);



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

