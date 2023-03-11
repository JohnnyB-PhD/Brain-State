function testoscillations2(file, row, column)
% Description: This program requires a .csv file containing raw brainwave rat data. 
% It segments this data into small timestamps and clusters the segments into the
% four different states: Theta, LIA, SIA, and Unlabeled. The program is able to plot the final
% results, as well as other meaningful figures, throughout the process. All
% that is necessary to run the program is changing the name of the .csv
% file inside of the csvread function call.
%
% $Author: Ari Vilker$
% Additional Author: Jonathan Bentley (coding of state times output)
%---------------------------------------------------------
filename = file; 
rowoffset = row;
columnoffset = column;

    
dataset = csvread([filename '.csv'],rowoffset,columnoffset);
[avg_results,non_z_results,choppedbins] = analysis(dataset);
%The following commented lines are optional calls to functions below which
%will plot an assortment of interesting figures. These are not required to
%complete the k-means pathway.
%plot_betathetadelta(avg_results);
%plot_gammathetadelta(avg_results);
%plot_gammabeta(avg_results);
%plot_kmeans_btd(avg_results);
%plot_kmeans_gtd(avg_results);
%plot_kmeans_gb(avg_results);
%[sum1,sum2,sum3] = plot_cluster_initialization(avg_results,non_z_results);
%[sum1,sum2,sum3] = plot_cluster_initialization(avg_results,non_z_results);
[centroid0,centroid1,centroid2] = plot_cluster_initialization(avg_results,non_z_results);
[centroid2,centroid3,centroid4,t,st,idx] = k_means(avg_results,non_z_results,centroid0,centroid1,centroid2,choppedbins);
centroids = [centroid2 centroid3 centroid4];

     %%%%




unlabeled = findstartstops(t,st,1);
theta = findstartstops(t,st,2);
LIA = findstartstops(t,st,3);
SIA = findstartstops(t,st,4);
chopped = findstartstops(t,st,5);

col_header = ["Unlabeled" " " " " "Theta" " " " " "LIA" " " " " "SIA" " " " " "ChoppedBins" " " " ";"start" "stop" " " "start" "stop" " " "start" "stop" " " "start" "stop" " " "start" "stop" " "];
xlswrite('StateTimes.xls',col_header,filename,'A1');

z = zeros(length(unlabeled),1);
test = [unlabeled z theta z LIA z SIA z chopped];
xlswrite('StateTimes.xls',test,filename,'A3');

load handel;
sound(y);

end

function [centroid2,centroid3,centroid4,t,st,idx] = k_means(avg_results,non_z_results,centroid0,centroid1,centroid2,choppedbins)
% Description: This function performs the k-means clustering and plots the
% results. It also displays the number of each state to the command window
% in the following order: unlabeled, theta, LIA, SIA.
%---------------------------------------------------------
[idx,C] = kmeans(avg_results,3,'Start',[centroid0;centroid1;centroid2]);
for i = 1:length(non_z_results)
    if non_z_results(i,6) < -0.5
        idx(i) = 4;
    end
end

st=[];
j=1;

for i=1:length(idx)
    if(choppedbins(j)==0)
        st = [st;idx(i)];
        j=j+1;
    else
        st = [st;5];
        st = [st;idx(i)];
        j=j+2;
    end

end

t=[];
for i=1:length(st)
    t(i,1)= ((.5*i)-.5);
end


%disp(length(avg_results(idx == 1,:)));
%disp(length(avg_results(idx == 2,:)));
%disp(length(avg_results(idx == 3,:)));
%disp(length(avg_results(idx == 4,:)));
centroid2 = mean(avg_results(idx == 2,:),1);
centroid3 = mean(avg_results(idx == 3,:),1);
centroid4 = mean(avg_results(idx == 4,:),1);
%figure
%gscatter(avg_results(:,3),avg_results(:,4),idx,'bgrk')
%hold on
%legend('Unlabeled','Theta','LIA','SIA')
%xlabel('Theta/Delta (z)')
%ylabel('Beta (z)');
%axis([-5 10 -3 5]);
%figure
%gscatter(avg_results(:,3),avg_results(:,5),idx,'bgrk')
%hold on
%legend('Unlabeled','Theta','LIA','SIA')
%xlabel('Theta/Delta (z)')
%ylabel('Gamma (z)');
%axis([-5 10 -3 5]);
%figure
%gscatter(avg_results(:,4),avg_results(:,5),idx,'bgrk')
%hold on
%legend('Unlabeled','Theta','LIA','SIA')
%xlabel('Beta (z)')
%ylabel('Gamma (z)');
%axis([-3 5 -3 5]);

