clc; clear; close all;
warning('off', 'all'); % Suppress warnings for cleaner output

% ========================================================================
% DYNAMIC SENSITIVITY ANALYSIS DASHBOARD FOR GA OPTIMIZATION
% ========================================================================

%% 1. BASE DATA SETUP
numStations = 5;
numRegions = 7;
stations = {'S1','S2','S3','S4','S5'};
regions = {'R1','R2','R3','R4','R5','R6','R7'};

% Distance matrix (km)
D = [
    2.5, 3.0, 4.2, 5.1, 6.0, 7.5, 3.2;
    3.1, 2.2, 3.8, 4.5, 5.3, 6.9, 2.8;
    4.0, 3.5, 2.0, 3.0, 4.1, 5.5, 3.0;
    5.2, 4.1, 3.1, 2.5, 3.6, 4.8, 4.0;
    6.3, 5.0, 4.0, 3.1, 2.3, 3.7, 5.0
];

base_speed_kmpm = 52.5 / 60;
base_Time = D / base_speed_kmpm;

%% 2. SENSITIVITY ANALYSIS PARAMETERS
% GA Parameters to analyze
pop_sizes = [20, 50, 100, 200, 300];
max_generations = [10, 20, 50, 100, 150];
mutation_rates = [0.01, 0.05, 0.1, 0.2, 0.3];
crossover_fractions = [0.6, 0.7, 0.8, 0.9, 0.95];

% System Parameters
speed_variations = [0.5, 0.75, 1.0, 1.25, 1.5]; % Speed multipliers
traffic_scenarios = [1, 2, 3, 4, 5]; % Different traffic patterns
penalty_intensities = [0.1, 0.5, 1.0, 2.0, 5.0]; % Penalty severity

% Results storage
results = struct();
param_names = {'PopSize', 'MaxGen', 'MutRate', 'CrossFrac', 'Speed', 'Traffic', 'Penalty'};

%% 3. MAIN SENSITIVITY ANALYSIS LOOP
fprintf('=== STARTING COMPREHENSIVE SENSITIVITY ANALYSIS ===\n');
fprintf('Total runs: %d\n', length(pop_sizes) + length(max_generations) + ...
    length(mutation_rates) + length(crossover_fractions) + ...
    length(speed_variations) + length(traffic_scenarios) + length(penalty_intensities));

run_counter = 0;
total_runs = length(pop_sizes) + length(max_generations) + length(mutation_rates) + ...
    length(crossover_fractions) + length(speed_variations) + length(traffic_scenarios) + length(penalty_intensities);

%% 3.1 Population Size Sensitivity
fprintf('\n--- Analyzing Population Size Impact ---\n');
results.PopSize.params = pop_sizes;
results.PopSize.fitness = zeros(size(pop_sizes));
results.PopSize.time = zeros(size(pop_sizes));
results.PopSize.generations = zeros(size(pop_sizes));

for i = 1:length(pop_sizes)
    run_counter = run_counter + 1;
    fprintf('Run %d/%d: PopSize = %d\n', run_counter, total_runs, pop_sizes(i));
    
    [Cost, ~] = generateCostMatrix(D, base_speed_kmpm, 1, 1);
    tic;
    [~, fval, ~, output] = runGA(Cost, numStations, numRegions, ...
        pop_sizes(i), 50, 0.1, 0.8);
    results.PopSize.time(i) = toc;
    results.PopSize.fitness(i) = fval;
    results.PopSize.generations(i) = output.generations;
end

%% 3.2 Generation Limit Sensitivity
fprintf('\n--- Analyzing Generation Limit Impact ---\n');
results.MaxGen.params = max_generations;
results.MaxGen.fitness = zeros(size(max_generations));
results.MaxGen.time = zeros(size(max_generations));
results.MaxGen.generations = zeros(size(max_generations));

for i = 1:length(max_generations)
    run_counter = run_counter + 1;
    fprintf('Run %d/%d: MaxGen = %d\n', run_counter, total_runs, max_generations(i));
    
    [Cost, ~] = generateCostMatrix(D, base_speed_kmpm, 1, 1);
    tic;
    [~, fval, ~, output] = runGA(Cost, numStations, numRegions, ...
        100, max_generations(i), 0.1, 0.8);
    results.MaxGen.time(i) = toc;
    results.MaxGen.fitness(i) = fval;
    results.MaxGen.generations(i) = output.generations;
