% Fire Station Response Time Simulation with Traffic Engineering Principles
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

% Traffic Engineering Parameters
% Traffic density (vehicles per km per lane)
traffic_density = struct(...
    'Light', 15, ...    % Low density - free flow
    'Average', 35, ...  % Moderate density - stable flow
    'Heavy', 65);       % High density - congested flow

% Speed-density relationship parameters (based on Greenshields model)
% v = v_max * (1 - k/k_jam) where k is density, k_jam is jam density
free_flow_speed = 80;  % km/h maximum speed
jam_density = 120;     % vehicles/km/lane at jam

% Emergency vehicle speed advantage factors
% Based on traffic engineering literature (May, 1990; TRB Highway Capacity Manual)
emergency_advantage = struct(...
    'Light', 1.15, ...   % 15% faster due to clear lanes
    'Average', 1.25, ... % 25% faster due to traffic clearing
    'Heavy', 1.10);      % Only 10% faster - limited maneuverability

% Calculate realistic speeds using traffic flow theory
condition_names = fieldnames(traffic_density);
traffic_speeds = struct();

for i = 1:length(condition_names)
    cond = condition_names{i};
    density = traffic_density.(cond);
    
    % Greenshields speed-density model
    general_speed = free_flow_speed * (1 - density/jam_density);
    
    % Emergency vehicle speed with realistic advantage
    emergency_speed = general_speed * emergency_advantage.(cond);
    
    % Ensure minimum speeds (emergency vehicles have alternate routes/techniques)
    general_speed = max(general_speed, 15);    % Minimum 15 km/h
    emergency_speed = max(emergency_speed, 25); % Minimum 25 km/h
    
    traffic_speeds.(cond) = [emergency_speed, general_speed];
end

% Display traffic engineering analysis
fprintf('\n=== TRAFFIC ENGINEERING ANALYSIS ===\n');
fprintf('Condition    | Density | General Speed | Emergency Speed | Advantage\n');
fprintf('-------------|---------|---------------|-----------------|----------\n');
for i = 1:length(condition_names)
    cond = condition_names{i};
    density = traffic_density.(cond);
    speeds = traffic_speeds.(cond);
    advantage = (speeds(1) - speeds(2)) / speeds(2) * 100;
    fprintf('%-12s | %3d v/km | %8.1f km/h | %9.1f km/h | %6.1f%%\n', ...
        cond, density, speeds(2), speeds(1), advantage);
end

% Create comprehensive visualization
figure('Position', [100, 100, 1400, 1000]);

% Vehicle types for analysis
vehicle_types = {'Emergency', 'General'};
colors = {'red', 'blue'};

% 1. Speed-Density Relationship (Traffic Engineering Fundamental)
subplot(3,4,1);
density_range = 0:5:120;
speed_curve = free_flow_speed * (1 - density_range/jam_density);
speed_curve = max(speed_curve, 0);
plot(density_range, speed_curve, 'k-', 'LineWidth', 2);
hold on;

% Plot current conditions
for i = 1:length(condition_names)
    cond = condition_names{i};
    density = traffic_density.(cond);
    speeds = traffic_speeds.(cond);
    
    % General traffic
    plot(density, speeds(2), 'o', 'Color', colors{2}, 'MarkerSize', 8, 'LineWidth', 2);
    % Emergency vehicles
    plot(density, speeds(1), 's', 'Color', colors{1}, 'MarkerSize', 8, 'LineWidth', 2);
    
    % Add condition labels
    text(density+2, speeds(1)+2, cond, 'FontSize', 8);
end

xlabel('Traffic Density (veh/km/lane)');
ylabel('Speed (km/h)');
title('Speed-Density Relationship');
legend('Theoretical Curve', 'General Traffic', 'Emergency Vehicles', 'Location', 'northeast');
grid on;

% 2. Emergency Vehicle Advantage Analysis
subplot(3,4,2);
cond_nums = 1:length(condition_names);
advantages = zeros(size(cond_nums));
for i = 1:length(condition_names)
    cond = condition_names{i};
    speeds = traffic_speeds.(cond);
    advantages(i) = (speeds(1) - speeds(2)) / speeds(2) * 100;
end
bar(cond_nums, advantages, 'FaceColor', [0.8 0.2 0.2]);
xlabel('Traffic Conditions');
ylabel('Speed Advantage (%)');
title('Emergency Vehicle Speed Advantage');
xticks(cond_nums);
xticklabels(condition_names);
grid on;

