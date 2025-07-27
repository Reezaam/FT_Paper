% Fire Station Response Time Simulation under Varying Traffic Conditions

clc; clear; close all;

% Define stations and regions
stations = {'S1','S2','S3','S4','S5'};
regions = {'R1','R2','R3','R4','R5','R6','R7'};

% Distance matrix from each station to each region (in kilometers)
D = [
    2.5, 3.0, 4.2, 5.1, 6.0, 7.5, 3.2;
    3.1, 2.2, 3.8, 4.5, 5.3, 6.9, 2.8;
    4.0, 3.5, 2.0, 3.0, 4.1, 5.5, 3.0;
    5.2, 4.1, 3.1, 2.5, 3.6, 4.8, 4.0;
    6.3, 5.0, 4.0, 3.1, 2.3, 3.7, 5.0
];

% Traffic condition speeds [Heavy vehicle speed, Light vehicle speed] in km/h
traffic_conditions = struct( ...
    'Light', [40, 50], ...
    'Average', [52.5, 62.5], ...
    'Heavy', [65, 75]);

% Prepare figure
figure;
condition_names = fieldnames(traffic_conditions);
vehicle_types = {'Heavy', 'Light'};

% Loop over vehicle types and traffic conditions
for v = 1:length(vehicle_types)
    for t = 1:length(condition_names)
        cond = condition_names{t};
        speeds = traffic_conditions.(cond); % [hv_speed, lv_speed]

        % Choose correct speed (in km/min)
        if strcmp(vehicle_types{v}, 'Heavy')
            speed_km_min = speeds(1) / 60;
        else
            speed_km_min = speeds(2) / 60;
        end

        % Compute response time (minutes)
        T = D / speed_km_min;

        % Plotting
        subplot(2,3,(v-1)*3 + t);
        imagesc(T);  % Create heatmap
        colormap('parula');  % Use built-in colormap
        colorbar;
        title([vehicle_types{v} ' Vehicles - ' cond ' Traffic']);
        xlabel('Regions'); ylabel('Stations');
        xticks(1:length(regions)); xticklabels(regions);
        yticks(1:length(stations)); yticklabels(stations);
    end
end

% Overall title
sgtitle('Response Time Heatmaps for Fire Stations (in Minutes)');
