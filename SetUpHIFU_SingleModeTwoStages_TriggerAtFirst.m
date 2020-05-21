function [TW,TX,SeqControl,Event] = SetUpHIFU_SingleModeTwoStages_TriggerAtFirst(P,Trans)
% %User defined parameters
% %Stage 1
% P.prf1 = 200;% initial treament PRF in Hz;
% P.pd1 = 0.3; % initial burst duration in msec, ON time;
% P.bnum1 = 100; %initial burst number
% %Stage 2
% P.prf2 = 200;% initial treament PRF in Hz;
% P.pd2 = 0.3; % initial burst duration in msec, ON time;
% P.bnum2 = 15; %initial burst number including long off time
% P.bnum3 = 15; %initial burst number before long off time
% P.offTime = 400; % initial long off time in msec;
%
% P.mode = Readdata; %choose the treament mode
% P.filename = 'HIFU-SingleModeTwoStages';
%
% %System parameters
% Resource.Parameters.numTransmit = 256;      % number of transmit channels.
% Resource.Parameters.numRcvChannels = 256;   % number of receive channels.
% Resource.Parameters.Connector = 2;
% Resource.Parameters.verbose = 2;
% Resource.Parameters.initializeOnly = 0;
% Resource.Parameters.simulateMode = 0;
%
% % HIFU % The Resource.HIFU.externalHifuPwr parameter must be specified in a
% % script using TPC Profile 5 with the HIFU option, to inform the system
% % that the script intends to use the external power supply.  This is also
% % to make sure that the script was explicitly written by the user for this
% % purpose, and to prevent a script intended only for an Extended Transmit
% % system from accidentally being used on the HIFU system.
% Resource.HIFU.externalHifuPwr = 1;
%
% % HIFU % The string value assigned to the variable below is used to set the
% % port ID for the virtual serial port used to control the external HIFU
% % power supply.  The port ID was assigned by the Windows OS when it
% % installed the SW driver for the power supply; the value assigned here may
% % have to be modified to match.  To find the value to use, open the Windows
% % Device Manager and select the serial/ COM port heading.  If you have
% % installed the driver for the external power supply, and it is connected
% % to the host computer and turned on, you should see it listed along with
% % the COM port ID number assigned to it.
% Resource.HIFU.extPwrComPortID = 'COM4';
%
% % HIFU % The system now supports two different commercial power supplies
% % for HIFU: the AIM-TTI model QPX600DP and the Sorensen model XG40-38.
% % These power supplies use different command formats for remote control
% % through the USB-based virtual serial port, and so the power supply
% % control funtion must be told which supply is present.  This is done in
% % the setup script through the field Resource.HIFU.psType, which must be
% % set to a string value of either 'QPX600DP' or 'XG40-38'.  If this field
% % is not specified, a default value of 'QPX600DP' will be used.
% Resource.HIFU.psType = 'QPX600DP'; % set to 'QPX600DP' or 'XG40-38' to match supply being used
%
% % Specify Transducer infomation by using external M-file
% TransducerInfo

% HIFU transmit

% define transmit waveform and duration
TW(1).type = 'parametric';
TW(1).Parameters = [Trans.frequency,.67,2*P.pd1*Trans.frequency,1];

TW(2).type = 'parametric';
TW(2).Parameters = [Trans.frequency,.67,2*P.pd2*Trans.frequency,1];

% Define TX
% Normalize UA for apodization
P.mode1.UAmax = max(abs(P.mode1.UA));
P.mode1.UAnorm = P.mode1.UA/P.mode1.UAmax;
P.mode1.UPHnorm = P.mode1.UPH/(2*pi);

TX(1).waveform = 1;            % use 1st TW structure.
TX(1).Origin = [0.0,0.0,0.0];  % flash transmit origin at (0,0,0).
TX(1).Apod = P.mode1.UAnorm;
TX(1).Apod([2,3,4,9,10,11,13,56,65,67,108,126,127,128,208]) = 0;
TX(1).Delay = P.mode1.UPHnorm;

TX(2) = TX(1);
TX(2).waveform = 2;