% 3-8. Response Time Heatmaps
for v = 1:length(vehicle_types)
    for t = 1:length(condition_names)
        cond = condition_names{t};
        speeds = traffic_speeds.(cond);
        
        % Choose correct speed (convert to km/min)
        if strcmp(vehicle_types{v}, 'Emergency')
            speed_km_min = speeds(1) / 60;
        else
            speed_km_min = speeds(2) / 60;
        end
        
        % Compute response time matrix (minutes)
        T = D / speed_km_min;
        
        % Create heatmap
        subplot(3,4, 2 + (v-1)*3 + t);
        imagesc(T);
        colormap('hot');
        c = colorbar;
        c.Label.String = 'Time (min)';
        
        title([vehicle_types{v} ' - ' cond ' Traffic']);
        xlabel('Regions'); 
        ylabel('Stations');
        xticks(1:length(regions)); 
        xticklabels(regions);
        yticks(1:length(stations)); 
        yticklabels(stations);
        
        % Add response time values as text
        for i = 1:size(T,1)
            for j = 1:size(T,2)
                text(j, i, sprintf('%.1f', T(i,j)), ...
                    'HorizontalAlignment', 'center', ...
                    'Color', 'white', 'FontWeight', 'bold', 'FontSize', 8);
            end
        end
    end
end

% 9. Traffic Flow vs Response Time Analysis
subplot(3,4,9);
for i = 1:length(condition_names)
    cond = condition_names{i};
    speeds = traffic_speeds.(cond);
    
    % Calculate average response times
    avg_emergency = mean(D(:) ./ (speeds(1)/60));
    avg_general = mean(D(:) ./ (speeds(2)/60));
    
    plot(traffic_density.(cond), avg_emergency, 's-', 'Color', colors{1}, ...
        'MarkerSize', 8, 'LineWidth', 2);
    hold on;
    plot(traffic_density.(cond), avg_general, 'o-', 'Color', colors{2}, ...
        'MarkerSize', 8, 'LineWidth', 2);
end
xlabel('Traffic Density (veh/km/lane)');
ylabel('Average Response Time (min)');
title('Response Time vs Traffic Density');
legend('Emergency Vehicles', 'General Traffic', 'Location', 'northwest');
grid on;

% 10. Station Efficiency Comparison
subplot(3,4,10);
station_efficiency = zeros(length(stations), length(condition_names));
for t = 1:length(condition_names)
    cond = condition_names{t};
    speed = traffic_speeds.(cond)(1) / 60; % Emergency speed in km/min
    
    for s = 1:length(stations)
        avg_response = mean(D(s,:) / speed);
        station_efficiency(s,t) = avg_response;
    end
end

bar(station_efficiency);
xlabel('Fire Stations');
ylabel('Average Response Time (min)');
title('Station Performance by Traffic Condition');
legend(condition_names, 'Location', 'northeast');
xticks(1:length(stations));
xticklabels(stations);
grid on;

% 11. Regional Coverage Analysis
subplot(3,4,11);
region_best_times = zeros(length(regions), length(condition_names));
for t = 1:length(condition_names)
    cond = condition_names{t};
    speed = traffic_speeds.(cond)(1) / 60; % Emergency speed in km/min
    T = D / speed;
    
    for r = 1:length(regions)
        region_best_times(r,t) = min(T(:,r)); % Best response time to each region
    end
end

bar(region_best_times);
xlabel('Regions');
ylabel('Best Response Time (min)');
title('Regional Coverage Analysis');
legend(condition_names, 'Location', 'northeast');
xticks(1:length(regions));
xticklabels(regions);
grid on;

% 12. Traffic Engineering Summary
subplot(3,4,12);
axis off;
text(0.1, 0.9, 'TRAFFIC ENGINEERING INSIGHTS:', 'FontWeight', 'bold', 'FontSize', 10);
text(0.1, 0.8, '• Speed decreases with traffic density', 'FontSize', 9);
text(0.1, 0.7, '• Emergency vehicles maintain advantage', 'FontSize', 9);
text(0.1, 0.6, '• Heavy traffic reduces overall mobility', 'FontSize', 9);
text(0.1, 0.5, '• Emergency protocols provide 10-25% benefit', 'FontSize', 9);
text(0.1, 0.4, '• Light traffic allows maximum speeds', 'FontSize', 9);
text(0.1, 0.3, '• Model based on Greenshields theory', 'FontSize', 9);
text(0.1, 0.2, '• Realistic speed-density relationships', 'FontSize', 9);
text(0.1, 0.1, '• Literature-supported assumptions', 'FontSize', 9);

% Overall title
sgtitle('Fire Station Response Analysis - Traffic Engineering Model', 'FontSize', 14, 'FontWeight', 'bold');

% Print summary statistics
fprintf('\n=== RESPONSE TIME SUMMARY ===\n');
for t = 1:length(condition_names)
    cond = condition_names{t};
    speed = traffic_speeds.(cond)(1) / 60;
    T = D / speed;
    fprintf('%s Traffic - Emergency Vehicles:\n', cond);
    fprintf('  Average Response Time: %.2f minutes\n', mean(T(:)));
    fprintf('  Maximum Response Time: %.2f minutes\n', max(T(:)));
    fprintf('  Minimum Response Time: %.2f minutes\n', min(T(:)));
    fprintf('  Standard Deviation: %.2f minutes\n', std(T(:)));
    fprintf('\n');
end