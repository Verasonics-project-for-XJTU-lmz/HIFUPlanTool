function Trans = TransducerInfo
Trans.name = 'HIFUcustom';
Trans.frequency = 1.1;
Trans.Bandwidth = [Trans.frequency * 0.9, Trans.frequency * 1.1];
Trans.type = 2;
Trans.units = 'mm';
Trans.numelements = 256;
Trans.elementWidth = 6.5;
Trans.spacingMm = 6.5;
Trans.radiusMm = 110;
Trans.impedance = 50;
% former Settings is 46 Ohm
Trans.maxHighVoltage = 50;
Trans.connType = -1;
Trans.ElementPos = zeros(Trans.numelements,5);
Temp.numRow = 19;
Temp.innerSize = 5; % element number of inner space length
Temp.RowPos = Trans.elementWidth* (-(Temp.numRow-1)/2:(Temp.numRow-1)/2);
Temp.elePerRow = [5,9,13,15,17,17,17,14,14,14,14,14,17,17,17,15,13,9,5];
Temp.Focus = [0 0 sqrt(Trans.radiusMm^2 - ((Temp.innerSize+1)/2*Trans.elementWidth)^2)];
for i = 1:Temp.numRow
    if i == 1
        Temp.ls = 1;
    else
        Temp.ls = sum(Temp.elePerRow(1:i-1))+1;
    end
    Temp.re = sum(Temp.elePerRow(1:i));
    Temp.ele = Temp.ls:Temp.re;
    if Temp.elePerRow(i) == 14
        Temp.index = Temp.elePerRow(i) + Temp.innerSize;
        Temp.dis = Trans.elementWidth*(-(Temp.index-1)/2:(Temp.index-1)/2);
        Temp.dis = Temp.dis([1:7,13:end]);
        Trans.ElementPos(Temp.ele,1) =  Temp.dis;
    else
        Trans.ElementPos(Temp.ele,1) = Trans.elementWidth*(-(Temp.elePerRow(i)-1)/2:(Temp.elePerRow(i)-1)/2);
    end
    Trans.ElementPos(Temp.ele,2) = Temp.RowPos(i);
    
    Temp.EleToZ = (Trans.ElementPos(Temp.ele,2).^2+Trans.ElementPos(Temp.ele,1).^2);
    Trans.ElementPos(Temp.ele,3) = Temp.Focus(3) - sqrt(Trans.radiusMm^2 - Temp.EleToZ);
    Temp.dX = Temp.Focus(1) - Trans.ElementPos(Temp.ele,1);
    Temp.dY = Temp.Focus(2) - Trans.ElementPos(Temp.ele,2);
    Temp.dZ = Temp.Focus(3) - Trans.ElementPos(Temp.ele,3);
    Trans.ElementPos(Temp.ele,4) = atan(Temp.dX./Temp.dZ);
    Trans.ElementPos(Temp.ele,5) = atan(Temp.dY./sqrt(Temp.dX.^2+Temp.dY.^2));
end

Temp.Theta = (-pi/2:pi/100:pi/2);
Temp.Theta(51) = 0.0000001; % set to almost zero to avoid divide by zero.
% note at this point elementWidth is in mm, so we have to
% convert to wavelengths for the ElementSens calculation
Temp.eleWidthWl = Trans.elementWidth * Trans.frequency / 1.54;
if Temp.eleWidthWl < 0.01
    % avoid the divide by zero for very small values (in this
    % case the sinc function will be extremely close to 1.0 for
    % all Theta, so we only need the cos term)
    Trans.ElementSens = abs(cos(Temp.Theta));
else
    Trans.ElementSens = abs(cos(Temp.Theta).*(sin(Temp.eleWidthWl*pi*sin(Temp.Theta))./(Temp.eleWidthWl*pi*sin(Temp.Theta))));
end


% Now convert all units as required, based on Trans.units
scaleToWvl = Trans.frequency/1.54; % conversion factor from mm to wavelengths
% regardless of units, always provide spacing in wavelengths
Trans.spacing = Trans.spacingMm * scaleToWvl;   % Spacing between elements in wavelengths

% Plot transducer element position
% for i=1:Trans.numelements, Labels{i}=num2str(i); end
% figure
% plot3(Trans.ElementPos(:,1), Trans.ElementPos(:,2), Trans.ElementPos(:,3), 'w.');axis equal; % plot element positions
% hold on;
% text(Trans.ElementPos(:,1), Trans.ElementPos(:,2), Trans.ElementPos(:,3), Labels,'HorizontalAlignment','center','FontSize',12);
% xlim([min(Trans.ElementPos(:,1))-1 max(Trans.ElementPos(:,1))+1]);
% ylim([min(Trans.ElementPos(:,2))-1 max(Trans.ElementPos(:,2))+1]);
% zlim([min(Trans.ElementPos(:,3))-1 max(Trans.ElementPos(:,3))+1]);
% zlabel('unit: mm' );

end