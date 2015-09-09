% script to read Microstrain IMU data and generate a binary Microstrain 
% file so it can be used in Inertial Explorer.
% The script will also output the required scale factors 

clear all;
close all;

imu = load('IMU_01.TXT');

%you might need to remove some data where the timestamps are not valid
%the following code attempts to do this automatically but might not
%work if, e.g. you dont have continuous GPS throughout the data collection
el = find(abs(diff(imu(1:floor(end/2),1)))>0.1,1, 'last');
if ( ~isempty(el) )
    imu = imu(el+1:end,:);
end
el = find(abs(diff(imu(floor(end/2):end,1)))>0.1,1, 'first');
el = el + floor(length(imu)/2);
if ( ~isempty(el) )
    imu = imu(1:el-1,:);
end

%correct for data logger bug where the timestamps are always wrong 
%by 1 second
imu(:,1)=imu(:,1)-1;

%timestamps from the Microstrain are rather inconsistent whereas the 
%sampling rate probably is consistent. Therefore we fit a line to 
%the times and use this instead
x      = 1:length(imu(:,1));
p      = polyfit(x',imu(:,1),1); %choose the polynomial order here
time_c = polyval(p,x');  %corrected time
% time_c = time_c - 0.005; %additional correction assuming time stamp error is random about the mean

fout = fopen('microstrain.bin','wb');
ftxt = fopen('microstrain.txt','w');

if ( fout < 0 )
    fprintf('Error opening output file');
    return;
end
if ( ftxt < 0 )
    fprintf('Error opening output file');
    return;
end

%compute reasonable scale factors
gyrosf = 1200 / 2147483647;
accelsf = 18 * 9.81 / 2147483647;
%?2147483648 to 2147483647

gyrosf=gyrosf;
accelsf=accelsf;

%these values you will need to enter in Inertial explorer using Convert IMU utility
%so we'll output to the screen
fprintf('Gyro scale factor: %.10f\n',1/gyrosf*2*2);       % An extra factor calcuated rougly on 24-03-13   
fprintf('Acce scale factor: %.10f\n',1/accelsf*100*100);    % An extra factor calcuated rougly on 24-03-13

%write the binary file and a text file containing the same information
for i=1:length(imu)
    time = double(time_c(i));
    fwrite(fout,time,'double');
    gx = int32(round(imu(i,2) / gyrosf));
    gy = int32(round(imu(i,3) / gyrosf));
    gz = int32(round(imu(i,4) / gyrosf));
    fwrite(fout,gx,'integer*4');
    fwrite(fout,gy,'integer*4');
    fwrite(fout,gz,'integer*4');
    ax = int32(round(imu(i,5) / accelsf));
    ay = int32(round(imu(i,6) / accelsf));
    az = int32(round(imu(i,7) / accelsf));
    fwrite(fout,ax,'integer*4');
    fwrite(fout,ay,'integer*4');
    fwrite(fout,az,'integer*4');
    
    fprintf(ftxt,'%.4f %.6f %.6f %.6f %.6f %.6f %.6f\n',imu(i,1),...
         imu(i,2),imu(i,3),imu(i,4),imu(i,5),imu(i,6),imu(i,7));
%     fprintf(ftxt,'%.4f %i %i %i %i %i %i\n',time,...
%         gx,gy,gz,ax,ay,az);
end

fclose(fout);
fclose(ftxt);

figure(1)
plot(imu(2:end,1),diff(imu(:,1)))
title(sprintf('Difference in time stamps - check this plot for time jumps.\nThe maximum value here should be 0.02s'));
xlabel('Time (s)');
ylabel('Difference (s)');

figure(2);
plot(imu(:,1),imu(:,2)*180/pi,imu(:,1),imu(:,3)*180/pi,imu(:,1),imu(:,4)*180/pi);
xlabel('time (s)');
ylabel('rotation (deg/s)')

figure(3);
plot(imu(:,1),imu(:,5),imu(:,1),imu(:,6),imu(:,1),imu(:,7));
xlabel('time (s)');
ylabel('acceleration (m/s/s)')



