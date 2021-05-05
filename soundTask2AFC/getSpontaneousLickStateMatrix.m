function [sma, params] = getSpontaneousLickStateMatrix(outputs, TrialNum, ITI)
global S 

locationNum = S.GUI.Location;

%bitcode params
params.bit.Ntrial = 12;
params.bit.Nrand = 12;
params.bit.bitTime = 0.005;
params.bit.interBitTime = 0.005;
params.bit.randNum = rand(1)*(2^params.bit.Nrand);

sma = NewStateMatrix(); % Assemble state matrix

sma = setTimers(sma);
sma = addBitcodeStates(sma, params.bit, TrialNum);


sma = AddState(sma, 'Name', 'GoCue', 'Timer', S.GUI.WaterValveTime,...
    'StateChangeConditions', {'Tup', 'AnswerPeriod'},...
    'OutputActions', outputs.CueOutput);
    
sma = AddState(sma, 'Name', 'AnswerPeriod', 'Timer', S.GUI.AnswerPeriod,...
    'StateChangeConditions', {'Port1In', 'LickedLeft','Port2In', 'LickedRight','Tup','NoResponse'},...% send them to stopLickingReturn? do we want them to lick at least once? should that be a parameter? or lick as many times as they want?
    'OutputActions', []); 

if isempty(outputs.LeftResponse) && isempty(outputs.RightResponse)
    sma = AddState(sma, 'Name', 'LickedLeft', 'Timer', S.GUI.WaterValveTime,...
        'StateChangeConditions', {'Tup', 'Reward'},...
        'OutputActions', []);
    sma = AddState(sma, 'Name', 'LickedRight', 'Timer', S.GUI.WaterValveTime,...
        'StateChangeConditions', {'Tup', 'Reward'},...
        'OutputActions', []);
    sma = AddState(sma, 'Name', 'Reward', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'StopLicking'},...
        'OutputActions', []);
else
    sma = AddState(sma, 'Name', 'LickedLeft', 'Timer', S.GUI.WaterValveTime,...
        'StateChangeConditions', {'Tup', 'Reward'},...
        'OutputActions', outputs.LeftResponse);
    sma = AddState(sma, 'Name', 'LickedRight', 'Timer', S.GUI.WaterValveTime,...
        'StateChangeConditions', {'Tup', 'Reward'},...
        'OutputActions', outputs.RightResponse);
    sma = AddState(sma, 'Name', 'Reward', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'StopLicking'},...
        'OutputActions', []);
end

% sma = AddState(sma, 'Name', 'Licked', 'Timer', S.GUI.WaterValveTime,...
%     'StateChangeConditions', {'Tup', 'StopLicking'},...
%     'OutputActions', outputs.Response);
% %
% %
% %

sma = AddState(sma, 'Name', 'StopLicking', 'Timer', S.GUI.StopLickingPeriod,...
    'StateChangeConditions', {'Port1In', 'StopLickingReturn','Port2In', 'StopLickingReturn','Tup','ITI'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'StopLickingReturn', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup','StopLicking'},...
    'OutputActions', []); % if lick during stop licking period, restart stop licking period

sma = AddState(sma, 'Name', 'NoResponse', 'Timer', 0.01,...
    'StateChangeConditionts', {'Tup', 'TrialEnd'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'ITI', 'Timer', ITI,...
    'StateChangeConditionts', {'Tup', 'TrialEnd'},...
    'OutputActions', []);

if ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Box'))
    
    sma = AddState(sma, 'Name', 'TrialEnd', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', []); % pole up and trial end
    
elseif ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Rig'))
    
    sma = AddState(sma, 'Name', 'TrialEnd', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'GlobalTimerCancel', 1, 'GlobalTimerCancel', 2}); % pole up and trial end
end

    


function sma = setTimers(sma)
global S

locationNum = S.GUI.Location;

if ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Box'))
    
    sma = AddState(sma, 'Name', 'TrigTrialStart', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'bit1'},...
        'OutputActions', []);
    
elseif ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Rig'))
    
    sma = SetGlobalTimer(sma, 'TimerID', 1, 'Duration', 60, ...
        'OnsetDelay', 0, 'Channel', 'BNC1', 'OnsetValue', 1, 'OffsetValue', 0);
    
    sma = SetGlobalTimer(sma, 'TimerID', 2, 'Duration', 60, 'OnsetDelay', 0, ...
        'Channel', 'WavePlayer1', 'OnMessage', 1, 'OffMessage', 2, ...
        'Loop', 1, 'SendGlobalTimerEvents', 0);
    
    sma = AddState(sma, 'Name', 'TrigTrialStart', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'TrigTrialStart2'},...
        'OutputActions', {'GlobalTimerTrig',1});
    
    sma = AddState(sma, 'Name', 'TrigTrialStart2', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'bit1'},...
        'OutputActions', {'GlobalTimerTrig',2});
end


function sma = addBitcodeStates(sma, bitparam, TrialNum)
global S

locationNum = S.GUI.Location;

if ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Box'))
    
    sma = AddState(sma, 'Name', 'bit1', 'Timer', 0.1,...
        'StateChangeConditions', {'Tup', 'GoCue'},...
        'OutputActions', []);
    
    
elseif ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Rig'))
    Nbits = bitparam.Nrand+bitparam.Ntrial+1; 
    
    decTrialCode = TrialNum;
    decRandCode = floor(bitparam.randNum);
    
    binTrialCode = dec2bin(decTrialCode, bitparam.Ntrial);
    binRandCode = dec2bin(decRandCode, bitparam.Nrand);
    binCode = ['1' binRandCode binTrialCode];
    
    
    %Setup the states for the bitcode
    for i = 1:Nbits
        bncstate = (binCode(i)=='1')*2;  %2 because BNC channel 2
        sma = AddState(sma, 'Name', ['bit' num2str(i)], 'Timer', bitparam.bitTime,...
            'StateChangeConditions', {'Tup', ['interbit' num2str(i)]},...
            'OutputActions', {'BNCState', bncstate});
        
        if i<Nbits
            sma = AddState(sma, 'Name', ['interbit' num2str(i)], 'Timer', bitparam.interBitTime,...
                'StateChangeConditions', {'Tup', ['bit' num2str(i+1)]},...
                'OutputActions', {'BNCState', 0});
        end
    end
    
    sma = AddState(sma, 'Name', ['interbit' num2str(Nbits)], 'Timer', bitparam.interBitTime,...
        'StateChangeConditions', {'Tup', 'GoCue'},...
        'OutputActions', {'BNCState', 0});
end

