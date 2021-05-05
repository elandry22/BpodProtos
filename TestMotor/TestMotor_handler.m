function TestMotor_handler(Byte)
global BpodSystem
% disp(Byte);

% s = serial('COM8','BaudRate',115200,'Terminator','CR');

ModuleName = BpodSystem.Modules.Name(2);
if Byte == 2
    Message = "/1 01 move rel 2000"; % up to 64 bytes
else
    Message = "/home"; % up to 64 bytes
end
% 
disp(Message)
Message = char(Message);
ModuleWrite(ModuleName, Message, 'char')

% fopen(s)
% fprintf(s,Message)
% fclose(s)

% For another example of a soft code handler, 
% see /Bpod/Examples/Protocols/PsychToolboxSound/SoftCodeHandler_PlaySound.m

