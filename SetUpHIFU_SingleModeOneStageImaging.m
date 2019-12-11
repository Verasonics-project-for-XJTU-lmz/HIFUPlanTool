clear all
%User defined parameters
P.prf1(1) = 100; % initial treament PRF in Hz;
P.pd1(1) = 400; % initial burst duration in us, ON time;
P.bnum1 = 1000; % initial burst number to treat  for one stage;
P.mode = Readdata; %choose the treament mode

P.startDepth = 0;
P.endDepth = 100;   % Acquisition depth in wavelengths

P.numFrames = 10;
P.HIFUElSel = 129:256;

Resource.Parameters.numTransmit = 256;      % number of transmit channels.
Resource.Parameters.numRcvChannels = 256;   % number of receive channels.
Resource.Parameters.simulateMode = 0;
% ***Dual Xdcr*** We must explicitly specify a connector
% value of zero, to inform the system that both connectors will be used to
% support an overall "transducer" with 256 elements
Resource.Parameters.Connector = [1,2];
% ***Dual Xdcr*** Also set the 'fakeScanhead' parameter, to allow this
% script to run on the HW system with no transducer actually connected and
% avoid confusion when the two distinct transducers are present.
Resource.Parameters.fakeScanhead = 1;
% HIFU % The Resource.HIFU.externalHifuPwr parameter must be specified in a
% script using TPC Profile 5 with the HIFU option, to inform the system
% that the script intends to use the external power supply.  This is also
% to make sure that the script was explicitly written by the user for this
% purpose, and to prevent a script intended only for an Extended Transmit
% system from accidentally being used on the HIFU system.
Resource.HIFU.externalHifuPwr = 1;

% HIFU % The string value assigned to the variable below is used to set the
% port ID for the virtual serial port used to control the external HIFU
% power supply.  The port ID was assigned by the Windows OS when it
% installed the SW driver for the power supply; the value assigned here may
% have to be modified to match.  To find the value to use, open the Windows
% Device Manager and select the serial/ COM port heading.  If you have
% installed the driver for the external power supply, and it is connected
% to the host computer and turned on, you should see it listed along with
% the COM port ID number assigned to it.
Resource.HIFU.extPwrComPortID = 'COM3'; 

% HIFU % The system now supports two different commercial power supplies
% for HIFU: the AIM-TTI model QPX600DP and the Sorensen model XG40-38.
% These power supplies use different command formats for remote control
% through the USB-based virtual serial port, and so the power supply
% control funtion must be told which supply is present.  This is done in
% the setup script through the field Resource.HIFU.psType, which must be
% set to a string value of either 'QPX600DP' or 'XG40-38'.  If this field
% is not specified, a default value of 'QPX600DP' will be used.
Resource.HIFU.psType = 'QPX600DP'; % set to 'QPX600DP' or 'XG40-38' to match supply being used% 

% Specify Trans structure array.
% ***Dual Xdcr*** First we will use computeTrans to define two separate
% TransL7 and TransP6 structures, and then we will use parameters from
% both of those to create the shared Trans structure that will actually be
% used by the script.

% ***Dual Xdcr*** Create the TransP4 structure
TransP4.name = 'L11-4v';           
TransP4.units = 'mm';
TransP4 = computeTrans(TransP4); 
TransP4.ElementPos(:,5) = zeros(TransP4.numelements,1);

% ***Dual Xdcr*** Create HIFU structure
TransHIFU = TransducerInfo;
TransHIFU.ElementPos = TransHIFU.ElementPos(P.HIFUElSel,:);

% ***Dual Xdcr*** Now use TransL7 and TransP6 to create the shared Trans structure ***
Trans.name = 'custom';      % Must be 'custom' to prevent confusion from the two unique transducer ID's that will actually be connected
Trans.id = hex2dec('0000'); % Dummy ID to be used with the 'fake scanhead' feature
Trans.units = 'mm';
Trans.frequency = TransP4.frequency;      % ***Dual Xdcr*** This is the shared frequency 
Trans.Bandwidth = TransP4.Bandwidth;
Trans.type = 0;            
Trans.numelements = 256;    % total over both connectors
% Concatenate the two element position arrays
Trans.ElementPos = [TransHIFU.ElementPos; TransP4.ElementPos];
% For the following parameters just copy the P4 values for the first
% image processing
Trans.lensCorrection = TransP4.lensCorrection;
Trans.spacing = TransP4.spacing;
Trans.elementWidth = TransP4.elementWidth;
Trans.ElementSens = TransP4.ElementSens;
% For the following use an appropriate shared value
Trans.impedance = 50;
Trans.maxHighVoltage = 50;  % set maximum high voltage limit for pulser supply.

