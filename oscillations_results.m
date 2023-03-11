function oscillations_results()
% Description: This function requires a .csv file with the macro results of analysis
% on all of the individual files. It plots the centroids of all of the
% files in a single plot. The types of files which are included
% (Sham/TB,F/NL) are typed out and selected explicitly.
%---------------------------------------------------------
data = csvread('Oscillations_Results.csv',1,3);
centroids = data(:,5:22);
centroids_plotter(centroids);
end

function centroids_plotter(centroids)
types1 = [2
2
2
2
2
2
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
2
2
2
2
2
2
1
1
1
1
1
1
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2];
types2 = [1
2
1
2
1
2
2
2
2
1
1
1
1
2
2
1
2
1
1
2
1
2
1
2
1
2
1
2
1
2
1
2
1
2
1
2
2
2
2
1
1
1
1
2
1
2
1
2
1
2
1
2
1
2
1
2
1
2
1
2
1
2
1
2
1
2
1
2
1
2
1
2];
%The following line can be adjusted to take out certain types of files.
centroids(~(types1 == 2 & types2 == 2),:) = [];
figure;
hold on;
scatter(centroids(:,4),centroids(:,3),'filled');
scatter(centroids(:,10),centroids(:,9),'filled');
scatter(centroids(:,16),centroids(:,15),'filled');
xlabel('Theta/Delta (z)')
ylabel('Beta (z)');
axis([-2 4 -2 2]);
legend('LIA','Theta','SIA');
hold off;
figure;
hold on;
scatter(centroids(:,5),centroids(:,3),'filled');
scatter(centroids(:,11),centroids(:,9),'filled');
scatter(centroids(:,17),centroids(:,15),'filled');
xlabel('Theta/Delta (z)')
ylabel('Gamma (z)');
axis([-2 4 -2 2]);
legend('LIA','Theta','SIA');
hold off;
figure;
hold on;
scatter(centroids(:,4),centroids(:,5),'filled');
scatter(centroids(:,10),centroids(:,11),'filled');
scatter(centroids(:,16),centroids(:,17),'filled');
xlabel('Beta (z)')
ylabel('Gamma (z)');
axis([-2 2 -2 2]);
legend('LIA','Theta','SIA');
hold off;
end