end

function [centroid0,centroid1,centroid2] = plot_cluster_initialization(avg_results,non_z_results)
% Description: This function sets up the initial clusters and collects the
% initial centroids. This process can be tuned in the if statements. There
% is also a large chunk of commented plotting code.
%---------------------------------------------------------
median_thetadelta = median(non_z_results(:,3));
median_beta = median(non_z_results(:,4));
non_z_results = [non_z_results zscore(avg_results(:,6))];
idx = zeros(length(avg_results),1);
for i = 1:length(non_z_results)
    if non_z_results(i,3) > 2.25*median_thetadelta
        idx(i) = 1;
    elseif avg_results(i,4) > -0.5
        idx(i) = 2;
    %elseif non_z_results(i,6) > -0.5
        %idx(i) = 2;
    end
end
% unlabeledcounter = length(non_z_results) - thetacounter - LIAcounter;
% beta = avg_results(:,4);
% thetadelta = avg_results(:,3);
% gamma = avg_results(:,5);
% totalpower = avg_results(:,6);
% ready = [thetadelta beta];
% figure
% gscatter(ready(:,1),ready(:,2),idx,'kbgr')
% xlabel('Theta/Delta (z)')
% ylabel('Beta (z)');
% axis([-5 10 -3 5]); 
% legend('Unlabeled','Theta','LIA')
% ready = [thetadelta gamma];
% figure
% gscatter(ready(:,1),ready(:,2),idx,'kbgr')
% xlabel('Theta/Delta (z)')
% ylabel('Gamma (z)');
% axis([-5 10 -3 5]); 
% legend('Unlabeled','Theta','LIA')
% ready = [beta gamma];
% figure
% gscatter(ready(:,1),ready(:,2),idx,'kbgr')
% xlabel('Beta (z)')
% ylabel('Gamma (z)');
% axis([-3 5 -3 5]); 
% legend('Unlabeled','Theta','LIA')
% ready = [thetadelta totalpower];
% figure
% gscatter(ready(:,1),ready(:,2),idx,'kbgr')
% xlabel('Theta/Delta (z)')
% ylabel('Total Power (z)');
% axis([-5 10 -3 5]); 
% legend('Unlabeled','Theta','LIA')
centroid0 = mean(avg_results(idx == 0,:),1);
centroid1 = mean(avg_results(idx == 1,:),1);
centroid2 = mean(avg_results(idx == 2,:),1);
end

function [avg_results,non_z,choppedbins] = analysis(subject)
% Description: This function performs the initial segmentation and analysis
% of the dataset. The preprocessing and transformation occurs here.
%---------------------------------------------------------
cols = size(subject,2);
sites = [];
i = 1;
while i < cols
    sites = [sites subject(:,i) subject(:,i+1)];
    i = i + 2;
end
avg_results = [];
stop = length(sites);
i=1000;
j=1;
while i <= stop
    sum = 0;
    a = 1;
    while a < cols       
    chunk = [sites(i-999:i,a),sites(i-999:i,a+1)]; %a bin of data from one channel
    a = a + 2;
    chunk_results = single_fft(chunk); %fft values of a bin from one channel
    sum = sum + chunk_results; 
    end
    avg_results(j,1:5) = sum/(cols/2); %row j is average fft values of a timebin
    i = i+1000;
    j = j+1;  
end
non_z = avg_results;
avg_results = zscore(avg_results);
avg_results = [avg_results mean(avg_results,2)];
non_z = [non_z avg_results(:,6)];
choppedbins = any(abs(avg_results)>10,2);
non_z(any(abs(avg_results)>10,2),:) = [];  %this is where 1 sec is chopped off.......
avg_results(any(abs(avg_results)>10,2),:) = [];  %this is where 1 sec is chopped off......
end