for i=1:Trans.numelements, Labels{i}=num2str(i); end
figure
plot3(Trans.ElementPos(:,1), Trans.ElementPos(:,2), Trans.ElementPos(:,3), 'w.');axis equal; % plot element positions
hold on;
text(Trans.ElementPos(:,1), Trans.ElementPos(:,2), Trans.ElementPos(:,3), Labels,'HorizontalAlignment','center','FontSize',12);
xlim([min(Trans.ElementPos(:,1))-1 max(Trans.ElementPos(:,1))+1]);
ylim([min(Trans.ElementPos(:,2))-1 max(Trans.ElementPos(:,2))+1]);
zlim([min(Trans.ElementPos(:,3))-1 max(Trans.ElementPos(:,3))+1]);
zlabel('unit: mm' );

% % Set up PData structure for Imaging probe
% P.theta = -pi/4;
% P.rayDelta = 2*(-P.theta);
% P.aperture = TransP4.numelements*Trans.spacing; 
% P.radius = (P.aperture/2)/tan(-P.theta); % dist. to virt. apex
% PData(1).PDelta = [0.5, 0, 0.5];
% PData(1).Size(1) = 10 + ceil((P.endDepth-P.startDepth)/PData(1).PDelta(3));
% PData(1).Size(2) = 10 + ceil(2*(P.endDepth + P.radius)*sin(-P.theta)/PData(1).PDelta(1));
% PData(1).Size(3) = 1;
% PData(1).Origin = [-(PData(1).Size(2)/2)*PData(1).PDelta(1),0,P.startDepth];
% PData(1).Region = struct(...
%             'Shape',struct('Name','SectorFT', ...
%             'Position',[0,0,-P.radius], ...
%             'z',P.startDepth, ...
%             'r',P.radius+P.endDepth, ...
%             'angle',P.rayDelta, ...
%             'steer',0));
% PData(1).Region = computeRegions(PData(1));
% Specify PData structure array.
PData(1).PDelta = [Trans.spacing, 0, 0.5];
PData(1).Size(1) = ceil((P.endDepth-P.startDepth)/PData(1).PDelta(3)); % startDepth, endDepth and pdelta set PData(1).Size.
PData(1).Size(2) = ceil((128*Trans.spacing)/PData(1).PDelta(1));
PData(1).Size(3) = 1;      % single image page
PData(1).Origin = [-Trans.spacing*(128-1)/2,0,P.startDepth]; % x,y,z of upper lft crnr.
% No PData.Region specified, so a default Region for the entire PData array will be created by computeRegions.

% Specify Media object.
pt1;
Media.attenuation = -0.5;
Media.function = 'movePoints';

% Specify Resources.
%=====b-mode======
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = 2*4096; 
Resource.RcvBuffer(1).colsPerFrame = Resource.Parameters.numRcvChannels;
Resource.RcvBuffer(1).numFrames = P.numFrames; 
Resource.InterBuffer(1).numFrames = 1;  % one intermediate buffer needed.
Resource.ImageBuffer(1).numFrames = 10;
Resource.DisplayWindow(1).Title = 'Imaging During On-Time';
Resource.DisplayWindow(1).pdelta = 0.35;
ScrnSize = get(0,'ScreenSize');
DwWidth = ceil(PData(1).Size(2)*PData(1).PDelta(1)/Resource.DisplayWindow(1).pdelta);
DwHeight = ceil(PData(1).Size(1)*PData(1).PDelta(3)/Resource.DisplayWindow(1).pdelta);
Resource.DisplayWindow(1).Position = [50,(ScrnSize(4)-(DwHeight+150))/2, ...  % lower left corner position
                                      DwWidth, DwHeight];
Resource.DisplayWindow(1).ReferencePt = [PData(1).Origin(1),0,PData(1).Origin(3)];   % 2D imaging is in the X,Z plane                                 
Resource.DisplayWindow(1).Type = 'Verasonics';                                 
Resource.DisplayWindow(1).numFrames = 20;
Resource.DisplayWindow(1).AxesUnits = 'mm';
Resource.DisplayWindow(1).Colormap = gray(256);
%=====passive detection======
Resource.RcvBuffer(2).datatype = 'int16';
Resource.RcvBuffer(2).rowsPerFrame = 1*4096; 
Resource.RcvBuffer(2).colsPerFrame = Resource.Parameters.numRcvChannels;
Resource.RcvBuffer(2).numFrames = P.numFrames; 
Resource.InterBuffer(2).numFrames = 1;  % one intermediate buffer needed.
Resource.ImageBuffer(2).numFrames = 10;
Resource.DisplayWindow(2).Title = 'Imaging During Off-Time';
Resource.DisplayWindow(2).pdelta = 0.35;
DwWidth = ceil(PData(1).Size(2)*PData(1).PDelta(1)/Resource.DisplayWindow(2).pdelta);
DwHeight = ceil(PData(1).Size(1)*PData(1).PDelta(3)/Resource.DisplayWindow(2).pdelta);
Resource.DisplayWindow(2).Position = [600,200, DwWidth, DwHeight];
Resource.DisplayWindow(2).ReferencePt = [PData(1).Origin(1),0,PData(1).Origin(3)];   % 2D imaging is in the X,Z plane
Resource.DisplayWindow(2).Type = 'Verasonics';
Resource.DisplayWindow(2).numFrames = 20;
Resource.DisplayWindow(2).AxesUnits = 'mm';
Resource.DisplayWindow(2).Colormap = gray(256);