end

%% 3.3 Mutation Rate Sensitivity
fprintf('\n--- Analyzing Mutation Rate Impact ---\n');
results.MutRate.params = mutation_rates;
results.MutRate.fitness = zeros(size(mutation_rates));
results.MutRate.time = zeros(size(mutation_rates));
results.MutRate.generations = zeros(size(mutation_rates));

for i = 1:length(mutation_rates)
    run_counter = run_counter + 1;
    fprintf('Run %d/%d: MutRate = %.3f\n', run_counter, total_runs, mutation_rates(i));
    
    [Cost, ~] = generateCostMatrix(D, base_speed_kmpm, 1, 1);
    tic;
    [~, fval, ~, output] = runGA(Cost, numStations, numRegions, ...
        100, 50, mutation_rates(i), 0.8);
    results.MutRate.time(i) = toc;
    results.MutRate.fitness(i) = fval;
    results.MutRate.generations(i) = output.generations;
end

%% 3.4 Crossover Fraction Sensitivity
fprintf('\n--- Analyzing Crossover Fraction Impact ---\n');
results.CrossFrac.params = crossover_fractions;
results.CrossFrac.fitness = zeros(size(crossover_fractions));
results.CrossFrac.time = zeros(size(crossover_fractions));
results.CrossFrac.generations = zeros(size(crossover_fractions));

for i = 1:length(crossover_fractions)
    run_counter = run_counter + 1;
    fprintf('Run %d/%d: CrossFrac = %.2f\n', run_counter, total_runs, crossover_fractions(i));
    
    [Cost, ~] = generateCostMatrix(D, base_speed_kmpm, 1, 1);
    tic;
    [~, fval, ~, output] = runGA(Cost, numStations, numRegions, ...
        100, 50, 0.1, crossover_fractions(i));
    results.CrossFrac.time(i) = toc;
    results.CrossFrac.fitness(i) = fval;
    results.CrossFrac.generations(i) = output.generations;
end

%% 3.5 Speed Variation Sensitivity
fprintf('\n--- Analyzing Speed Variation Impact ---\n');
results.Speed.params = speed_variations;
results.Speed.fitness = zeros(size(speed_variations));
results.Speed.time = zeros(size(speed_variations));
results.Speed.generations = zeros(size(speed_variations));

for i = 1:length(speed_variations)
    run_counter = run_counter + 1;
    fprintf('Run %d/%d: Speed Mult = %.2f\n', run_counter, total_runs, speed_variations(i));
    
    [Cost, ~] = generateCostMatrix(D, base_speed_kmpm * speed_variations(i), 1, 1);
    tic;
    [~, fval, ~, output] = runGA(Cost, numStations, numRegions, ...
        100, 50, 0.1, 0.8);
    results.Speed.time(i) = toc;
    results.Speed.fitness(i) = fval;
    results.Speed.generations(i) = output.generations;
end

%% 3.6 Traffic Scenario Sensitivity
fprintf('\n--- Analyzing Traffic Scenario Impact ---\n');
results.Traffic.params = traffic_scenarios;
results.Traffic.fitness = zeros(size(traffic_scenarios));
results.Traffic.time = zeros(size(traffic_scenarios));
results.Traffic.generations = zeros(size(traffic_scenarios));

for i = 1:length(traffic_scenarios)
    run_counter = run_counter + 1;
    fprintf('Run %d/%d: Traffic Scenario = %d\n', run_counter, total_runs, traffic_scenarios(i));
    
    [Cost, ~] = generateCostMatrix(D, base_speed_kmpm, traffic_scenarios(i), 1);
    tic;
    [~, fval, ~, output] = runGA(Cost, numStations, numRegions, ...
        100, 50, 0.1, 0.8);
    results.Traffic.time(i) = toc;
    results.Traffic.fitness(i) = fval;
    results.Traffic.generations(i) = output.generations;
end

