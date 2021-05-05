function [sma, params] = getSpontaneousLickStateMatrix(params, outputs, actions, TrialNum)
global S 

%bitcode params
params.bit.Ntrial = 12;
params.bit.Nrand = 12;
params.bit.bitTime = 0.005;
params.bit.interBitTime = 0.005;
params.bit.randNum = rand(1)*(2^params.bit.Nrand);



sma = NewStateMatrix(); % Assemble state matrix

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


sma = addBitcodeStates(sma, params.bit, TrialNum);

if S.GUI.CueType==1 % 'Water Drop'
    
    waitTime=rand;
    sma = AddState(sma, 'Name', 'WaitPeriod', 'Timer', waitTime,...
        'StateChangeConditions', {'Port1In', 'WaitPeriodReturn', 'Port2In', 'WaitPeriodReturn','Tup','ResponsePeriod'},...
        'OutputActions', []); % wait before water delivered
    sma = AddState(sma, 'Name', 'WaitPeriodReturn', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup','WaitPeriod'},...
        'OutputActions', []); % if lick during wait period, restart wait period
    
    % determine output from trial selection
    
    
    sma = AddState(sma, 'Name', 'Reward', 'Timer', S.GUI.WaterValveTime,...
        'StateChangeConditions', {'Tup', 'RewardConsumption'},...
        'OutputActions', outputs.RewardOutput); % turn on water
    sma = AddState(sma, 'Name', 'RewardConsumption', 'Timer', S.GUI.ConsumptionPeriod,...
        'StateChangeConditions', {'Tup', 'StopLicking'},...
        'OutputActions', []); % reward consumption
    
    sma = AddState(sma, 'Name', 'StopLicking', 'Timer', S.GUI.StopLickingPeriod,...
        'StateChangeConditions', {'Port1In', 'StopLickingReturn','Port2In', 'StopLickingReturn','Tup', 'TrialEnd'},...
        'OutputActions', []); % stop licking before advancing to next trial
    sma = AddState(sma, 'Name', 'StopLickingReturn', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'StopLicking'},...
        'OutputActions',[]); % return to stop licking
    
    sma = AddState(sma, 'Name', 'TrialEnd', 'Timer', 0.5,...
        'StateChangeConditions', {'Tup', 'exit'},'OutputActions', []); % pole up and trial end
    
elseif S.GUI.CueType==2
    
    T=rand;
    sma = AddState(sma, 'Name', 'WaitPeriod', 'Timer', T,...
        'StateChangeConditions', {'Port1In', 'WaitPeriodReturn', 'Port2In', 'WaitPeriodReturn','Tup','ResponsePeriod'},...
        'OutputActions', []); % wait before response allowed
    sma = AddState(sma, 'Name', 'WaitPeriodReturn', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup','WaitPeriod'},...
        'OutputActions', []); % if lick during wait period, restart wait period
    
    sma = AddState(sma, 'Name', 'ResponsePeriod', 'Timer', S.GUI.AnswerPeriod,...
        'StateChangeConditions', {'Port1In', LeftLickAction, 'Port2In', RightLickAction,'Tup','ResponsePeriodReturn'},...
        'OutputActions', []);% wait for lick
    sma = AddState(sma, 'Name', 'ResponsePeriodReturn', 'Timer', 0.01,...
        'StateChangeConditions', {'Port1In', LeftLickAction, 'Port2In', RightLickAction,'Tup','ResponsePeriod'},...
        'OutputActions', []);% if no lick, return to wait for lick
    
    sma = AddState(sma, 'Name', 'Reward', 'Timer', S.GUI.WaterValveTime,...
        'StateChangeConditions', {'Tup', 'RewardConsumption'},...
        'OutputActions', RewardOutput); % turn on water
    sma = AddState(sma, 'Name', 'RewardConsumption', 'Timer', S.GUI.ConsumptionPeriod,...
        'StateChangeConditions', {'Tup', 'StopLicking'},...
        'OutputActions', []); % reward consumption
    
    sma = AddState(sma, 'Name', 'StopLicking', 'Timer', S.GUI.StopLickingPeriod,...
        'StateChangeConditions', {'Port1In', 'StopLickingReturn','Port2In', 'StopLickingReturn','Tup', 'TrialEnd'},...
        'OutputActions', []); % stop licking before advancing to next trial
    sma = AddState(sma, 'Name', 'StopLickingReturn', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'StopLicking'},...
        'OutputActions',[]); % return to stop licking
    
    sma = AddState(sma, 'Name', 'TrialEnd', 'Timer', 0.5,...
        'StateChangeConditions', {'Tup', 'exit'},'OutputActions', []); % pole up and trial end
    
elseif S.GUI.CueType==3
end