% Sequence control
SeqControl(1).command = 'setTPCProfile';
SeqControl(1).argument = 5;
SeqControl(1).condition = 'immediate';
SeqControl(2).command = 'timeToNextEB';
SeqControl(2).argument = 1/P.prf1*1e6;
SeqControl(3).command = 'timeToNextEB';
SeqControl(3).argument = 1/P.prf2*1e6;
SeqControl(4).command = 'noop';
SeqControl(4).argument = P.OffTime*1e3/0.2; % 0.2 us per unit
SeqControl(5).command = 'returnToMatlab';
SeqControl(6).command = 'loopCnt';
SeqControl(6).argument = P.bnum1;
SeqControl(7).command = 'loopCnt';
SeqControl(7).argument = P.bnum2;
SeqControl(8).command = 'sync';
SeqControl(8).argument = 2000e6; % 2000s
SeqControl(9).command = 'noop';
SeqControl(9).argument = 100*1000/0.2; % 0.2 us per unit
SeqControl(10).command = 'triggerOut';
SeqControl(10).argument = 0; % zero delay 

nsc = 11; % nsc is count of SeqControl objects + 1
n = 1; % n is count of Events

% initial TPC profile 5 for HIFU transmit
Event(n).info = 'select TPC profile';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = 1;
n = n+1;

%initial TPC profile 5 for HIFU transmit
Event(n).info = 'noop';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = 9;
n = n+1;

%Send out a trigger singal
Event(n).info = 'triggerOut';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = 10;
n = n+1;

% ===== stage 1 =====
Event(n).info = 'Set loop count for number of rep for stage 1.';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = 6;
n = n+1;

Event(n).info = 'Jump to end of accumulate events for loop count test.';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = nsc;
SeqControl(nsc).command = 'jump';  % Argument set below.
nsc = nsc + 1;
n = n+1;

nstart = n;
Event(n).info = 'Accumulate acquisition';
Event(n).tx = 1;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = [2,5];
n = n+1;

SeqControl(nsc-1).argument = n;
Event(n).info = 'Test loop count - if nz, jmp back to start of accumulates.';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = nsc;
SeqControl(nsc).command = 'loopTst';
SeqControl(nsc).argument = nstart;
nsc = nsc + 1;
n = n+1;
% ===== stage 1 =====

% 
% ===== stage 2 =====
for i = 1:P.bnum3
    Event(n).info = 'Set loop count for number of rep for stage 2.';
    Event(n).tx = 0;
    Event(n).rcv = 0;
    Event(n).recon = 0;
    Event(n).process = 0;
    Event(n).seqControl = 7;
    n = n+1;
    
    Event(n).info = 'Jump to end of accumulate events for loop count test.';
    Event(n).tx = 0;
    Event(n).rcv = 0;
    Event(n).recon = 0;
    Event(n).process = 0;
    Event(n).seqControl = nsc;
    SeqControl(nsc).command = 'jump';  % Argument set below.
    nsc = nsc + 1;
    n = n+1;
    
    nstart = n;
    Event(n).info = 'Accumulate acquisition';
    Event(n).tx = 2;
    Event(n).rcv = 0;
    Event(n).recon = 0;
    Event(n).process = 0;
    Event(n).seqControl = [3,5];
    n = n+1;
    
    SeqControl(nsc-1).argument = n;
    Event(n).info = 'Test loop count - if nz, jmp back to start of accumulates.';
    Event(n).tx = 0;
    Event(n).rcv = 0;
    Event(n).recon = 0;
    Event(n).process = 0;
    Event(n).seqControl = nsc;
    SeqControl(nsc).command = 'loopTst';
    SeqControl(nsc).argument = nstart;
    nsc = nsc + 1;
    n = n+1;
    
    Event(n).info = 'noop to set rest time';
    Event(n).tx = 0;
    Event(n).rcv = 0;
    Event(n).recon = 0;
    Event(n).process = 0;
    Event(n).seqControl = 4;
    n = n+1;
    
end
% ===== stage 2 =====


Event(n).info = 'sync'; % make sure the HW seqencer won't get killed by completion of SW sequencer
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = 8;
n = n+1;

end