%% 3.7 Penalty Intensity Sensitivity
fprintf('\n--- Analyzing Penalty Intensity Impact ---\n');
results.Penalty.params = penalty_intensities;
results.Penalty.fitness = zeros(size(penalty_intensities));
results.Penalty.time = zeros(size(penalty_intensities));
results.Penalty.generations = zeros(size(penalty_intensities));

for i = 1:length(penalty_intensities)
    run_counter = run_counter + 1;
    fprintf('Run %d/%d: Penalty Intensity = %.1f\n', run_counter, total_runs, penalty_intensities(i));
    
    [Cost, ~] = generateCostMatrix(D, base_speed_kmpm, 1, penalty_intensities(i));
    tic;
    [~, fval, ~, output] = runGA(Cost, numStations, numRegions, ...
        100, 50, 0.1, 0.8);
    results.Penalty.time(i) = toc;
    results.Penalty.fitness(i) = fval;
    results.Penalty.generations(i) = output.generations;
end

%% 4. CREATE DYNAMIC DASHBOARD
fprintf('\n=== CREATING DYNAMIC SENSITIVITY DASHBOARD ===\n');
createSensitivityDashboard(results, param_names, stations, regions);

%% 5. ADDITIONAL ANALYSIS: PARAMETER INTERACTIONS
fprintf('\n=== ANALYZING PARAMETER INTERACTIONS ===\n');
createInteractionAnalysis(D, base_speed_kmpm, numStations, numRegions);

%% 6. STATISTICAL ANALYSIS AND RECOMMENDATIONS
fprintf('\n=== GENERATING RECOMMENDATIONS ===\n');
generateRecommendations(results);

fprintf('\n=== SENSITIVITY ANALYSIS COMPLETE ===\n');

%% ========================================================================
%% SUPPORTING FUNCTIONS
%% ========================================================================

function [Cost, Penalty] = generateCostMatrix(D, speed_kmpm, traffic_scenario, penalty_intensity)
    Time = D / speed_kmpm;
    Penalty = ones(size(Time));
    
    % Apply traffic scenario effects
    switch traffic_scenario
        case 1 % Light traffic
            Penalty = Penalty + 0.1 * penalty_intensity * rand(size(Penalty));
        case 2 % Moderate traffic
            Penalty(1,6) = 1 + penalty_intensity * rand();
            Penalty = Penalty + 0.2 * penalty_intensity * rand(size(Penalty));
        case 3 % Heavy traffic
            Penalty(1,6) = 1 + 2 * penalty_intensity * rand();
            Penalty(5,:) = 1 + penalty_intensity * rand(1,7);
            Penalty = Penalty + 0.3 * penalty_intensity * rand(size(Penalty));
        case 4 % Congested traffic
            Penalty(1,:) = 1 + penalty_intensity * rand(1,7);
            Penalty(:,7) = 1 + penalty_intensity * rand(5,1);
            Penalty = Penalty + 0.4 * penalty_intensity * rand(size(Penalty));
        case 5 % Critical traffic
            Penalty = 1 + penalty_intensity * rand(size(Penalty));
    end
    
    Cost = Time .* Penalty;
end

function [xopt, fval, exitflag, output] = runGA(Cost, numStations, numRegions, ...
    popSize, maxGen, mutRate, crossFrac)
    
    nVars = numStations * numRegions;
    fitnessFcn = @(x) sum(sum(Cost .* reshape(x, numStations, numRegions)));
    
    % Constraints
    A_ineq = [];
    b_ineq = [];
    for j = 1:numRegions
        row = zeros(1, nVars);
        for i = 1:numStations
            row((i-1)*numRegions + j) = -1;
        end
        A_ineq = [A_ineq; row];
        b_ineq = [b_ineq; -1];
    end
    
    lb = zeros(nVars,1);
    ub = ones(nVars,1);
    IntCon = 1:nVars;
    
    opts = optimoptions('ga', ...
        'Display','off', ...
        'PopulationSize', popSize, ...
        'MaxGenerations', maxGen, ...
        'MutationFcn', {@mutationuniform, mutRate}, ...
        'CrossoverFraction', crossFrac, ...
        'UseParallel', false);
    
    [xopt, fval, exitflag, output] = ga(fitnessFcn, nVars, A_ineq, b_ineq, ...
        [], [], lb, ub, [], IntCon, opts);
end