function plot_data(chunkeddata)
figure;
plot(chunkeddata(:,1),chunkeddata(:,2));
xlabel('Time (s)');
ylabel('Amplitude');
end

function results = single_fft(chunkeddata)
% Description: This function performs the continuous wavelet transform and
% collects the results based on the maximums for the states associated with
% different frequency levels in the data.
%---------------------------------------------------------
[wt,f] = cwt(chunkeddata(:,2),2000,'FrequencyLimits',[0.3 80],"TimeBandwidth",10);
abs_wt = abs(wt);
max_theta = max(max(abs_wt(29:38,:)));
max_delta = max(max(abs_wt(46:58,:)));
max_thetadelta = max_theta/max_delta;
max_beta = max(max(abs_wt(21:28,:)));
max_gamma = max(max(abs_wt(8:15,:)));
results = [max_theta,max_delta,max_thetadelta,max_beta,max_gamma];
end

function plot_betathetadelta(avg_results)
beta = avg_results(:,4);
thetadelta = avg_results(:,3);
figure
scatter(thetadelta,beta,'filled');
xlabel('Theta/Delta (z)')
ylabel('Beta (z)');
axis([-5 10 -3 5]);
end

function plot_gammathetadelta(avg_results)
gamma = avg_results(:,5);
thetadelta = avg_results(:,3);
figure
scatter(thetadelta,gamma,'filled');
xlabel('Theta/Delta (z)')
ylabel('Gamma (z)');
axis([-5 10 -3 5]);
end

function plot_gammabeta(avg_results)
beta = avg_results(:,4);
gamma = avg_results(:,5);
figure
scatter(beta,gamma,'filled');
xlabel('Beta (z)')
ylabel('Gamma (z)');
axis([-3 5 -3 5]);
end

function plot_kmeans_btd(avg_results,non_z_results,centroid0,centroid1,centroid2)
beta = avg_results(:,4);
thetadelta = avg_results(:,3);
ready = [thetadelta beta];
[idx,C] = kmeans(ready,3,'Start',[centroid0(3) centroid0(4);centroid1(3) centroid1(4);centroid2(3) centroid2(4)]);
for i = 1:length(non_z_results)
    if non_z_results(i,6) < -0.5
        idx(i) = 4;
    end
end
figure
gscatter(ready(:,1),ready(:,2),idx,'bgrk')
hold on
legend('Theta','SIA','LIA','Unlabeled')
xlabel('Theta/Delta (z)')
ylabel('Beta (z)');
axis([-5 10 -3 5]); 
end

function plot_kmeans_gtd(avg_results,non_z_results,centroid0,centroid1,centroid2)
gamma = avg_results(:,5);
thetadelta = avg_results(:,3);
ready = [thetadelta gamma];
[idx,C] = kmeans(ready,3,'Start',[centroid0(3) centroid0(5);centroid1(3) centroid1(5);centroid2(3) centroid2(5)]);
for i = 1:length(non_z_results)
    if non_z_results(i,6) < -0.5
        idx(i) = 4;
    end
end
figure
gscatter(ready(:,1),ready(:,2),idx,'bgr')
hold on
legend('Theta','SIA','LIA','Cluster Centroid')
xlabel('Theta/Delta (z)')
ylabel('Gamma (z)');
axis([-5 10 -3 5]);
end

function plot_kmeans_gb(avg_results,non_z_results,centroid0,centroid1,centroid2)
gamma = avg_results(:,5);
beta = avg_results(:,4);
ready = [beta gamma];
[idx,C] = kmeans(ready,3,'Start',[centroid0(4) centroid0(5);centroid1(4) centroid1(5);centroid2(4) centroid2(5)]);
for i = 1:length(non_z_results)
    if non_z_results(i,6) < -0.5
        idx(i) = 4;
    end
end
figure
gscatter(ready(:,1),ready(:,2),idx,'bgr')
hold on
legend('Theta','SIA','LIA','Cluster Centroid')
xlabel('Beta (z)')
ylabel('Gamma (z)');
axis([-3 5 -3 5]);
end