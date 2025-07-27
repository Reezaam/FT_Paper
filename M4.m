% Cost-Benefit Analysis Tool for Proposed Fire Stations
clc; clear;

% --- Define Initial Inputs ---
n_years = 20;                  
discount_rate = 0.05;          

% Setup Costs for each proposed station (Million IRR)
setup_costs = [1500, 1800];    

% Annual Savings (Million IRR)
fuel_savings = [80, 95];       
maintenance_savings = [60, 70];
personnel_savings = [100, 110];

% Total Annual Savings
annual_savings = fuel_savings + maintenance_savings + personnel_savings;

% --- NPV Calculation ---
npv_savings = zeros(1, length(annual_savings));
for i = 1:length(annual_savings)
    npv_savings(i) = sum(annual_savings(i) ./ ((1 + discount_rate).^(1:n_years)));
end

% Net Benefit
net_benefit = npv_savings - setup_costs;

% Display Results
fprintf('--- Cost-Benefit Summary for Proposed Stations ---\n');
for i = 1:length(setup_costs)
    fprintf('Station %d:\n', i);
    fprintf('  Setup Cost (Million IRR): %.2f\n', setup_costs(i));
    fprintf('  NPV of Savings (Million IRR): %.2f\n', npv_savings(i));
    fprintf('  Net Benefit (Million IRR): %.2f\n\n', net_benefit(i));
end

% --- Sensitivity Analysis ---
r_values = 0.01:0.01:0.10;  
sensitivity_matrix = zeros(length(r_values), length(setup_costs));

for j = 1:length(setup_costs)
    for k = 1:length(r_values)
        r = r_values(k);
        npv_temp = sum(annual_savings(j) ./ ((1 + r).^(1:n_years)));
        sensitivity_matrix(k, j) = npv_temp - setup_costs(j);
    end
end

% --- Enhanced Plotting ---
figure('Color', 'w');
hold on;

colors = lines(length(setup_costs));
markers = {'-o','-s'};

for i = 1:length(setup_costs)
    plot(r_values * 100, sensitivity_matrix(:, i), markers{i}, ...
        'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', sprintf('Station %d', i), ...
        'Color', colors(i,:));
end

% Annotate maximum benefits
[~, idx1] = max(sensitivity_matrix(:,1));
[~, idx2] = max(sensitivity_matrix(:,2));

text(r_values(idx1)*100, sensitivity_matrix(idx1,1), sprintf('  Max: %.0f', sensitivity_matrix(idx1,1)), ...
     'FontSize', 10, 'FontWeight', 'bold', 'Color', colors(1,:));
text(r_values(idx2)*100, sensitivity_matrix(idx2,2), sprintf('  Max: %.0f', sensitivity_matrix(idx2,2)), ...
     'FontSize', 10, 'FontWeight', 'bold', 'Color', colors(2,:));

% Styling
xlabel('Discount Rate (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Net Benefit (Million IRR)', 'FontSize', 12, 'FontWeight', 'bold');
title('? Sensitivity Analysis: Net Benefit vs. Discount Rate', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'northeast');
grid on;
set(gca, 'FontSize', 11);
box on;
