function [sma, bitParams] = getStateMatrix_optoTagging(TrialNum)
global S


sma = NewStateMatrix(); % Assemble state matrix

% set up timers for trial start and stimulation
% timer 1 = SpikeGLX trigger
% timer 2 = laser (& camera trigger)
sma = setTimers(sma); 

bitParams = setBitCodeParams();

sma = AddState(sma, 'Name', 'TrialStart', 'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'TrigSGLX'},...
    'OutputActions', []);

sma = AddState(sma, 'Name', 'TrigSGLX', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'bit1'},...
        'OutputActions', {'GlobalTimerTrig', 1});
    
% First state is 'bit1'
sma = addBitcodeStates(sma, bitParams, TrialNum);
% Goes to 'TrigWaveforms'

sma = AddState(sma, 'Name', 'TrigWaveforms', 'Timer', S.GUI.ProtoDur,...
        'StateChangeConditions', {'Tup', 'TrialEnd'},...
        'OutputActions', {'GlobalTimerTrig', 2});

sma = AddState(sma, 'Name', 'TrialEnd', 'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'GlobalTimerCancel', 1, 'GlobalTimerCancel', 2});


%% Helper functions

function sma = setTimers(sma)

global S

params.wav = S.wavParams;

% gets triggered in 'TrigSGLX' state
% puts SpikeGLX in mode to record input
% 120% of protocol duration to make sure SGLX is always recording
sma = SetGlobalTimer(sma, 'TimerID', 1, 'Duration', 1.2*S.GUI.ProtoDur, ...
    'OnsetDelay', 0, 'Channel', 'BNC1', 'OnsetValue', 1, 'OffsetValue', 0);

% wavIndex = params.wav.stim.num(1);

sma = SetGlobalTimer(sma, 'TimerID', 2, 'Duration', S.GUI.ProtoDur,...
    'OnsetDelay', 0, 'Channel', 'WavePlayer1', ...
    'OnMessage', params.wav.stim.num(1), 'OffMessage', 1,...
    'Loop', 0, 'SendGlobalTimerEvents', 1);


function bitparam = setBitCodeParams()
bitparam.Ntrial = 12; % num bins to use in bitcode
bitparam.Nrand = 12; % num bins to use in bitcode
bitparam.bitTime = 0.005;
bitparam.interBitTime = 0.005;
bitparam.randNum = floor(rand(1)*(2^bitparam.Nrand));


function sma = addBitcodeStates(sma, bitparams, TrialNum)

Nbits = bitparams.Nrand+bitparams.Ntrial+1;

decTrialCode = TrialNum;
decRandCode = bitparams.randNum;

binTrialCode = dec2bin(decTrialCode, bitparams.Ntrial);
binRandCode = dec2bin(decRandCode, bitparams.Nrand);
binCode = ['1' binRandCode binTrialCode]; % starts with 1 to know when bitcode starts


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
    'StateChangeConditions', {'Tup', 'TrigWaveforms'},...
    'OutputActions', {'BNCState', 0});