function createSensitivityDashboard(results, param_names, stations, regions)
    % Create main dashboard figure with better font settings
    fig = figure('Position', [50, 50, 1800, 1400], 'Name', 'GA Sensitivity Analysis Dashboard');
    set(fig, 'DefaultAxesFontSize', 10);
    set(fig, 'DefaultTextFontSize', 10);
    set(fig, 'DefaultAxesFontName', 'Arial');
    set(fig, 'DefaultTextFontName', 'Arial');
    
    % Define colors for consistency
    colors = lines(length(param_names));
    
    % 1. Fitness Sensitivity Overview (3D Surface)
    subplot(4, 4, [1, 2]);
    param_indices = 1:length(param_names);
    fitness_matrix = zeros(length(param_names), 5);
    
    for i = 1:length(param_names)
        field = param_names{i};
        if isfield(results, field)
            fitness_vals = results.(field).fitness;
            if length(fitness_vals) >= 5
                fitness_matrix(i, :) = fitness_vals(1:5);
            else
                fitness_matrix(i, 1:length(fitness_vals)) = fitness_vals;
            end
        end
    end
    
    imagesc(fitness_matrix);
    colormap(hot);
    c1 = colorbar;
    c1.Label.String = 'Fitness Value';
    c1.Label.FontSize = 10;
    title('Fitness Sensitivity Heatmap', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
    xlabel('Parameter Value Index', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Parameters', 'FontSize', 12, 'FontWeight', 'bold');
    yticks(1:length(param_names));
    yticklabels(param_names);
    set(gca, 'FontSize', 11);
    
    % 2. Computational Time Analysis
    subplot(4, 4, 3);
    time_data = [];
    time_labels = {};
    for i = 1:length(param_names)
        field = param_names{i};
        if isfield(results, field)
            time_data = [time_data; mean(results.(field).time)];
            time_labels{end+1} = field;
        end
    end
    
    pie(time_data, time_labels);
    title('Computational Time Distribution', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
    set(gca, 'FontSize', 10);
    
    % 3. Convergence Analysis
    subplot(4, 4, 4);
    gen_data = [];
    gen_labels = {};
    for i = 1:length(param_names)
        field = param_names{i};
        if isfield(results, field)
            gen_data = [gen_data; mean(results.(field).generations)];
            gen_labels{end+1} = field;
        end
    end
    
    bar(gen_data, 'FaceColor', [0.2 0.6 0.8], 'EdgeColor', 'k', 'LineWidth', 1);
    title('Average Generations to Convergence', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
    xlabel('Parameters', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Generations', 'FontSize', 11, 'FontWeight', 'bold');
    xticks(1:length(gen_labels));
    xticklabels(gen_labels);
    xtickangle(45);
    set(gca, 'FontSize', 10);
    grid on; grid minor;
    
    % 4-7. Individual Parameter Analysis
    subplot_positions = [5, 6, 7, 8, 9, 10, 11];
    for i = 1:min(length(param_names), 7)
        field = param_names{i};
        if isfield(results, field)
            subplot(4, 4, subplot_positions(i));
            
            params = results.(field).params;
            fitness = results.(field).fitness;
            
            plot(params, fitness, 'o-', 'Color', colors(i,:), ...
                'LineWidth', 3, 'MarkerSize', 10, 'MarkerFaceColor', colors(i,:), ...
                'MarkerEdgeColor', 'k');
            grid on; grid minor;
            title([field ' Sensitivity'], 'FontSize', 13, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
            xlabel('Parameter Value', 'FontSize', 10, 'FontWeight', 'bold');
            ylabel('Fitness (Cost)', 'FontSize', 10, 'FontWeight', 'bold');
            set(gca, 'FontSize', 9);
            
            % Add trend line
            if length(params) > 2
                p = polyfit(params, fitness, 1);
                trend_y = polyval(p, params);
                hold on;
                plot(params, trend_y, '--', 'Color', colors(i,:), 'LineWidth', 2);
                hold off;
            end
        end
    end
    
    % 12. Performance Radar Chart
    subplot(4, 4, 12);
    createRadarChart(results, param_names);
    
    % 13. Statistical Summary
    subplot(4, 4, 13);
    axis off;
    % Create a clean background
    rectangle('Position', [0, 0, 1, 1], 'FaceColor', [0.95 0.95 0.95], 'EdgeColor', 'k');
    text(0.5, 0.95, 'STATISTICAL SUMMARY', 'FontWeight', 'bold', 'FontSize', 14, ...
        'HorizontalAlignment', 'center', 'Color', [0.1 0.1 0.5]);
    
    y_pos = 0.85;
    for i = 1:min(length(param_names), 6) % Limit to 6 to avoid overcrowding
        field = param_names{i};
        if isfield(results, field)
            fitness = results.(field).fitness;
            cv = std(fitness) / mean(fitness) * 100; % Coefficient of variation
            text(0.05, y_pos, sprintf('• %s: CV = %.1f%%', field, cv), ...
                'FontSize', 11, 'FontWeight', 'normal', 'Color', 'k');
            y_pos = y_pos - 0.12;
        end
    end
    
    % 14. Optimization Efficiency
    subplot(4, 4, 14);
    efficiency_data = [];
    efficiency_labels = {};
    for i = 1:length(param_names)
        field = param_names{i};
        if isfield(results, field)
            fitness = results.(field).fitness;
            time = results.(field).time;
            efficiency = 1 ./ (fitness .* time); % Higher is better
            efficiency_data = [efficiency_data; mean(efficiency)];
            efficiency_labels{end+1} = field;
        end
    end
    
    bar(efficiency_data, 'FaceColor', [0.8 0.2 0.4], 'EdgeColor', 'k', 'LineWidth', 1);
    title('Optimization Efficiency', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
    xlabel('Parameters', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Efficiency (1/Cost·Time)', 'FontSize', 11, 'FontWeight', 'bold');
    xticks(1:length(efficiency_labels));
    xticklabels(efficiency_labels);
    xtickangle(45);
    set(gca, 'FontSize', 10);
    grid on; grid minor;
    
    % 15. Best Configuration Display
    subplot(4, 4, 15);
    axis off;
    % Create a clean background
    rectangle('Position', [0, 0, 1, 1], 'FaceColor', [0.95 0.95 0.95], 'EdgeColor', 'k');
    text(0.5, 0.95, 'OPTIMAL CONFIGURATIONS', 'FontWeight', 'bold', 'FontSize', 14, ...
        'HorizontalAlignment', 'center', 'Color', [0.1 0.1 0.5]);
    
    y_pos = 0.85;
    for i = 1:min(length(param_names), 6) % Limit to 6 to avoid overcrowding
        field = param_names{i};
        if isfield(results, field)
            [min_val, min_idx] = min(results.(field).fitness);
            opt_param = results.(field).params(min_idx);
            text(0.05, y_pos, sprintf('• %s: %.3f (Cost: %.2f)', field, opt_param, min_val), ...
                'FontSize', 11, 'FontWeight', 'normal', 'Color', 'k');
            y_pos = y_pos - 0.12;
        end
    end
    
    % 16. Robustness Analysis
    subplot(4, 4, 16);
    robustness_scores = [];
    robustness_labels = {};
    for i = 1:length(param_names)
        field = param_names{i};
        if isfield(results, field)
            fitness = results.(field).fitness;
            robustness = 1 / std(fitness); % Lower std = higher robustness
            robustness_scores = [robustness_scores; robustness];
            robustness_labels{end+1} = field;
        end
    end
    
    barh(robustness_scores, 'FaceColor', [0.2 0.8 0.2], 'EdgeColor', 'k', 'LineWidth', 1);
    title('Parameter Robustness', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
    ylabel('Parameters', 'FontSize', 11, 'FontWeight', 'bold');
    xlabel('Robustness Score', 'FontSize', 11, 'FontWeight', 'bold');
    yticks(1:length(robustness_labels));
    yticklabels(robustness_labels);
    set(gca, 'FontSize', 10);
    grid on; grid minor;
    
    % Main title with better formatting
    sgtitle('GA Fire Station Optimization - Comprehensive Sensitivity Dashboard', ...
        'FontSize', 20, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
    
    % Adjust spacing between subplots
    set(fig, 'Units', 'normalized');
    tightfig(fig);
end

function createRadarChart(results, param_names)
    % Create custom radar chart with improved fonts
    angles = linspace(0, 2*pi, length(param_names)+1);
    
    % Normalize all metrics to 0-1 scale
    normalized_fitness = [];
    normalized_time = [];
    normalized_generations = [];
    
    for i = 1:length(param_names)
        field = param_names{i};
        if isfield(results, field)
            fitness = results.(field).fitness;
            time = results.(field).time;
            generations = results.(field).generations;
            
            if ~isempty(fitness) && max(fitness) > 0
                normalized_fitness(i) = (max(fitness) - min(fitness)) / max(fitness);
            else
                normalized_fitness(i) = 0;
            end
            
            if ~isempty(time) && max(time) > 0
                normalized_time(i) = (max(time) - min(time)) / max(time);
            else
                normalized_time(i) = 0;
            end
            
            if ~isempty(generations) && max(generations) > 0
                normalized_generations(i) = (max(generations) - min(generations)) / max(generations);
            else
                normalized_generations(i) = 0;
            end
        else
            normalized_fitness(i) = 0;
            normalized_time(i) = 0;
            normalized_generations(i) = 0;
        end
    end
    
    % Close the polygon
    normalized_fitness(end+1) = normalized_fitness(1);
    normalized_time(end+1) = normalized_time(1);
    normalized_generations(end+1) = normalized_generations(1);
    
    % Check MATLAB version and use appropriate function
    if exist('polarplot', 'file') == 2
        % Use modern polarplot function (R2016a and later)
        polarplot(angles, normalized_fitness, 'r-o', 'LineWidth', 3, 'MarkerSize', 8);
        hold on;
        polarplot(angles, normalized_time, 'b-s', 'LineWidth', 3, 'MarkerSize', 8);
        polarplot(angles, normalized_generations, 'g-^', 'LineWidth', 3, 'MarkerSize', 8);
        hold off;
        
        % Add parameter labels
        thetalim([0 360]);
        rlim([0 1]);
        
        % Set theta tick labels to parameter names
        theta_degrees = angles(1:end-1) * 180/pi;
        thetaticks(theta_degrees);
        thetaticklabels(param_names);
        
        title('Multi-Metric Sensitivity Radar', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
        legend({'Fitness Range', 'Time Range', 'Generation Range'}, 'Location', 'best', 'FontSize', 10);
        
        % Improve axis fonts
        ax = gca;
        ax.FontSize = 10;
        ax.RTickLabel = {'0.2', '0.4', '0.6', '0.8', '1.0'};
        
    else
        % Fallback: Create manual radar chart using Cartesian coordinates
        % Convert polar to cartesian
        x_fitness = normalized_fitness .* cos(angles);
        y_fitness = normalized_fitness .* sin(angles);
        x_time = normalized_time .* cos(angles);
        y_time = normalized_time .* sin(angles);
        x_gen = normalized_generations .* cos(angles);
        y_gen = normalized_generations .* sin(angles);
        
        % Plot the radar chart manually with better styling
        plot(x_fitness, y_fitness, 'r-o', 'LineWidth', 3, 'MarkerSize', 8, 'MarkerFaceColor', 'r');
        hold on;
        plot(x_time, y_time, 'b-s', 'LineWidth', 3, 'MarkerSize', 8, 'MarkerFaceColor', 'b');
        plot(x_gen, y_gen, 'g-^', 'LineWidth', 3, 'MarkerSize', 8, 'MarkerFaceColor', 'g');
        
        % Add circular grid with better styling
        theta_grid = linspace(0, 2*pi, 100);
        for r = 0.2:0.2:1
            plot(r*cos(theta_grid), r*sin(theta_grid), 'k:', 'LineWidth', 1);
            % Add radial labels
            if r == 1
                text(1.05, 0, '1.0', 'HorizontalAlignment', 'left', 'FontSize', 9, 'FontWeight', 'bold');
            elseif r == 0.6
                text(0.63, 0, '0.6', 'HorizontalAlignment', 'center', 'FontSize', 8);
            end
        end
        
        % Add radial lines
        for i = 1:length(param_names)
            angle = angles(i);
            plot([0, cos(angle)], [0, sin(angle)], 'k:', 'LineWidth', 1);
            % Add parameter labels with better positioning
            label_radius = 1.25;
            text(label_radius*cos(angle), label_radius*sin(angle), param_names{i}, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
        end
        
        % Add center point
        plot(0, 0, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
        
        hold off;
        axis equal;
        axis([-1.4 1.4 -1.4 1.4]);
        axis off;
        
        title('Multi-Metric Sensitivity Radar', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
        legend({'Fitness Range', 'Time Range', 'Generation Range'}, 'Location', 'best', ...
            'FontSize', 10, 'Box', 'on', 'EdgeColor', 'k');
    end
end

function createInteractionAnalysis(D, base_speed_kmpm, numStations, numRegions)
    % Analyze interactions between key parameters with improved fonts
    figure('Position', [100, 100, 1600, 900], 'Name', 'Parameter Interaction Analysis');
    
    % Set default font properties for this figure
    set(gcf, 'DefaultAxesFontSize', 11);
    set(gcf, 'DefaultTextFontSize', 11);
    set(gcf, 'DefaultAxesFontName', 'Arial');
    set(gcf, 'DefaultTextFontName', 'Arial');
    
    % Test parameter combinations
    pop_sizes = [50, 100, 200];
    generations = [20, 50, 100];
    
    interaction_results = zeros(length(pop_sizes), length(generations));
    
    fprintf('Computing parameter interactions...\n');
    for i = 1:length(pop_sizes)
        for j = 1:length(generations)
            [Cost, ~] = generateCostMatrix(D, base_speed_kmpm, 2, 1);
            [~, fval, ~, ~] = runGA(Cost, numStations, numRegions, ...
                pop_sizes(i), generations(j), 0.1, 0.8);
            interaction_results(i, j) = fval;
            fprintf('  PopSize: %d, Generations: %d, Fitness: %.2f\n', ...
                pop_sizes(i), generations(j), fval);
        end
    end
    
    % 3D Surface plot
    subplot(2, 2, 1);
    [X, Y] = meshgrid(generations, pop_sizes);
    surf(X, Y, interaction_results, 'EdgeColor', 'k', 'LineWidth', 0.5);
    colormap(jet);
    c1 = colorbar;
    c1.Label.String = 'Fitness Value';
    c1.Label.FontSize = 11;
    xlabel('Generations', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Population Size', 'FontSize', 12, 'FontWeight', 'bold');
    zlabel('Fitness (Cost)', 'FontSize', 12, 'FontWeight', 'bold');
    title('Population Size × Generations Interaction', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
    set(gca, 'FontSize', 10);
    view(45, 30);
    grid on;
    
    % Contour plot
    subplot(2, 2, 2);
    [C, h] = contourf(X, Y, interaction_results, 20);
    clabel(C, h, 'FontSize', 9, 'Color', 'k', 'FontWeight', 'bold');
    c2 = colorbar;
    c2.Label.String = 'Fitness Value';
    c2.Label.FontSize = 11;
    xlabel('Generations', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Population Size', 'FontSize', 12, 'FontWeight', 'bold');
    title('Interaction Contour Map', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
    set(gca, 'FontSize', 10);
    
    % Heatmap
    subplot(2, 2, 3);
    imagesc(interaction_results);
    colormap(hot);
    c3 = colorbar;
    c3.Label.String = 'Fitness Value';
    c3.Label.FontSize = 11;
    xlabel('Generations Index', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Population Size Index', 'FontSize', 12, 'FontWeight', 'bold');
    title('Interaction Heatmap', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
    xticks(1:length(generations));
    xticklabels(generations);
    yticks(1:length(pop_sizes));
    yticklabels(pop_sizes);
    set(gca, 'FontSize', 10);
    
    % Add text annotations on heatmap
    for i = 1:length(pop_sizes)
        for j = 1:length(generations)
            text(j, i, sprintf('%.1f', interaction_results(i,j)), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'Color', 'white', 'FontSize', 10, 'FontWeight', 'bold');
        end
    end
    
    % Optimization landscape
    subplot(2, 2, 4);
    scatter3(X(:), Y(:), interaction_results(:), 100, interaction_results(:), ...
        'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1);
    colormap(jet);
    c4 = colorbar;
    c4.Label.String = 'Fitness Value';
    c4.Label.FontSize = 11;
    xlabel('Generations', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Population Size', 'FontSize', 12, 'FontWeight', 'bold');
    zlabel('Fitness (Cost)', 'FontSize', 12, 'FontWeight', 'bold');
    title('Parameter Space Exploration', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
    set(gca, 'FontSize', 10);
    view(45, 30);
    grid on;
    
    % Add optimal point annotation
    [min_val, min_idx] = min(interaction_results(:));
    [min_i, min_j] = ind2sub(size(interaction_results), min_idx);
    optimal_pop = pop_sizes(min_i);
    optimal_gen = generations(min_j);
    
    hold on;
    scatter3(optimal_gen, optimal_pop, min_val, 200, 'r', 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 2);
    text(optimal_gen, optimal_pop, min_val + 0.5, ...
        sprintf('Optimal\n(%d,%d)', optimal_pop, optimal_gen), ...
        'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold', ...
        'BackgroundColor', 'white', 'EdgeColor', 'k');
    hold off;
    
    sgtitle('GA Parameter Interaction Analysis', 'FontSize', 18, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.5]);
    
    % Print interaction summary
    fprintf('\n=== PARAMETER INTERACTION SUMMARY ===\n');
    fprintf('Optimal combination: PopSize = %d, Generations = %d\n', optimal_pop, optimal_gen);
    fprintf('Best fitness value: %.3f\n', min_val);
    fprintf('Fitness range: %.3f - %.3f\n', min(interaction_results(:)), max(interaction_results(:)));
    fprintf('Standard deviation: %.3f\n', std(interaction_results(:)));
end

% Helper function to tighten figure layout
function tightfig(fig)
    % Get all axes handles
    ax = findall(fig, 'type', 'axes');
    
    % Adjust positions for better spacing
    for i = 1:length(ax)
        pos = get(ax(i), 'Position');
        % Slightly reduce margins
        pos(1) = pos(1) + 0.01; % left margin
        pos(2) = pos(2) + 0.01; % bottom margin
        pos(3) = pos(3) - 0.02; % width reduction
        pos(4) = pos(4) - 0.02; % height reduction
        set(ax(i), 'Position', pos);
    end
end

function generateRecommendations(results)
    fprintf('\n========== GA OPTIMIZATION RECOMMENDATIONS ==========\n');
    
    % Find best parameters for each category
    for i = 1:length(fieldnames(results))
        fields = fieldnames(results);
        field = fields{i};
        
        fitness = results.(field).fitness;
        time = results.(field).time;
        params = results.(field).params;
        
        [min_fitness, min_idx] = min(fitness);
        best_param = params(min_idx);
        avg_time = mean(time);
        
        fprintf('\n%s Analysis:\n', field);
        fprintf('  Best Parameter Value: %.3f\n', best_param);
        fprintf('  Best Fitness: %.3f\n', min_fitness);
        fprintf('  Average Computation Time: %.3f seconds\n', avg_time);
        fprintf('  Coefficient of Variation: %.2f%%\n', std(fitness)/mean(fitness)*100);
        
        % Provide specific recommendations
        switch field
            case 'PopSize'
                if best_param < 100
                    fprintf('  Recommendation: Consider larger population for better exploration\n');
                else
                    fprintf('  Recommendation: Current population size is adequate\n');
                end
            case 'MaxGen'
                if min_idx == length(params)
                    fprintf('  Recommendation: May benefit from more generations\n');
                else
                    fprintf('  Recommendation: Current generation limit is sufficient\n');
                end
            case 'MutRate'
                if best_param < 0.05
                    fprintf('  Recommendation: Low mutation rate - good for exploitation\n');
                else
                    fprintf('  Recommendation: Higher mutation rate - good for exploration\n');
                end
        end
    end
    
    fprintf('\n========== OVERALL RECOMMENDATIONS ==========\n');
    fprintf('1. Use moderate population sizes (100-200) for balanced performance\n');
    fprintf('2. Allow sufficient generations (50-100) for convergence\n');
    fprintf('3. Keep mutation rates low (0.05-0.15) for stability\n');
    fprintf('4. Use high crossover fractions (0.8-0.9) for good mixing\n');
    fprintf('5. Consider traffic scenarios in real-world deployment\n');
    fprintf('======================================================\n');
end