% Specify Transmit waveform structure. 
% HIFU transmit

% define transmit waveform and duration
TW(1).type = 'parametric';
TW(1).Parameters = [TransHIFU.frequency,.67,2*P.pd1(1)*TransHIFU.frequency,1];
TW(2).type = 'parametric';
TW(2).Parameters = [TransP4.frequency,.67,2,1]; 

% Define TX
% Normalize UA for apodization
P.mode.UAmax = max(P.mode.UA(P.HIFUElSel));
P.mode.UAnorm = P.mode.UA(P.HIFUElSel)/P.mode.UAmax;
P.mode.UPHnorm = P.mode.UPH(P.HIFUElSel)/(2*pi);

TX(1).waveform = 1;            % use 1st TW structure.
TX(1).Origin = [0.0,0.0,0.0];  % flash transmit origin at (0,0,0).
TX(1).Apod = [P.mode.UAnorm,zeros(1,128)];
TX(1).Delay = [P.mode.UPHnorm,zeros(1,128)];

TX(2).waveform = 2;
TX(2).Origin = [0,0,0];             % set origin to 0,0,0 for flat focus.
TX(2).focus = 0;  	% set focus to negative for concave TX.Delay profile.
TX(2).Steer = [0,0];
TX(2).Apod = [zeros(1,128), ones(1,128)]; % ***Dual Xdcr*** 4-2v uses channels 129:196
TX(2).Delay = computeTXDelays(TX(2));

% Specify TPC structures ... creates two TPC profiles and two HV control sliders.
TPC(5).name = 'HIFU';
TPC(5).maxHighVoltage = 50;

% Specify TGC Waveform structure for imaging
TGC(1).CntrlPts = [0,141,275,404,510,603,702,782];
TGC(1).rangeMax = P.endDepth;
TGC(1).Waveform = computeTGCWaveform(TGC(1));
TGC(2).CntrlPts = [0,141,275,404,510,603,702,782];
TGC(2).rangeMax = P.endDepth;
TGC(2).Waveform = computeTGCWaveform(TGC(2));
% Imaging.
% maxAcqLengthP4 = sqrt(P.aperture^2 + P.endDepth^2 - 2*P.aperture*P.endDepth*cos(P.theta-pi/2)) - P.startDepth;
maxAcqLengthP4 = ceil(sqrt(P.endDepth^2 + ((Trans.numelements-1)*Trans.spacing)^2));
wlsPer128 = 128/(4*2); % wavelengths in 128 samples for 4 samplesPerWave
Receive = repmat(struct('Apod', [zeros(1,128), ones(1,128)], ...
                        'startDepth', P.startDepth, ...
                        'endDepth', P.startDepth + wlsPer128*ceil(maxAcqLengthP4/wlsPer128), ...
                        'TGC', 1, ...
                        'bufnum', 1, ...
                        'framenum', 1, ...
                        'acqNum', 1, ...
                        'sampleMode', 'NS200BW', ...
                        'mode', 0, ...
                        'callMediaFunc', 1),1,2*Resource.RcvBuffer(1).numFrames); % ***Dual Xdcr*** two Receive sturctures per frame

 for i = 1:P.numFrames
    % Imaging during On-Time
    Receive(2*i-1).callMediaFunc = 0; % only move the media points once per frame
    Receive(2*i-1).framenum = i;
    Receive(2*i-1).TGC = 1;
    Receive(2*i-1).startDepth = 160/(1.54/Trans.frequency);
    Receive(2*i-1).endDepth = Receive(2*i-1).startDepth;
    
    % Imaging during Off-Time
    Receive(2*i).framenum = i; 
    Receive(2*i).acqNum = 2;
    Receive(2*i).TGC = 2;
 end                   
 
