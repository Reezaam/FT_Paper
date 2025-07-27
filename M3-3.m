clc; clear; close all;
warning('off', 'all');

% ========================================================================
% FIRE STATION SERVICE OUTPUT ANALYSIS DASHBOARD
% ========================================================================

%% 1. BASE DATA SETUP
numStations = 5;
numRegions = 7;
stations = {'S1', 'S2', 'S3', 'S4', 'S5'};
regions = {'R1', 'R2', 'R3', 'R4', 'R5', 'R6', 'R7'};

% Distance matrix (km)
D = [
    2.5, 3.0, 4.2, 5.1, 6.0, 7.5, 3.2;
    3.1, 2.2, 3.8, 4.5, 5.3, 6.9, 2.8;
    4.0, 3.5, 2.0, 3.0, 4.1, 5.5, 3.0;
    5.2, 4.1, 3.1, 2.5, 3.6, 4.8, 4.0;
    6.3, 5.0, 4.0, 3.1, 2.3, 3.7, 5.0
];

%% 2. SERVICE PARAMETERS AND SCENARIOS
% Different service scenarios
service_scenarios = {
    'NormalOperations', 'PeakHours', 'EmergencyAlert', 'SevereWeather', 'MultipleIncidents'
};

% Vehicle speeds under different conditions (km/h)
vehicle_speeds = [45, 35, 55, 25, 30]; % corresponding to scenarios

% Population density per region (thousands)
population_density = [25, 15, 18, 20, 30, 12, 14];

% Emergency call frequency per day per region
call_frequency = [8, 12, 6, 7, 15, 4, 5];

% Station capacity (number of vehicles)
station_capacity = [3, 2, 4, 3, 2];

% Regional risk factors (1-5 scale)
risk_factors = [4, 5, 2, 3, 4, 2, 2];

%% 3. SERVICE OUTPUT CALCULATIONS
fprintf('=== CALCULATING FIRE STATION SERVICE OUTPUTS ===\n');

% Initialize service output matrices
service_outputs = struct();

for scenario_idx = 1:length(service_scenarios)
    scenario = service_scenarios{scenario_idx};
    speed = vehicle_speeds(scenario_idx);
    
    fprintf('Analyzing scenario: %s (Speed: %d km/h)\n', scenario, speed);
    
    % Calculate response times
    response_times = D ./ (speed / 60); % Convert to minutes
    
    % Calculate service coverage (inverse of response time weighted by capacity)
    service_coverage = zeros(size(D));
    for i = 1:numStations
        for j = 1:numRegions
            service_coverage(i,j) = (station_capacity(i) / response_times(i,j)) * ...
                                   (population_density(j) / 20) * ...
                                   (call_frequency(j) / 10);
        end
    end
    
    % Calculate service efficiency
    service_efficiency = service_coverage .* (1 ./ risk_factors);
    
    % Store results
    service_outputs.(sprintf('scenario_%d', scenario_idx)) = struct();
    service_outputs.(sprintf('scenario_%d', scenario_idx)).name = scenario;
    service_outputs.(sprintf('scenario_%d', scenario_idx)).response_times = response_times;
    service_outputs.(sprintf('scenario_%d', scenario_idx)).service_coverage = service_coverage;
    service_outputs.(sprintf('scenario_%d', scenario_idx)).service_efficiency = service_efficiency;
    service_outputs.(sprintf('scenario_%d', scenario_idx)).speed = speed;
end

%% 4. COMPREHENSIVE SERVICE ANALYSIS
fprintf('\n=== CREATING COMPREHENSIVE SERVICE OUTPUT DASHBOARD ===\n');
createServiceOutputDashboard(service_outputs, stations, regions, population_density, call_frequency, station_capacity, risk_factors, service_scenarios);

%% 5. OPERATIONAL METRICS ANALYSIS
fprintf('\n=== ANALYZING OPERATIONAL METRICS ===\n');
createOperationalMetricsDashboard(service_outputs, stations, regions, service_scenarios);

%% 6. REGIONAL SERVICE QUALITY ANALYSIS
fprintf('\n=== ANALYZING REGIONAL SERVICE QUALITY ===\n');
createRegionalServiceDashboard(service_outputs, stations, regions, population_density, call_frequency, risk_factors, service_scenarios);

