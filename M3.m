clc; clear; close all;

% -------------------------------
% 1. Data Setup (from paper)
% -------------------------------

numStations = 5;
numRegions = 7;
stations = {'S1','S2','S3','S4','S5'};
regions = {'R1','R2','R3','R4','R5','R6','R7'};

% Distance matrix (from manuscript, km)
D = [
    2.5, 3.0, 4.2, 5.1, 6.0, 7.5, 3.2;
    3.1, 2.2, 3.8, 4.5, 5.3, 6.9, 2.8;
    4.0, 3.5, 2.0, 3.0, 4.1, 5.5, 3.0;
    5.2, 4.1, 3.1, 2.5, 3.6, 4.8, 4.0;
    6.3, 5.0, 4.0, 3.1, 2.3, 3.7, 5.0
];

% Average speed (km/min)
speed_kmpm = 52.5 / 60;

% Base response time matrix
Time = D / speed_kmpm;

% ------------------------------------------
% 2. Scenario: Dynamic Penalty Matrix
% ------------------------------------------

% Start with no penalty
Penalty = ones(size(Time));

% Apply scenario-based dynamic penalties
Penalty(1,6) = 1 + rand()*4;              % S1 to R6 - possible road issue (1–5x)
Penalty(5,:) = 1 + rand(1,7)*2;           % S5 - vehicle issues, varies across all regions

% Add global noise to introduce diversity
Penalty = Penalty + 0.1*rand(size(Penalty));

% Combined time-cost matrix
Cost = Time .* Penalty;

% ------------------------------------------
% 3. GA Setup
% ------------------------------------------

nVars = numStations * numRegions;

% Fitness function
fitnessFcn = @(x) sum(sum(Cost .* reshape(x, numStations, numRegions)));

% Constraints: Each region must be covered by at least one station
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

% Variable bounds and binary type
lb = zeros(nVars,1);
ub = ones(nVars,1);
IntCon = 1:nVars;

% GA options
opts = optimoptions('ga', ...
    'Display','iter', ...
    'PopulationSize', 100, ...
    'MaxGenerations', 20, ...
    'PlotFcn', {@gaplotbestf, @gaplotscores}, ...
    'UseParallel', false);

% ------------------------------------------
% 4. Run Genetic Algorithm
% ------------------------------------------

[xopt, fval, ~, output, population, scores] = ...
    ga(fitnessFcn, nVars, A_ineq, b_ineq, [], [], lb, ub, [], IntCon, opts);

assignment = reshape(round(xopt), numStations, numRegions);

% ------------------------------------------
% 5. Output & Visualization
% ------------------------------------------

disp('Optimal Assignment (1 = station covers region):');
disp(array2table(assignment, 'RowNames', stations, 'VariableNames', regions));
disp(['Total Optimized Response Time (with smart penalties): ' num2str(fval, '%.2f') ' minutes']);
disp('GA Summary:');
disp(output);

% Colorful matrix plot with labels
figure;
imagesc(assignment);
colormap(jet);
colorbar;
title('Station-to-Region Assignment (Smart Penalty)');
xlabel('Regions'); ylabel('Stations');
xticks(1:numRegions); xticklabels(regions);
yticks(1:numStations); yticklabels(stations);

% Add annotation text
for i = 1:numStations
    for j = 1:numRegions
        text(j, i, num2str(assignment(i,j)), ...
            'FontSize', 12, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', ...
            'Color', 'white');
    end
end

% Histogram of fitness values in final population
figure;
histogram(scores, 15);
title('Fitness Score Distribution (Final Population)');
xlabel('Total Cost (min)'); ylabel('Individuals');
grid on;
