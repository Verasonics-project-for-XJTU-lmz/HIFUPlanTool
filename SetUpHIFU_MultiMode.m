function [TW,TX,SeqControl,Event] = SetUpHIFU_MultiMode(P, Trans)
% %User defined parameters
% P.TotalMode = 3;
% %Mode 1
% P.prf1(1) = 200;% initial treament PRF in Hz;
% P.pd1(1) = 0.3; % initial burst duration in msec, ON time;
% P.bnum(1) = 100; %initial burst number
% %Mode 2
% P.prf1(2) = 200;% initial treament PRF in Hz;
% P.pd1(2) = 0.3; % initial burst duration in msec, ON time;
% P.bnum1(2) = 15; %initial burst number;
% %Mode 3
% P.prf1(3) = 200;% initial treament PRF in Hz;
% P.pd1(3) = 0.3; % initial burst duration in msec, ON time;
% P.bnum1(3) = 15; %initial burst number;
%
%
% P.offTime = 400; % initial long off time in msec;
%
% P.filename = 'HIFU-MultiMode';
% %
% % % Read in Mode data
% % Index = P.TotalMode;
% % while Index > 0
% %     TempModa = Readdata;
% %     if isempty(TempModa)
% %         if ~exist ('P.mode1', 'var')
% %             error('No mode selected');
% %         else
% %             printf('No mode selected');
% %         end
% %     else
% %         eval(['P.mode',num2str(P.TotalMode-Index+1),'= TempModa;']);
% %         Index = Index-1;
% %     end
% % end
% %
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
% HIFU transmit
for i = 1:P.TotalMode
    % define transmit waveform and duration
    TW(i).type = 'parametric';
    TW(i).Parameters = [Trans.frequency,.67,2*P.pd1(i)*Trans.frequency,1];
    % Define TX
    % Normalize UA for apodization
    eval(['P.mode',num2str(i),'.UAmax = max(abs(P.mode',num2str(i),'.UA));']);
    eval(['P.mode',num2str(i),'.UAnorm = P.mode',num2str(i),'.UA/P.mode',num2str(i),'.UAmax;']);
    eval(['P.mode',num2str(i),'.UPHnorm = P.mode',num2str(i),'.UPH/(2*pi);']);
    TX(i).waveform = i;
    TX(i).Origin = [0.0,0.0,0.0];  % flash transmit origin at (0,0,0).
    eval(['TX(i).Apod = P.mode',num2str(i),'.UAnorm;']);    
    TX(i).Apod([2,3,4,9,10,11,13,56,65,67,108,126,127,128,208]) = 0;
    eval(['TX(i).Delay = P.mode',num2str(i),'.UPHnorm;']);
end


% Sequence control
SeqControl(1).command = 'setTPCProfile';
SeqControl(1).argument = 5;
SeqControl(1).condition = 'immediate';
SeqControl(2).command = 'returnToMatlab';
SeqControl(3).command = 'noop';
SeqControl(3).argument = P.OffTime*1e3/0.2; % 0.2 ns per unit
SeqControl(4).command = 'sync';
SeqControl(4).argument = 2000e6; % 2000s
SeqControl(5).command = 'noop';
SeqControl(5).argument = 100*1000/0.2; % 0.2 us per unit
nsc = 6;
nsc1 = nsc-1;

for i = 1:P.TotalMode
    SeqControl(i+nsc1).command = 'timeToNextEB';
    SeqControl(i+nsc1).argument = 1/P.prf1(i)*1e6;
    nsc = nsc+1;
end

for i = 1:P.TotalMode
    SeqControl(i+nsc1+P.TotalMode).command = 'loopCnt';
    SeqControl(i+nsc1+P.TotalMode).argument = P.bnum1(i);
    nsc = nsc+1;
end

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
Event(n).seqControl = 5;
n = n+1;

for k = 1:P.bnum2(1)
    for i = 1:P.TotalMode
        
        % ===== stage 1 =====
        Event(n).info = 'Set loop count for number of rep for stage 2.';
        Event(n).tx = 0;
        Event(n).rcv = 0;
        Event(n).recon = 0;
        Event(n).process = 0;
        Event(n).seqControl = i+nsc1+P.TotalMode;
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
        Event(n).tx = i;
        Event(n).rcv = 0;
        Event(n).recon = 0;
        Event(n).process = 0;
        Event(n).seqControl = [i+nsc1,2];
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
    end
    Event(n).info = 'noop to set rest time';
    Event(n).tx = 0;
    Event(n).rcv = 0;
    Event(n).recon = 0;
    Event(n).process = 0;
    Event(n).seqControl = 3;
    n = n+1;
end

Event(n).info = 'sync'; % make sure the HW seqencer won't get killed by completion of SW sequencer
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = 4;
n = n+1;

end