%% 7. STATION PERFORMANCE ANALYSIS
fprintf('\n=== ANALYZING STATION PERFORMANCE ===\n');
createStationPerformanceDashboard(service_outputs, stations, regions, station_capacity, service_scenarios);

fprintf('\n=== SERVICE OUTPUT ANALYSIS COMPLETE ===\n');

%% ========================================================================
%% SUPPORTING FUNCTIONS
%% ========================================================================

function createServiceOutputDashboard(service_outputs, stations, regions, population_density, call_frequency, station_capacity, risk_factors, service_scenarios)
    % Create comprehensive service output dashboard
    fig = figure('Position', [50, 50, 1900, 1200], 'Name', 'Fire Station Service Output Dashboard');
    set(fig, 'DefaultAxesFontSize', 6);
    set(fig, 'DefaultTextFontSize', 6);
    set(fig, 'DefaultAxesFontName', 'Arial');
    set(fig, 'DefaultTextFontName', 'Arial');
    
    % 1. Response Time Heatmaps for All Scenarios
    for i = 1:5
        subplot(4, 5, i);
        scenario_data = service_outputs.(sprintf('scenario_%d', i));
        
        imagesc(scenario_data.response_times);
        colormap(hot);
        c = colorbar;
        c.Label.String = 'Minutes';
        c.Label.FontSize = 6;
        
        title(sprintf('%s\nResponse Times', scenario_data.name), 'FontSize', 11, 'FontWeight', 'bold');
        xlabel('Regions', 'FontSize', 6);
        ylabel('Stations', 'FontSize', 6);
        
        xticks(1:length(regions));
        xticklabels(regions);
        xtickangle(45);
        yticks(1:length(stations));
        yticklabels(stations);
        set(gca, 'FontSize', 6);
        
        % Add response time values
        for row = 1:size(scenario_data.response_times, 1)
            for col = 1:size(scenario_data.response_times, 2)
                text(col, row, sprintf('%.1f', scenario_data.response_times(row, col)), ...
                    'HorizontalAlignment', 'center', 'Color', 'white', ...
                    'FontWeight', 'bold', 'FontSize', 6);
            end
        end
    end
    
    % 6. Average Response Time by Scenario
    subplot(4, 5, 6);
    avg_response_times = zeros(1, 5);
    for i = 1:5
        scenario_data = service_outputs.(sprintf('scenario_%d', i));
        avg_response_times(i) = mean(scenario_data.response_times(:));
    end
    
    bar(avg_response_times, 'FaceColor', [0.2 0.6 0.8], 'EdgeColor', 'k');
    title('Average Response Time by Scenario', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Service Scenarios', 'FontSize', 6);
    ylabel('Average Response Time (min)', 'FontSize', 6);
    xticks(1:5);
    xticklabels(service_scenarios);
    xtickangle(45);
    grid on;
    
    % Add value labels on bars
    for i = 1:length(avg_response_times)
        text(i, avg_response_times(i) + 0.2, sprintf('%.1f', avg_response_times(i)), ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    % 7. Station Capacity vs Coverage
    subplot(4, 5, 7);
    total_coverage = zeros(1, length(stations));
    for i = 1:length(stations)
        scenario1_data = service_outputs.scenario_1;
        total_coverage(i) = sum(scenario1_data.service_coverage(i, :));
    end
    
    scatter(station_capacity, total_coverage, 100, 'filled', 'MarkerEdgeColor', 'k');
    title('Station Capacity vs Service Coverage', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Station Capacity (Vehicles)', 'FontSize', 6);
    ylabel('Total Service Coverage', 'FontSize', 6);
    grid on;
    
    % Add station labels
    for i = 1:length(stations)
        text(station_capacity(i) + 0.1, total_coverage(i), stations{i}, ...
            'FontSize', 6, 'FontWeight', 'bold');
    end
    
    % 8. Population Density Impact
    subplot(4, 5, 8);
    bar(population_density, 'FaceColor', [0.8 0.4 0.2], 'EdgeColor', 'k');
    title('Population Density by Region', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Regions', 'FontSize', 6);
    ylabel('Population Density (thousands)', 'FontSize', 6);
    xticks(1:length(regions));
    xticklabels(regions);
    xtickangle(45);
    grid on;
    
    % 9. Emergency Call Frequency
    subplot(4, 5, 9);
    bar(call_frequency, 'FaceColor', [0.6 0.8 0.2], 'EdgeColor', 'k');
    title('Daily Emergency Calls by Region', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Regions', 'FontSize', 6);
    ylabel('Calls per Day', 'FontSize', 6);
    xticks(1:length(regions));
    xticklabels(regions);
    xtickangle(45);
    grid on;
    
    % 10. Risk Factor Analysis
    subplot(4, 5, 10);
    bar(risk_factors, 'FaceColor', [0.8 0.2 0.4], 'EdgeColor', 'k');
    title('Regional Risk Factors', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Regions', 'FontSize', 6);
    ylabel('Risk Level (1-5)', 'FontSize', 6);
    xticks(1:length(regions));
    xticklabels(regions);
    xtickangle(45);
    grid on;
    ylim([0 5.5]);
    
    % 11-15. Service Coverage Heatmaps
    for i = 1:5
        subplot(4, 5, 10 + i);
        scenario_data = service_outputs.(sprintf('scenario_%d', i));
        
        imagesc(scenario_data.service_coverage);
        colormap(parula);
        c = colorbar;
        c.Label.String = 'Coverage Index';
        c.Label.FontSize = 6;
        
        title(sprintf('%s\nService Coverage', scenario_data.name), 'FontSize', 6, 'FontWeight', 'bold');
        xlabel('Regions', 'FontSize', 6);
        ylabel('Stations', 'FontSize', 6);
        
        xticks(1:length(regions));
        xticklabels(regions);
        xtickangle(45);
        yticks(1:length(stations));
        yticklabels(stations);
        set(gca, 'FontSize', 6);
    end
    
    % 16-20. Service Efficiency Analysis
    for i = 1:5
        subplot(4, 5, 15 + i);
        scenario_data = service_outputs.(sprintf('scenario_%d', i));
        
        imagesc(scenario_data.service_efficiency);
        colormap(jet);
        c = colorbar;
        c.Label.String = 'Efficiency Index';
        c.Label.FontSize = 6;
        
        title(sprintf('%s\nService Efficiency', scenario_data.name), 'FontSize', 6, 'FontWeight', 'bold');
        xlabel('Regions', 'FontSize', 6);
        ylabel('Stations', 'FontSize', 6);
        
        xticks(1:length(regions));
        xticklabels(regions);
        xtickangle(45);
        yticks(1:length(stations));
        yticklabels(stations);
        set(gca, 'FontSize', 6);
    end
    
    sgtitle('Fire Station Service Output Analysis - Comprehensive Dashboard', ...
        'FontSize', 6, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
end

function createOperationalMetricsDashboard(service_outputs, stations, regions, service_scenarios)
    % Create operational metrics analysis dashboard
    fig = figure('Position', [100, 100, 1600, 1000], 'Name', 'Operational Metrics Dashboard');
    set(fig, 'DefaultAxesFontSize', 6);
    set(fig, 'DefaultTextFontSize', 6);
    set(fig, 'DefaultAxesFontName', 'Arial');
    set(fig, 'DefaultTextFontName', 'Arial');
    
    % 1. Response Time Trends Across Scenarios
    subplot(3, 4, [1, 2]);
    response_matrix = zeros(length(stations), length(service_scenarios));
    
    for i = 1:length(service_scenarios)
        scenario_data = service_outputs.(sprintf('scenario_%d', i));
        response_matrix(:, i) = mean(scenario_data.response_times, 2);
    end
    
    plot(1:length(service_scenarios), response_matrix', 'o-', 'LineWidth', 3, 'MarkerSize', 8);
    title('Station Response Time Trends', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Service Scenarios', 'FontSize', 6);
    ylabel('Ave.Res.Time(min)', 'FontSize', 6);
    xticks(1:length(service_scenarios));
    xticklabels(service_scenarios);
    xtickangle(45);
    legend(stations, 'Location', 'best', 'FontSize', 6);
    grid on; grid minor;
    
    % 2. Service Coverage Distribution
    subplot(3, 4, 3);
    coverage_totals = zeros(1, length(service_scenarios));
    for i = 1:length(service_scenarios)
        scenario_data = service_outputs.(sprintf('scenario_%d', i));
        coverage_totals(i) = sum(scenario_data.service_coverage(:));
    end
    
    pie(coverage_totals, service_scenarios);
    title('Service Coverage Distribution', 'FontSize', 6, 'FontWeight', 'bold');
    
    % 3. Efficiency Metrics
    subplot(3, 4, 4);
    efficiency_avgs = zeros(1, length(service_scenarios));
    for i = 1:length(service_scenarios)
        scenario_data = service_outputs.(sprintf('scenario_%d', i));
        efficiency_avgs(i) = mean(scenario_data.service_efficiency(:));
    end
    
    bar(efficiency_avgs, 'FaceColor', [0.4 0.7 0.9], 'EdgeColor', 'k');
    title('Average Service Efficiency', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Service Scenarios', 'FontSize', 6);
    ylabel('Efficiency Index', 'FontSize', 6);
    xticks(1:length(service_scenarios));
    xticklabels(service_scenarios);
    xtickangle(45);
    grid on;
    
    % 4. Regional Service Quality Matrix
    subplot(3, 4, [5, 6]);
    quality_matrix = zeros(length(regions), length(service_scenarios));
    
    for i = 1:length(service_scenarios)
        scenario_data = service_outputs.(sprintf('scenario_%d', i));
        for j = 1:length(regions)
            quality_matrix(j, i) = mean(scenario_data.service_coverage(:, j));
        end
    end
    
    imagesc(quality_matrix);
    colormap(viridis_colormap());
    colorbar;
    title('Regional Service Quality Matrix', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Service Scenarios', 'FontSize', 6);
    ylabel('Regions', 'FontSize', 6);
    xticks(1:length(service_scenarios));
    xticklabels(service_scenarios);
    xtickangle(45);
    yticks(1:length(regions));
    yticklabels(regions);
    
    % Add quality values
    for i = 1:size(quality_matrix, 1)
        for j = 1:size(quality_matrix, 2)
            text(j, i, sprintf('%.2f', quality_matrix(i, j)), ...
                'HorizontalAlignment', 'center', 'Color', 'white', ...
                'FontWeight', 'bold', 'FontSize', 6);
        end
    end
    
    % 5. Station Workload Analysis
    subplot(3, 4, 7);
    workload_data = zeros(length(stations), length(service_scenarios));
    for i = 1:length(service_scenarios)
        scenario_data = service_outputs.(sprintf('scenario_%d', i));
        workload_data(:, i) = sum(scenario_data.service_coverage, 2);
    end
    
    boxplot(workload_data', 'Labels', stations);
    title('Station Workload Distribution', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Fire Stations', 'FontSize', 6);
    ylabel('Workload Index', 'FontSize', 6);
    xtickangle(45);
    grid on;
    
    % 6. Performance Variability
    subplot(3, 4, 8);
    variability = zeros(1, length(stations));
    for i = 1:length(stations)
        station_responses = [];
        for j = 1:length(service_scenarios)
            scenario_data = service_outputs.(sprintf('scenario_%d', j));
            station_responses = [station_responses, scenario_data.response_times(i, :)];
        end
        variability(i) = std(station_responses) / mean(station_responses) * 100;
    end
    
    bar(variability, 'FaceColor', [0.9 0.6 0.2], 'EdgeColor', 'k');
    title('Station Performance Variability', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Fire Stations', 'FontSize', 6);
    ylabel('Coefficient of Variation (%)', 'FontSize', 6);
    xticks(1:length(stations));
    xticklabels(stations);
    xtickangle(45);
    grid on;
    
    % 7-12. Scenario Comparison Radar Charts
    subplot_positions = [9, 10, 11, 12];
    for i = 1:4
        if i <= length(subplot_positions)
            subplot(3, 4, subplot_positions(i));
            createServiceRadarChart(service_outputs, i, service_scenarios);
        end
    end
    
    sgtitle('Fire Station Operational Metrics Dashboard', ...
        'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
end

function createRegionalServiceDashboard(service_outputs, stations, regions, population_density, call_frequency, risk_factors, service_scenarios)
    % Create regional service quality dashboard
    fig = figure('Position', [150, 150, 1500, 900], 'Name', 'Regional Service Quality Dashboard');
    set(fig, 'DefaultAxesFontSize', 6);
    set(fig, 'DefaultTextFontSize', 6);
    set(fig, 'DefaultAxesFontName', 'Arial');
    set(fig, 'DefaultTextFontName', 'Arial');
    
    % 1. Regional Service Score Calculation
    subplot(3, 3, 1);
    service_scores = zeros(length(regions), length(service_scenarios));
    
    for i = 1:length(service_scenarios)
        scenario_data = service_outputs.(sprintf('scenario_%d', i));
        for j = 1:length(regions)
            avg_response = mean(scenario_data.response_times(:, j));
            avg_coverage = mean(scenario_data.service_coverage(:, j));
            service_scores(j, i) = avg_coverage / avg_response * 10; % Normalized score
        end
    end
    
    bar(service_scores);
    title('Regional Service Scores', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Regions', 'FontSize', 6);
    ylabel('Service Score', 'FontSize', 6);
    xticks(1:length(regions));
    xticklabels(regions);
    xtickangle(45);
    legend(service_scenarios, 'Location', 'best', 'FontSize', 6);
    grid on;
    
    % 2. Population vs Service Quality
    subplot(3, 3, 2);
    normal_ops_scores = service_scores(:, 1);
    scatter(population_density, normal_ops_scores, 100, call_frequency, 'filled', 'MarkerEdgeColor', 'k');
    colorbar;
    title('Population Density vs Service Quality', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Population Density (thousands)', 'FontSize', 6);
    ylabel('Service Score', 'FontSize', 6);
    
    % Add region labels
    for i = 1:length(regions)
        text(population_density(i) + 0.5, normal_ops_scores(i), regions{i}, ...
            'FontSize', 6, 'FontWeight', 'bold');
    end
    grid on;
    
    % 3. Risk vs Response Capability
    subplot(3, 3, 3);
    avg_response_times = zeros(1, length(regions));
    scenario1_data = service_outputs.scenario_1;
    for i = 1:length(regions)
        avg_response_times(i) = mean(scenario1_data.response_times(:, i));
    end
    
    scatter(risk_factors, avg_response_times, 100, population_density, 'filled', 'MarkerEdgeColor', 'k');
    colorbar;
    title('Risk Level vs Response Time', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Risk Factor (1-5)', 'FontSize', 6);
    ylabel('Average Response Time (min)', 'FontSize', 6);
    grid on;
    
    % 4. Service Coverage Comparison
    subplot(3, 3, [4, 5]);
    coverage_comparison = zeros(length(regions), 3);
    scenarios_to_compare = [1, 3, 4]; % Normal, Emergency, Weather
    scenario_names = {'Normal', 'Emergency', 'Severe Weather'};
    
    for i = 1:3
        scenario_data = service_outputs.(sprintf('scenario_%d', scenarios_to_compare(i)));
        for j = 1:length(regions)
            coverage_comparison(j, i) = sum(scenario_data.service_coverage(:, j));
        end
    end
    
    bar(coverage_comparison);
    title('Service Coverage Comparison Across Key Scenarios', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Regions', 'FontSize', 6);
    ylabel('Total Coverage Index', 'FontSize', 6);
    xticks(1:length(regions));
    xticklabels(regions);
    xtickangle(45);
    legend(scenario_names, 'Location', 'best', 'FontSize', 6);
    grid on;
    
    % 6. Regional Priority Matrix
    subplot(3, 3, 6);
    priority_matrix = [population_density', call_frequency', risk_factors'];
    priority_matrix = priority_matrix ./ max(priority_matrix); % Normalize
    
    imagesc(priority_matrix);
    colormap(hot);
    colorbar;
    title('Regional Priority Factors', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Priority Factors', 'FontSize', 6);
    ylabel('Regions', 'FontSize', 6);
    xticks(1:3);
    xticklabels({'Population', 'Call Frequency', 'Risk Level'});
    yticks(1:length(regions));
    yticklabels(regions);
    
    % 7. Service Gap Analysis
    subplot(3, 3, 7);
    service_gaps = zeros(1, length(regions));
    for i = 1:length(regions)
        demand = population_density(i) * call_frequency(i) * risk_factors(i);
        supply = sum(service_scores(i, :));
        service_gaps(i) = max(0, demand/100 - supply/10); % Normalized gap
    end
    
    bar(service_gaps, 'FaceColor', [0.8 0.3 0.3], 'EdgeColor', 'k');
    title('Regional Service Gaps', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Regions', 'FontSize', 6);
    ylabel('Service Gap Index', 'FontSize', 6);
    xticks(1:length(regions));
    xticklabels(regions);
    xtickangle(45);
    grid on;
    
    % Highlight critical gaps
    critical_threshold = mean(service_gaps) + std(service_gaps);
    hold on;
    plot([0, length(regions)+1], [critical_threshold, critical_threshold], 'r--', 'LineWidth', 2);
    text(length(regions)/2, critical_threshold + 0.1, 'Critical Threshold', ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', 'red');
    hold off;
    
    % 8. Regional Performance Summary
    subplot(3, 3, [8, 9]);
    axis off;
    
    % Create performance summary table
    rectangle('Position', [0, 0, 1, 1], 'FaceColor', [0.95 0.95 0.95], 'EdgeColor', 'k');
    text(0.5, 0.95, 'REGIONAL PERFORMANCE SUMMARY', 'FontWeight', 'bold', 'FontSize', 6, ...
        'HorizontalAlignment', 'center', 'Color', [0.1 0.1 0.5]);
    
    y_positions = 0.85:-0.1:0.15;
    for i = 1:length(regions)
        if i <= length(y_positions)
            avg_score = mean(service_scores(i, :));
            status = 'Good';
            if service_gaps(i) > critical_threshold
                status = 'Needs Attention';
            end
            
            text(0.05, y_positions(i), sprintf('• %s:', regions{i}), ...
                'FontSize', 6, 'FontWeight', 'bold', 'Color', 'k');
            text(0.35, y_positions(i), sprintf('Score: %.1f', avg_score), ...
                'FontSize', 6, 'Color', 'k');
            text(0.65, y_positions(i), sprintf('Status: %s', status), ...
                'FontSize', 6, 'Color', strcmp(status, 'Good') * [0 0.6 0] + strcmp(status, 'Needs Attention') * [0.8 0 0]);
        end
    end
    
    sgtitle('Regional Fire Service Quality Analysis', ...
        'FontSize', 6, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
end

function createStationPerformanceDashboard(service_outputs, stations, regions, station_capacity, service_scenarios)
    % Create station performance analysis dashboard
    fig = figure('Position', [200, 200, 1400, 800], 'Name', 'Station Performance Dashboard');
    set(fig, 'DefaultAxesFontSize', 6);
    set(fig, 'DefaultTextFontSize', 6);
    set(fig, 'DefaultAxesFontName', 'Arial');
    set(fig, 'DefaultTextFontName', 'Arial');
    
    % 1. Station Performance Metrics
    subplot(2, 4, 1);
    performance_metrics = zeros(length(stations), 3); % Response, Coverage, Efficiency
    
    for i = 1:length(stations)
        total_response = 0;
        total_coverage = 0;
        total_efficiency = 0;
        
        for j = 1:length(service_scenarios)
            scenario_data = service_outputs.(sprintf('scenario_%d', j));
            total_response = total_response + mean(scenario_data.response_times(i, :));
            total_coverage = total_coverage + sum(scenario_data.service_coverage(i, :));
            total_efficiency = total_efficiency + mean(scenario_data.service_efficiency(i, :));
        end
        
        performance_metrics(i, 1) = 10 - (total_response / length(service_scenarios)); % Lower response time = higher score
        performance_metrics(i, 2) = total_coverage / length(service_scenarios);
        performance_metrics(i, 3) = total_efficiency / length(service_scenarios);
    end
    
    % Normalize metrics
    performance_metrics = performance_metrics ./ max(performance_metrics);
    
    bar(performance_metrics);
    title('Station Performance Metrics', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Fire Stations', 'FontSize', 6);
    ylabel('Normalized Performance', 'FontSize', 6);
    xticks(1:length(stations));
    xticklabels(stations);
    xtickangle(45);
    legend({'Response Score', 'Coverage Score', 'Efficiency Score'}, 'Location', 'best', 'FontSize', 6);
    grid on;
    
    % 2. Capacity Utilization
    subplot(2, 4, 2);
    utilization = zeros(1, length(stations));
    for i = 1:length(stations)
        scenario1_data = service_outputs.scenario_1;
        workload = sum(scenario1_data.service_coverage(i, :));
        utilization(i) = workload / station_capacity(i);
    end
    
    bar(utilization, 'FaceColor', [0.6 0.8 0.4], 'EdgeColor', 'k');
    title('Station Capacity Utilization', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Fire Stations', 'FontSize', 6);
    ylabel('Utilization Ratio', 'FontSize', 6);
    xticks(1:length(stations));
    xticklabels(stations);
    xtickangle(45);
    grid on;
    
    % Add utilization values on bars
    for i = 1:length(utilization)
        text(i, utilization(i) + 0.05, sprintf('%.2f', utilization(i)), ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    % 3. Station Response Time Distribution
    subplot(2, 4, 3);
    response_data = [];
    station_labels = {};
    
    for i = 1:length(stations)
        station_responses = [];
        for j = 1:length(service_scenarios)
            scenario_data = service_outputs.(sprintf('scenario_%d', j));
            station_responses = [station_responses, scenario_data.response_times(i, :)];
        end
        response_data = [response_data; station_responses];
        station_labels{end+1} = stations{i};
    end
    
    boxplot(response_data', 'Labels', station_labels);
    title('Response Time Distribution', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Fire Stations', 'FontSize', 6);
    ylabel('Response Time (min)', 'FontSize', 6);
    xtickangle(45);
    grid on;
    
    % 4. Station Service Coverage Radar
    subplot(2, 4, 4);
    createStationRadarChart(service_outputs, stations, service_scenarios);
    
    % 5. Station Efficiency Trends
    subplot(2, 4, [5, 6]);
    efficiency_trends = zeros(length(stations), length(service_scenarios));
    
    for i = 1:length(stations)
        for j = 1:length(service_scenarios)
            scenario_data = service_outputs.(sprintf('scenario_%d', j));
            efficiency_trends(i, j) = mean(scenario_data.service_efficiency(i, :));
        end
    end
    
    plot(1:length(service_scenarios), efficiency_trends', 'o-', 'LineWidth', 3, 'MarkerSize', 8);
    title('Station Efficiency Trends Across Scenarios', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Service Scenarios', 'FontSize', 6);
    ylabel('Average Efficiency Index', 'FontSize', 6);
    xticks(1:length(service_scenarios));
    xticklabels(service_scenarios);
    xtickangle(45);
    legend(stations, 'Location', 'best', 'FontSize', 6);
    grid on; grid minor;
    
    % 7. Station Load Balance
    subplot(2, 4, 7);
    load_balance = zeros(1, length(stations));
    for i = 1:length(stations)
        station_loads = [];
        for j = 1:length(service_scenarios)
            scenario_data = service_outputs.(sprintf('scenario_%d', j));
            station_loads = [station_loads, sum(scenario_data.service_coverage(i, :))];
        end
        load_balance(i) = std(station_loads) / mean(station_loads) * 100;
    end
    
    bar(load_balance, 'FaceColor', [0.8 0.5 0.3], 'EdgeColor', 'k');
    title('Station Load Variability', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Fire Stations', 'FontSize', 6);
    ylabel('Load Coefficient of Variation (%)', 'FontSize', 6);
    xticks(1:length(stations));
    xticklabels(stations);
    xtickangle(45);
    grid on;
    
    % 8. Station Performance Summary
    subplot(2, 4, 8);
    axis off;
    
    rectangle('Position', [0, 0, 1, 1], 'FaceColor', [0.95 0.95 0.95], 'EdgeColor', 'k');
    text(0.5, 0.95, 'STATION RANKINGS', 'FontWeight', 'bold', 'FontSize', 6, ...
        'HorizontalAlignment', 'center', 'Color', [0.1 0.1 0.5]);
    
    % Calculate overall performance scores
    overall_scores = mean(performance_metrics, 2);
    [~, ranking] = sort(overall_scores, 'descend');
    
    y_positions = 0.85:-0.15:0.15;
    for i = 1:min(length(stations), length(y_positions))
        station_idx = ranking(i);
        score = overall_scores(station_idx);
        
        text(0.05, y_positions(i), sprintf('%d. %s', i, stations{station_idx}), ...
            'FontSize', 6, 'FontWeight', 'bold', 'Color', 'k');
        text(0.65, y_positions(i), sprintf('Score: %.3f', score), ...
            'FontSize', 6, 'Color', 'k');
        
        % Performance indicator
        if score > 0.8
            indicator = '???';
            color = [0 0.6 0];
        elseif score > 0.6
            indicator = '???';
            color = [0.8 0.6 0];
        else
            indicator = '???';
            color = [0.8 0 0];
        end
        
        text(0.85, y_positions(i), indicator, 'FontSize', 6, 'Color', color);
    end
    
    sgtitle('Fire Station Performance Analysis Dashboard', ...
        'FontSize', 6, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
end

function createServiceRadarChart(service_outputs, scenario_idx, service_scenarios)
    % Create radar chart for service metrics
    if scenario_idx > length(service_scenarios)
        axis off;
        text(0.5, 0.5, 'No Data', 'HorizontalAlignment', 'center', 'FontSize', 6);
        return;
    end
    
    scenario_data = service_outputs.(sprintf('scenario_%d', scenario_idx));
    
    % Calculate metrics
    avg_response = mean(scenario_data.response_times(:));
    max_response = max(scenario_data.response_times(:));
    total_coverage = sum(scenario_data.service_coverage(:));
    avg_efficiency = mean(scenario_data.service_efficiency(:));
    
    % Normalize metrics (0-1 scale, higher is better)
    metrics = [
        1 - (avg_response / 15), ... % Normalized response time (assume max 15 min)
        1 - (max_response / 20), ... % Normalized max response time
        total_coverage / 50, ...     % Normalized coverage
        avg_efficiency / 5           % Normalized efficiency
    ];
    
    % Ensure values are between 0 and 1
    metrics = max(0, min(1, metrics));
    
    % Create simple bar chart as radar alternative
    metric_names = {'Avg Response', 'Max Response', 'Coverage', 'Efficiency'};
    bar(metrics, 'FaceColor', [0.4 0.6 0.8], 'EdgeColor', 'k');
    title(sprintf('%s\nMetrics', service_scenarios{scenario_idx}), 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Metrics', 'FontSize', 6);
    ylabel('Normalized Score', 'FontSize', 6);
    xticks(1:4);
    xticklabels(metric_names);
    xtickangle(45);
    ylim([0 1]);
    grid on;
    set(gca, 'FontSize', 6);
end

function createStationRadarChart(service_outputs, stations, service_scenarios)
    % Create radar chart showing station coverage across regions
    coverage_data = zeros(length(stations), 1);
    
    % Use normal operations data
    scenario1_data = service_outputs.scenario_1;
    for i = 1:length(stations)
        coverage_data(i) = mean(scenario1_data.service_coverage(i, :));
    end
    
    bar(coverage_data, 'FaceColor', [0.6 0.4 0.8], 'EdgeColor', 'k');
    title('Average Station Coverage', 'FontSize', 6, 'FontWeight', 'bold');
    xlabel('Fire Stations', 'FontSize', 6);
    ylabel('Coverage Index', 'FontSize', 6);
    xticks(1:length(stations));
    xticklabels(stations);
    xtickangle(45);
    grid on;
    set(gca, 'FontSize', 6);
end

function cmap = viridis_colormap()
    % Create a viridis-like colormap
    n = 64;
    x = linspace(0, 1, n);
    
    % Viridis color points
    r = 0.267004 + x.*(0.127568 + x.*(-0.24292 + x.*(0.27581 + x.*(-0.142061 + x.*(-0.11567)))));
    g = 0.004874 + x.*(0.221343 + x.*(0.319397 + x.*(-0.29796 + x.*(-0.01478 + x.*(0.066814)))));
    b = 0.329415 + x.*(0.531833 + x.*(-0.65289 + x.*(0.226417 + x.*(0.087194 + x.*(-0.04356)))));
    
    cmap = [r' g' b'];
end