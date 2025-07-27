clc; clear; close all;

% Region and station names
regions = {'R1','R2','R3','R4','R5','R6','R7'};
stations = {'S1','S2','S3','S4','S5'};

% Assumed demand data from paper (proportional, 1-week window, Figure 4)
% Units: number of calls per region
demand = [20, 35, 25, 40, 30, 15, 28];  % Example based on Fig. 4

% Distance matrix from each station to each region (in km)
D = [
    2.5, 3.0, 4.2, 5.1, 6.0, 7.5, 3.2;
    3.1, 2.2, 3.8, 4.5, 5.3, 6.9, 2.8;
    4.0, 3.5, 2.0, 3.0, 4.1, 5.5, 3.0;
    5.2, 4.1, 3.1, 2.5, 3.6, 4.8, 4.0;
    6.3, 5.0, 4.0, 3.1, 2.3, 3.7, 5.0
];

% Speed of fire trucks under average traffic (km/h)
speed = 52.5 / 60;  % Convert to km/min

% Response time matrix (minutes)
T = D / speed;

% Set threshold (maximum acceptable response time in minutes)
threshold = 5;

% Coverage matrix (1 = covered within threshold, 0 = not covered)
Coverage = T <= threshold;

% Coverage efficiency per region (i.e., how many stations can reach each region in time)
coverage_efficiency = sum(Coverage, 1);

% ---------- PLOTTING HEATMAPS ----------

figure;

% Demand Heatmap
subplot(1,2,1);
bar(demand, 'FaceColor', [0.8 0.2 0.2]);
title('Emergency Demand per Region');
xlabel('Region'); ylabel('Weekly Demand');
set(gca, 'XTickLabel', regions, 'FontWeight','bold');
grid on;

% Coverage Efficiency Heatmap
subplot(1,2,2);
bar(coverage_efficiency, 'FaceColor', [0.2 0.4 0.8]);
title('Coverage Efficiency per Region');
xlabel('Region'); ylabel('No. of Stations Covering (? 5 min)');
set(gca, 'XTickLabel', regions, 'FontWeight','bold');
ylim([0, max(coverage_efficiency)+1]);
grid on;

sgtitle('Spatial Visualization of Demand and Coverage Efficiency');