if S.GUI.ProtocolType==3 % enforce delay and sample
    sma = AddState(sma, 'Name', 'SamplePeriod', 'Timer', S.GUI.SamplePeriod,...
        'StateChangeConditions', {'Port1In','EarlyLickSample','Port2In','EarlyLickSample','Tup', 'DelayPeriod'},...
        'OutputActions', outputs.SoundOutput);
    sma = AddState(sma, 'Name', 'EarlyLickSample', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'EarlyLickSampleReturn'},...
        'OutputActions', []); % if lick during sample, time out for duration of sample period
    sma = AddState(sma, 'Name', 'EarlyLickSampleReturn', 'Timer',S.GUI.SamplePeriod,...
        'StateChangeConditions', {'Port1In','EarlyLickSample','Port2In','EarlyLickSample','Tup', 'DelayPeriod'},...
        'OutputActions', []); % send to delay period
    sma = AddState(sma, 'Name', 'DelayPeriod', 'Timer', S.GUI.DelayPeriod,...
        'StateChangeConditions', {'Port1In','EarlyLickDelay','Port2In','EarlyLickDelay','Tup', 'GoCue'},...
        'OutputActions', []); % if lick during delay, restart delay
    sma = AddState(sma, 'Name', 'EarlyLickDelay', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'DelayPeriod'},...
        'OutputActions', []); % if lick during delay, restart delay
    
elseif S.GUI.ProtocolType==2 % enforce sample
    sma = AddState(sma, 'Name', 'SamplePeriod', 'Timer', S.GUI.SamplePeriod,...
        'StateChangeConditions', {'Port1In','EarlyLickSample','Port2In','EarlyLickSample','Tup', 'GoCue'},...
        'OutputActions', outputs.SoundOutput); % stimulus
    sma = AddState(sma, 'Name', 'EarlyLickSample', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'EarlyLickSampleReturn'},...
        'OutputActions', []); % if lick during sample, restart sample
    sma = AddState(sma, 'Name', 'EarlyLickSampleReturn', 'Timer',S.GUI.SamplePeriod,...
        'StateChangeConditions', {'Port1In','EarlyLickSample','Port2In','EarlyLickSample','Tup', 'GoCue'},...
        'OutputActions', []); % send to delay period
    
elseif S.GUI.ProtocolType==1 % no early lick punishment
    sma = AddState(sma, 'Name', 'SamplePeriod', 'Timer', S.GUI.SamplePeriod,...
        'StateChangeConditions', {'Tup', 'GoCue'},...
        'OutputActions', outputs.SoundOutput); % stimulus
end

sma = AddState(sma, 'Name', 'GoCue', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', actions.ActionAfterCue},...
    'OutputActions', outputs.CueOutput); % answer or free reward

for i = 1:params.Nlicks
    sma = AddState(sma, 'Name', ['WaitForLick' num2str(i)], 'Timer', S.GUI.AnswerPeriod,...
        'StateChangeConditions', {'Port1In', actions.LeftLickAction{i}, 'Port2In', actions.RightLickAction{i}, 'Tup', 'NoResponse'},...
        'OutputActions', []); % wait for response
end

sma = AddState(sma, 'Name', 'GiveLeftDropShort', 'Timer', S.GUI.WaterValveTime*S.GUI.AutoWaterScale,...
    'StateChangeConditions', {'Tup', 'WaitForLick1'},...
    'OutputActions', outputs.LeftWaterOutput); % free reward left
sma = AddState(sma, 'Name', 'GiveRightDropShort', 'Timer', S.GUI.WaterValveTime*S.GUI.AutoWaterScale,...
    'StateChangeConditions', {'Tup', 'WaitForLick1'},...
    'OutputActions', outputs.RightWaterOutput); % free reward right
% answer period changed to 'WaitForLick1'
sma = AddState(sma, 'Name', 'Reward', 'Timer', S.GUI.WaterValveTime,...
    'StateChangeConditions', {'Tup', 'RewardConsumption'},...
    'OutputActions', outputs.RewardOutput); % turn on water
sma = AddState(sma, 'Name', 'RewardConsumption', 'Timer', S.GUI.ConsumptionPeriod,...
    'StateChangeConditions', {'Tup', 'StopLicking'},...
    'OutputActions', []); % reward consumption
sma = AddState(sma, 'Name', 'NoResponse', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'StopLicking'},...
    'OutputActions',[]); % no response
sma = AddState(sma, 'Name', 'TimeOut', 'Timer', S.GUI.TimeOut,...
    'StateChangeConditions', {'Tup', 'StopLicking'},...
    'OutputActions', []);%{'WavePlayer1',4});% incorrect response
sma = AddState(sma, 'Name', 'StopLicking', 'Timer', S.GUI.StopLickingPeriod,...
    'StateChangeConditions', {'Port1In', 'StopLickingReturn','Port2In', 'StopLickingReturn','Tup', 'TrialEnd'},...
    'OutputActions', []); % stop licking before advancing to next trial
sma = AddState(sma, 'Name', 'StopLickingReturn', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'StopLicking'},...
    'OutputActions',[]); % return to stop licking
sma = AddState(sma, 'Name', 'TrialEnd', 'Timer', 0.5,...
    'StateChangeConditions', {'Tup', 'exit'},...
    'OutputActions', {'GlobalTimerCancel', 1, 'GlobalTimerCancel', 2}); % pole up and trial end





function sma = addBitcodeStates(sma, bitparam, TrialNum)
global S

locationNum = S.GUI.Location;

if ~isempty(strfind(S.GUIMeta.Location.String{locationNum}, 'Box'))
    
    sma = AddState(sma, 'Name', 'bit1', 'Timer', 0.1,...
        'StateChangeConditions', {'Tup', 'WaitPeriod'},...
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
        'StateChangeConditions', {'Tup', 'WaitPeriod'},...
        'OutputActions', {'BNCState', 0});
end