% Specify Recon structure for image during HIFU.
Recon(1) = struct('senscutoff', 0.5, ...
               'pdatanum', 1, ...
               'rcvBufFrame', -1, ...
               'ImgBufDest', [1,-1], ...
               'RINums', 1);

% Define ReconInfo structure for image during HIFU.
ReconInfo(1) = struct('mode', 'replaceIntensity', ...          % replace amplitude.
                   'txnum', 1, ...
                   'rcvnum', 1, ...
                   'regionnum',1);

% Specify Recon structure for image during off-time
% Copy Recon(1) and then modify values that are different
Recon(2) = Recon(1);
Recon(2).ImgBufDest = [2,-1];
Recon(2).RINums = 2;

% Define ReconInfo structure 
ReconInfo(2) = ReconInfo(1);
ReconInfo(2).txnum = 2;
ReconInfo(2).rcvnum = 2;

pers = 20;
Process(1).classname = 'Image';
Process(1).method = 'imageDisplay';
Process(1).Parameters = {'imgbufnum',1,...   % number of buffer to process.
                         'framenum',-1,...   % (-1 => lastFrame)
                         'pdatanum',1,...    % number of PData structure to use
                         'pgain',1.0,...            % pgain is image processing gain
                         'reject',2,...      % reject level 
                         'persistMethod','simple',...
                         'persistLevel',pers,...
                         'interpMethod','4pt',...  
                         'grainRemoval','none',...
                         'processMethod','none',...
                         'averageMethod','none',...
                         'compressMethod','power',...
                         'compressFactor',40,...
                         'mappingMethod','full',...
                         'display',1,...      % display image after processing
                         'displayWindow',1};
                     
Process(2).classname = 'Image';
Process(2).method = 'imageDisplay';
Process(2).Parameters = {'imgbufnum',2,...   % number of buffer to process.
                         'framenum',-1,...   % (-1 => lastFrame)
                         'pdatanum',1,...    % number of PData structure to use
                         'pgain',1.0,...            % pgain is image processing gain
                         'reject',2,...      % reject level 
                         'persistMethod','simple',...
                         'persistLevel',pers,...
                         'interpMethod','4pt',...  
                         'grainRemoval','none',...
                         'processMethod','none',...
                         'averageMethod','none',...
                         'compressMethod','power',...
                         'compressFactor',40,...
                         'mappingMethod','full',...
                         'display',1,...      % display image after processing
                         'displayWindow',2};
                    
% Sequence control
SeqControl(1).command = 'timeToNextEB';  % time between HIFU transmit
SeqControl(1).argument = 1/P.prf1(1)*1e6; 
SeqControl(2).command = 'timeToNextAcq'; 
SeqControl(2).argument = P.pd1(1)+ 2*Receive(1).endDepth/Trans.frequency; % time between imaging pulse
SeqControl(3).command = 'returnToMatlab';

nsc = 4; % nsc is count of SeqControl objects
n = 1; % n is count of Events

% initial TPC profile 5 for HIFU transmit
Event(n).info = 'select TPC profile';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = nsc; 
   SeqControl(nsc).command = 'setTPCProfile';
   SeqControl(nsc).argument = 5;
   SeqControl(nsc).condition = 'immediate';
   nsc = nsc + 1; 
n = n+1;

for i = 1:P.bnum1
    Event(n).info = 'HIFU pulse';
    Event(n).tx = 1;         
    Event(n).rcv = 1;        
    Event(n).recon = 0;      
    Event(n).process = 0;    
    Event(n).seqControl = [1,2]; 
    n = n+1;
       
    Event(n).info = 'Imaging Pulse';
    Event(n).tx = 2;         
    Event(n).rcv = 2;        
    Event(n).recon = 0;      
    Event(n).process = 0;    
    Event(n).seqControl = nsc;
        SeqControl(nsc).command = 'transferToHost';
        nsc = nsc + 1;
    n = n+1;
    
    Event(n).info = 'Reconstruct & display during on time'; 
    Event(n).tx = 0;         
    Event(n).rcv = 0;        
    Event(n).recon = 1;      
    Event(n).process = 1;    
    Event(n).seqControl = 0;
    n = n+1;
       
    Event(n).info = 'Reconstruct & display during off time'; 
    Event(n).tx = 0;         
    Event(n).rcv = 0;        
    Event(n).recon = 2;      
    Event(n).process = 2;    
    if floor(i/5) == i/5    % Exit to Matlab every 5th Frame;
        Event(n).seqControl = 3; 
    else
        Event(n).seqControl = 0;
    end
    n = n+1;
end

filename = 'HIFU-SingleModeOneStageImaging';
save(['MatFiles/',filename]);
VSX % run automatically