%% ========================================================================
%  PROFESSIONAL FIRE STATION COST-BENEFIT ANALYSIS SYSTEM
%  Version 2.0 - Advanced Economic Evaluation Framework
%  ========================================================================
%  Features:
%  - Dynamic inflation and escalation modeling
%  - Population growth integration
%  - Monte Carlo risk analysis
%  - Professional dashboard with multiple visualizations
%  - Comprehensive sensitivity analysis
%  - IRR and payback period calculations
%  ========================================================================

function fire_station_professional_cba()
    clc; clear; close all;
    
    %% =====================================================================
    %  CONFIGURATION PARAMETERS
    %% =====================================================================
    
    % Analysis Configuration
    config = struct();
    config.analysis_period = 25;           % Extended analysis period (years)
    config.base_discount_rate = 0.055;     % Real discount rate (5.5%)
    config.currency_symbol = 'IRR';        % Currency denomination
    config.monte_carlo_runs = 1000;        % Number of simulation runs
    
    % Economic Parameters with Uncertainty
    economic_params = struct();
    economic_params.inflation_rate = 0.035;           % Annual inflation (3.5%)
    economic_params.inflation_std = 0.01;             % Inflation volatility
    economic_params.population_growth = 0.025;        % Population growth (2.5%)
    economic_params.demand_escalation = 0.02;         % Service demand growth
    economic_params.cost_escalation = 0.03;           % Cost escalation rate
    
    % Station Data Structure
    stations = initialize_station_data();
    
    %% =====================================================================
    %  CORE FINANCIAL ANALYSIS
    %% =====================================================================
    
    fprintf('\n%s\n', repmat('=', 1, 80));
    fprintf('   PROFESSIONAL FIRE STATION COST-BENEFIT ANALYSIS\n');
    fprintf('%s\n\n', repmat('=', 1, 80));
    
    % Perform comprehensive analysis
    results = perform_comprehensive_analysis(stations, config, economic_params);
    
    % Generate professional dashboard
    create_professional_dashboard(results, config, stations);
    
    % Export detailed report
    generate_executive_report(results, config, stations, economic_params);
    
    fprintf('Analysis completed successfully. Dashboard and reports generated.\n\n');
end

%% ========================================================================
%  DATA INITIALIZATION
%% ========================================================================

function stations = initialize_station_data()
    % Define comprehensive station data with uncertainty ranges
    
    % Pre-allocate structure array with all fields
    stations = struct('id', {}, 'name', {}, 'setup_cost', {}, 'setup_cost_std', {}, ...
                     'annual_fuel_savings', {}, 'annual_maintenance_savings', {}, ...
                     'annual_personnel_savings', {}, 'operational_cost', {}, ...
                     'capacity_factor', {}, 'service_population', {}, ...
                     'gross_annual_savings', {}, 'net_annual_savings', {}, 'cost_per_capita', {});
    
    % Station 1 - Fire Station Alpha (Urban)
    stations(1).id = 'FS-Alpha';
    stations(1).name = 'Fire Station Alpha (Urban)';
    stations(1).setup_cost = 1650;              % Million IRR (inflated from base)
    stations(1).setup_cost_std = 165;           % 10% standard deviation
    stations(1).annual_fuel_savings = 85;       % Million IRR
    stations(1).annual_maintenance_savings = 65;
    stations(1).annual_personnel_savings = 105;
    stations(1).operational_cost = 45;          % Annual operational costs
    stations(1).capacity_factor = 0.85;         % Utilization rate
    stations(1).service_population = 75000;     % People served
    
    % Station 2 - Fire Station Beta (Suburban)
    stations(2).id = 'FS-Beta';
    stations(2).name = 'Fire Station Beta (Suburban)';
    stations(2).setup_cost = 1950;
    stations(2).setup_cost_std = 195;
    stations(2).annual_fuel_savings = 100;
    stations(2).annual_maintenance_savings = 75;
    stations(2).annual_personnel_savings = 115;
    stations(2).operational_cost = 52;
    stations(2).capacity_factor = 0.80;
    stations(2).service_population = 95000;
    
    % Calculate derived metrics
    for i = 1:length(stations)
        stations(i).gross_annual_savings = stations(i).annual_fuel_savings + ...
                                         stations(i).annual_maintenance_savings + ...
                                         stations(i).annual_personnel_savings;
        stations(i).net_annual_savings = stations(i).gross_annual_savings - ...
                                       stations(i).operational_cost;
        stations(i).cost_per_capita = stations(i).setup_cost * 1e6 / ...
                                    stations(i).service_population;
    end
end

%% ========================================================================
%  COMPREHENSIVE ANALYSIS ENGINE
%% ========================================================================

function results = perform_comprehensive_analysis(stations, config, economic_params)
    
    n_stations = length(stations);
    n_years = config.analysis_period;
    base_rate = config.base_discount_rate;
    
    % Initialize results structure
    results = struct();
    results.stations = stations;
    results.n_years = n_years;
    results.base_discount_rate = base_rate;
    
    % Preallocate result matrices
    results.npv = zeros(1, n_stations);
    results.irr = zeros(1, n_stations);
    results.payback_period = zeros(1, n_stations);
    results.roi = zeros(1, n_stations);
    results.benefit_cost_ratio = zeros(1, n_stations);
    
    % Cash flow analysis with dynamic escalation
    results.cash_flows = cell(1, n_stations);
    results.discounted_cash_flows = cell(1, n_stations);
    results.cumulative_cash_flows = cell(1, n_stations);
    
    fprintf('Performing advanced financial analysis...\n');
    
    for i = 1:n_stations
        station = stations(i);
        
        % Generate dynamic cash flows
        [cash_flows, discounted_cf] = calculate_dynamic_cash_flows(...
            station, config, economic_params);
        
        results.cash_flows{i} = cash_flows;
        results.discounted_cash_flows{i} = discounted_cf;
        results.cumulative_cash_flows{i} = cumsum(discounted_cf);
        
        % Financial metrics
        results.npv(i) = sum(discounted_cf);
        results.irr(i) = calculate_irr(cash_flows);
        results.payback_period(i) = calculate_payback_period(cash_flows);
        results.roi(i) = (sum(cash_flows(2:end)) / abs(cash_flows(1))) * 100;
        
        % Benefit-Cost Ratio
        total_benefits = sum(discounted_cf(discounted_cf > 0));
        total_costs = sum(abs(discounted_cf(discounted_cf < 0)));
        results.benefit_cost_ratio(i) = total_benefits / total_costs;
        
        fprintf('  %s: NPV = %.0f M %s, IRR = %.2f%%, Payback = %.1f years\n', ...
               station.id, results.npv(i), config.currency_symbol, ...
               results.irr(i), results.payback_period(i));
    end
    
    % Perform Monte Carlo risk analysis
    fprintf('\nPerforming Monte Carlo risk analysis...\n');
    results.monte_carlo = perform_monte_carlo_analysis(stations, config, economic_params);
    
    % Sensitivity analysis
    fprintf('Conducting sensitivity analysis...\n');
    results.sensitivity = perform_advanced_sensitivity_analysis(stations, config, economic_params);
    
    % Comparative analysis
    results.comparison = perform_comparative_analysis(results, stations);
    
    fprintf('Analysis completed.\n\n');
end

%% ========================================================================
%  DYNAMIC CASH FLOW CALCULATION
%% ========================================================================

function [cash_flows, discounted_cf] = calculate_dynamic_cash_flows(station, config, economic_params)
    
    n_years = config.analysis_period;
    discount_rate = config.base_discount_rate;
    
    % Initialize cash flow vectors
    cash_flows = zeros(1, n_years + 1);
    discounted_cf = zeros(1, n_years + 1);
    
    % Initial investment (Year 0)
    cash_flows(1) = -station.setup_cost;
    discounted_cf(1) = cash_flows(1);
    
    % Annual cash flows with escalation
    base_savings = station.net_annual_savings;
    
    for year = 1:n_years
        % Apply growth factors
        population_factor = (1 + economic_params.population_growth)^year;
        demand_factor = (1 + economic_params.demand_escalation)^year;
        inflation_factor = (1 + economic_params.inflation_rate)^year;
        
        % Calculate escalated savings
        escalated_savings = base_savings * population_factor * demand_factor * inflation_factor;
        
        % Apply capacity utilization decay (minor degradation over time)
        utilization_factor = station.capacity_factor * (0.98^year);
        
        % Net cash flow for the year
        cash_flows(year + 1) = escalated_savings * utilization_factor;
        
        % Discount to present value
        discount_factor = (1 + discount_rate)^year;
        discounted_cf(year + 1) = cash_flows(year + 1) / discount_factor;
    end
end

%% ========================================================================
%  FINANCIAL METRICS CALCULATIONS
%% ========================================================================

function irr_value = calculate_irr(cash_flows)
    % Calculate Internal Rate of Return using iterative method
    
    % Initial guess
    rate = 0.1;
    tolerance = 1e-6;
    max_iterations = 100;
    
    for iter = 1:max_iterations
        npv = 0;
        npv_derivative = 0;
        
        for i = 1:length(cash_flows)
            year = i - 1;
            npv = npv + cash_flows(i) / (1 + rate)^year;
            if year > 0
                npv_derivative = npv_derivative - year * cash_flows(i) / (1 + rate)^(year + 1);
            end
        end
        
        if abs(npv) < tolerance
            break;
        end
        
        % Newton-Raphson update
        if abs(npv_derivative) > tolerance
            rate = rate - npv / npv_derivative;
        else
            break;
        end
        
        % Bound the rate to reasonable values
        rate = max(-0.5, min(rate, 2.0));
    end
    
    irr_value = rate * 100; % Convert to percentage
end

function payback_period = calculate_payback_period(cash_flows)
    % Calculate discounted payback period
    
    cumulative_cf = cumsum(cash_flows);
    payback_index = find(cumulative_cf > 0, 1);
    
    if isempty(payback_index)
        payback_period = Inf;
    else
        % Linear interpolation for fractional year
        if payback_index > 1
            prev_cumulative = cumulative_cf(payback_index - 1);
            current_cf = cash_flows(payback_index);
            fractional_year = abs(prev_cumulative) / current_cf;
            payback_period = (payback_index - 2) + fractional_year;
        else
            payback_period = 0;
        end
    end
end

%% ========================================================================
%  MONTE CARLO RISK ANALYSIS
%% ========================================================================

function mc_results = perform_monte_carlo_analysis(stations, config, economic_params)
    
    n_runs = config.monte_carlo_runs;
    n_stations = length(stations);
    
    % Preallocate results
    mc_npv = zeros(n_runs, n_stations);
    mc_irr = zeros(n_runs, n_stations);
    
    % Parameter uncertainty ranges
    inflation_range = [economic_params.inflation_rate - economic_params.inflation_std, ...
                      economic_params.inflation_rate + economic_params.inflation_std];
    discount_range = [config.base_discount_rate - 0.015, config.base_discount_rate + 0.015];
    
    fprintf('  Running %d Monte Carlo simulations...\n', n_runs);
    
    for run = 1:n_runs
        % Sample random parameters
        inflation_rate = inflation_range(1) + rand() * diff(inflation_range);
        discount_rate = discount_range(1) + rand() * diff(discount_range);
        
        % Modify economic parameters
        temp_econ_params = economic_params;
        temp_econ_params.inflation_rate = inflation_rate;
        temp_config = config;
        temp_config.base_discount_rate = discount_rate;
        
        % Calculate metrics for each station
        for i = 1:n_stations
            % Add cost uncertainty
            cost_multiplier = 1 + 0.1 * randn(); % 10% cost uncertainty
            temp_station = stations(i);
            temp_station.setup_cost = temp_station.setup_cost * cost_multiplier;
            
            % Calculate cash flows
            [cash_flows, discounted_cf] = calculate_dynamic_cash_flows(...
                temp_station, temp_config, temp_econ_params);
            
            mc_npv(run, i) = sum(discounted_cf);
            mc_irr(run, i) = calculate_irr(cash_flows);
        end
        
        if mod(run, 200) == 0
            fprintf('    Completed %d simulations...\n', run);
        end
    end
    
    % Calculate statistics
    mc_results = struct();
    mc_results.npv_mean = mean(mc_npv);
    mc_results.npv_std = std(mc_npv);
    mc_results.npv_percentiles = prctile(mc_npv, [5, 25, 50, 75, 95]);
    mc_results.irr_mean = mean(mc_irr);
    mc_results.irr_std = std(mc_irr);
    mc_results.irr_percentiles = prctile(mc_irr, [5, 25, 50, 75, 95]);
    mc_results.npv_data = mc_npv;
    mc_results.irr_data = mc_irr;
    
    % Risk metrics
    mc_results.probability_positive_npv = mean(mc_npv > 0) * 100;
    mc_results.value_at_risk_5 = prctile(mc_npv, 5);
    mc_results.expected_shortfall = mean(mc_npv(mc_npv <= mc_results.value_at_risk_5));
end

%% ========================================================================
%  ADVANCED SENSITIVITY ANALYSIS
%% ========================================================================

function sensitivity = perform_advanced_sensitivity_analysis(stations, config, economic_params)
    
    % Parameter ranges for sensitivity
    discount_rates = 0.02:0.005:0.12;
    inflation_rates = 0.01:0.005:0.08;
    growth_rates = 0.005:0.005:0.05;
    
    n_stations = length(stations);
    
    % Initialize sensitivity matrices
    sensitivity = struct();
    sensitivity.discount_sensitivity = zeros(length(discount_rates), n_stations);
    sensitivity.inflation_sensitivity = zeros(length(inflation_rates), n_stations);
    sensitivity.growth_sensitivity = zeros(length(growth_rates), n_stations);
    sensitivity.discount_rates = discount_rates;
    sensitivity.inflation_rates = inflation_rates;
    sensitivity.growth_rates = growth_rates;
    
    % Discount rate sensitivity
    for i = 1:length(discount_rates)
        temp_config = config;
        temp_config.base_discount_rate = discount_rates(i);
        
        for j = 1:n_stations
            [~, discounted_cf] = calculate_dynamic_cash_flows(...
                stations(j), temp_config, economic_params);
            sensitivity.discount_sensitivity(i, j) = sum(discounted_cf);
        end
    end
    
    % Inflation rate sensitivity
    for i = 1:length(inflation_rates)
        temp_econ_params = economic_params;
        temp_econ_params.inflation_rate = inflation_rates(i);
        
        for j = 1:n_stations
            [~, discounted_cf] = calculate_dynamic_cash_flows(...
                stations(j), config, temp_econ_params);
            sensitivity.inflation_sensitivity(i, j) = sum(discounted_cf);
        end
    end
    
    % Population growth sensitivity
    for i = 1:length(growth_rates)
        temp_econ_params = economic_params;
        temp_econ_params.population_growth = growth_rates(i);
        
        for j = 1:n_stations
            [~, discounted_cf] = calculate_dynamic_cash_flows(...
                stations(j), config, temp_econ_params);
            sensitivity.growth_sensitivity(i, j) = sum(discounted_cf);
        end
    end
end

%% ========================================================================
%  COMPARATIVE ANALYSIS
%% ========================================================================

function comparison = perform_comparative_analysis(results, stations)
    
    comparison = struct();
    
    % Efficiency metrics
    comparison.npv_per_capita = zeros(1, length(stations));
    comparison.roi_ranking = zeros(1, length(stations));
    comparison.risk_adjusted_return = zeros(1, length(stations));
    
    for i = 1:length(stations)
        comparison.npv_per_capita(i) = results.npv(i) * 1e6 / stations(i).service_population;
        comparison.risk_adjusted_return(i) = results.npv(i) / results.monte_carlo.npv_std(i);
    end
    
    % Rankings
    [~, comparison.npv_ranking] = sort(results.npv, 'descend');
    [~, comparison.irr_ranking] = sort(results.irr, 'descend');
    [~, comparison.efficiency_ranking] = sort(comparison.npv_per_capita, 'descend');
    [~, comparison.risk_ranking] = sort(comparison.risk_adjusted_return, 'descend');
    
    % Summary statistics
    comparison.total_investment = sum([stations.setup_cost]);
    comparison.total_npv = sum(results.npv);
    comparison.portfolio_irr = mean(results.irr);
    comparison.total_population_served = sum([stations.service_population]);
end

%% ========================================================================
%  PROFESSIONAL DASHBOARD CREATION
%% ========================================================================

function create_professional_dashboard(results, config, stations)
    
    % Create main dashboard figure
    fig = figure('Name', 'Fire Station CBA Professional Dashboard', ...
                'Position', [100, 100, 1600, 1000], ...
                'Color', [0.95, 0.95, 0.95]);
    
    % Define professional color scheme
    colors = [0.2, 0.4, 0.8;     % Professional Blue
              0.8, 0.2, 0.2;     % Professional Red
              0.2, 0.7, 0.3;     % Professional Green
              0.9, 0.6, 0.1];    % Professional Orange
    
    % Subplot 1: NPV Comparison with Error Bars
    subplot(2, 3, 1);
    bar_data = results.npv;
    error_data = results.monte_carlo.npv_std;
    b = bar(bar_data, 'FaceColor', colors(1,:), 'EdgeColor', 'k', 'LineWidth', 1);
    hold on;
    errorbar(1:length(bar_data), bar_data, error_data, 'k', 'LineStyle', 'none', 'LineWidth', 2);
    
    % Add value labels
    for i = 1:length(bar_data)
        text(i, bar_data(i) + error_data(i) + 50, sprintf('%.0f M', bar_data(i)), ...
             'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10);
    end
    
    title('Net Present Value Analysis', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('NPV (Million IRR)', 'FontSize', 12);
    xlabel('Fire Station', 'FontSize', 12);
    set(gca, 'XTickLabel', {stations.id});
    grid on; box on;
    
    % Subplot 2: Risk-Return Profile
    subplot(2, 3, 2);
    scatter(results.monte_carlo.npv_std, results.npv, 150, colors(1:length(stations),:), 'filled', 'MarkerEdgeColor', 'k');
    
    % Add station labels
    for i = 1:length(stations)
        text(results.monte_carlo.npv_std(i) + 5, results.npv(i), stations(i).id, ...
             'FontWeight', 'bold', 'FontSize', 10);
    end
    
    xlabel('Risk (NPV Standard Deviation)', 'FontSize', 12);
    ylabel('Expected Return (NPV)', 'FontSize', 12);
    title('Risk-Return Profile', 'FontSize', 14, 'FontWeight', 'bold');
    grid on; box on;
    
    % Subplot 3: Sensitivity Tornado Chart
    subplot(2, 3, 3);
    create_tornado_chart(results.sensitivity, stations);
    
    % Subplot 4: Cash Flow Timeline
    subplot(2, 3, 4);
    years = 0:config.analysis_period;
    for i = 1:length(stations)
        plot(years, results.cumulative_cash_flows{i}, 'LineWidth', 3, ...
             'Color', colors(i,:), 'DisplayName', stations(i).id);
        hold on;
    end
    xlabel('Year', 'FontSize', 12);
    ylabel('Cumulative NPV (Million IRR)', 'FontSize', 12);
    title('Cumulative Cash Flow Analysis', 'FontSize', 14, 'FontWeight', 'bold');
    legend('Location', 'southeast');
    grid on; box on;
    
    % Add break-even line
    yline(0, '--k', 'Break-even', 'LineWidth', 2, 'FontSize', 10, 'FontWeight', 'bold');
    
    % Subplot 5: Monte Carlo Distribution
    subplot(2, 3, 5);
    create_monte_carlo_plot(results.monte_carlo, stations, colors);
    
    % Subplot 6: Key Performance Indicators
    subplot(2, 3, 6);
    create_kpi_summary(results, stations, config);
    
    % Add main title
    sgtitle('FIRE STATION COST-BENEFIT ANALYSIS - EXECUTIVE DASHBOARD', ...
           'FontSize', 18, 'FontWeight', 'bold');
    
    % Save dashboard
    print(fig, 'Fire_Station_CBA_Dashboard', '-dpng', '-r300');
    fprintf('Dashboard saved as: Fire_Station_CBA_Dashboard.png\n');
end

%% ========================================================================
%  SPECIALIZED PLOTTING FUNCTIONS
%% ========================================================================

function create_tornado_chart(sensitivity, stations)
    % Create tornado chart for sensitivity analysis
    
    station_idx = 1; % Focus on first station for tornado chart
    
    % Calculate sensitivity ranges
    discount_range = [min(sensitivity.discount_sensitivity(:, station_idx)), ...
                     max(sensitivity.discount_sensitivity(:, station_idx))];
    inflation_range = [min(sensitivity.inflation_sensitivity(:, station_idx)), ...
                      max(sensitivity.inflation_sensitivity(:, station_idx))];
    growth_range = [min(sensitivity.growth_sensitivity(:, station_idx)), ...
                   max(sensitivity.growth_sensitivity(:, station_idx))];
    
    base_npv = sensitivity.discount_sensitivity(6, station_idx); % Middle value
    
    % Calculate percentage impacts
    factors = {'Population Growth', 'Inflation Rate', 'Discount Rate'};
    low_impact = [growth_range(1) - base_npv, inflation_range(1) - base_npv, discount_range(1) - base_npv];
    high_impact = [growth_range(2) - base_npv, inflation_range(2) - base_npv, discount_range(2) - base_npv];
    
    % Create horizontal bar chart
    y_pos = 1:length(factors);
    barh(y_pos, low_impact, 'FaceColor', [0.8, 0.3, 0.3], 'EdgeColor', 'k');
    hold on;
    barh(y_pos, high_impact, 'FaceColor', [0.3, 0.7, 0.3], 'EdgeColor', 'k');
    
    set(gca, 'YTick', y_pos, 'YTickLabel', factors);
    xlabel('NPV Impact (Million IRR)', 'FontSize', 12);
    title(sprintf('Sensitivity Analysis - %s', stations(station_idx).id), 'FontSize', 14, 'FontWeight', 'bold');
    legend('Downside', 'Upside', 'Location', 'best');
    grid on; box on;
end

function create_monte_carlo_plot(mc_results, stations, colors)
    % Create Monte Carlo distribution plots
    
    n_stations = length(stations);
    x_positions = 1:n_stations;
    
    % Create box plots manually for better control
    for i = 1:n_stations
        npv_data = mc_results.npv_data(:, i);
        
        % Calculate quartiles
        q1 = prctile(npv_data, 25);
        q2 = prctile(npv_data, 50);
        q3 = prctile(npv_data, 75);
        iqr = q3 - q1;
        
        % Box plot elements
        box_width = 0.3;
        box_x = [x_positions(i) - box_width/2, x_positions(i) + box_width/2];
        
        % Draw box
        rectangle('Position', [box_x(1), q1, box_width, iqr], ...
                 'FaceColor', colors(i,:), 'EdgeColor', 'k', 'LineWidth', 1.5);
        
        % Median line
        line(box_x, [q2, q2], 'Color', 'k', 'LineWidth', 3);
        
        % Whiskers
        whisker_low = max(min(npv_data), q1 - 1.5*iqr);
        whisker_high = min(max(npv_data), q3 + 1.5*iqr);
        
        line([x_positions(i), x_positions(i)], [whisker_low, q1], 'Color', 'k', 'LineWidth', 1.5);
        line([x_positions(i), x_positions(i)], [q3, whisker_high], 'Color', 'k', 'LineWidth', 1.5);
        
        % Whisker caps
        cap_width = box_width * 0.3;
        line([x_positions(i) - cap_width/2, x_positions(i) + cap_width/2], ...
             [whisker_low, whisker_low], 'Color', 'k', 'LineWidth', 1.5);
        line([x_positions(i) - cap_width/2, x_positions(i) + cap_width/2], ...
             [whisker_high, whisker_high], 'Color', 'k', 'LineWidth', 1.5);
        
        hold on;
    end
    
    % Formatting
    xlabel('Fire Station', 'FontSize', 12);
    ylabel('NPV Distribution (Million IRR)', 'FontSize', 12);
    title('Monte Carlo Risk Analysis', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'XTick', x_positions, 'XTickLabel', {stations.id});
    grid on; box on;
    
    % Add zero line
    yline(0, '--r', 'Break-even', 'LineWidth', 2, 'FontWeight', 'bold');
end

function create_kpi_summary(results, stations, config)
    % Create KPI summary visualization
    
    % Remove axes for text display
    axis off;
    
    % Title
    text(0.5, 0.95, 'KEY PERFORMANCE INDICATORS', ...
         'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    % Portfolio summary
    total_investment = sum([stations.setup_cost]);
    total_npv = sum(results.npv);
    portfolio_roi = (total_npv / total_investment) * 100;
    
    y_pos = 0.85;
    line_height = 0.08;
    
    % Portfolio metrics
    text(0.05, y_pos, sprintf('Total Investment: %.0f M IRR', total_investment), ...
         'FontSize', 12, 'FontWeight', 'bold');
    y_pos = y_pos - line_height;
    
    text(0.05, y_pos, sprintf('Portfolio NPV: %.0f M IRR', total_npv), ...
         'FontSize', 12, 'FontWeight', 'bold', 'Color', [0, 0.6, 0]);
    y_pos = y_pos - line_height;
    
    text(0.05, y_pos, sprintf('Portfolio ROI: %.1f%%', portfolio_roi), ...
         'FontSize', 12, 'FontWeight', 'bold');
    y_pos = y_pos - line_height;
    
    text(0.05, y_pos, sprintf('Analysis Period: %d years', config.analysis_period), ...
         'FontSize', 12);
    y_pos = y_pos - line_height * 1.5;
    
    % Best performing station
    [best_npv, best_idx] = max(results.npv);
    text(0.05, y_pos, 'BEST PERFORMER:', 'FontSize', 12, 'FontWeight', 'bold');
    y_pos = y_pos - line_height;
    
    text(0.05, y_pos, sprintf('%s', stations(best_idx).name), ...
         'FontSize', 11, 'FontWeight', 'bold', 'Color', [0, 0.4, 0.8]);
    y_pos = y_pos - line_height * 0.7;
    
    text(0.05, y_pos, sprintf('NPV: %.0f M IRR', best_npv), 'FontSize', 11);
    y_pos = y_pos - line_height * 0.7;
    
    text(0.05, y_pos, sprintf('IRR: %.2f%%', results.irr(best_idx)), 'FontSize', 11);
    y_pos = y_pos - line_height * 0.7;
    
    text(0.05, y_pos, sprintf('Payback: %.1f years', results.payback_period(best_idx)), 'FontSize', 11);
    
    % Add recommendation box
    y_pos = 0.25;
    text(0.05, y_pos, 'RECOMMENDATION:', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.8, 0, 0]);
    y_pos = y_pos - line_height;
    
    if total_npv > 0
        recommendation = 'PROCEED with investment';
        rec_color = [0, 0.6, 0];
    else
        recommendation = 'RECONSIDER investment';
        rec_color = [0.8, 0, 0];
    end
    
    text(0.05, y_pos, recommendation, 'FontSize', 11, 'FontWeight', 'bold', 'Color', rec_color);
end

%% ========================================================================
%  EXECUTIVE REPORT GENERATION
%% ========================================================================

function generate_executive_report(results, config, stations, economic_params)
    
    % Create detailed text report
    report_filename = 'Fire_Station_CBA_Executive_Report.txt';
    fid = fopen(report_filename, 'w');
    
    if fid == -1
        fprintf('Warning: Could not create report file.\n');
        return;
    end
    
    % Report Header
    fprintf(fid, '%s\n', repmat('=', 1, 80));
    fprintf(fid, '                FIRE STATION COST-BENEFIT ANALYSIS\n');
    fprintf(fid, '                    EXECUTIVE SUMMARY REPORT\n');
    fprintf(fid, '%s\n\n', repmat('=', 1, 80));
    
    fprintf(fid, 'Analysis Date: %s\n', datestr(now, 'yyyy-mm-dd HH:MM'));
    fprintf(fid, 'Analysis Period: %d years\n', config.analysis_period);
    fprintf(fid, 'Base Discount Rate: %.2f%%\n', config.base_discount_rate * 100);
    fprintf(fid, 'Currency: Million %s\n\n', config.currency_symbol);
    
    % Economic Assumptions
    fprintf(fid, 'ECONOMIC ASSUMPTIONS:\n');
    fprintf(fid, '%s\n', repmat('-', 1, 40));
    fprintf(fid, 'Inflation Rate: %.2f%% annually\n', economic_params.inflation_rate * 100);
    fprintf(fid, 'Population Growth: %.2f%% annually\n', economic_params.population_growth * 100);
    fprintf(fid, 'Demand Escalation: %.2f%% annually\n', economic_params.demand_escalation * 100);
    fprintf(fid, 'Cost Escalation: %.2f%% annually\n\n', economic_params.cost_escalation * 100);
    
    % Portfolio Summary
    total_investment = sum([stations.setup_cost]);
    total_npv = sum(results.npv);
    portfolio_roi = (total_npv / total_investment) * 100;
    
    fprintf(fid, 'PORTFOLIO SUMMARY:\n');
    fprintf(fid, '%s\n', repmat('-', 1, 40));
    fprintf(fid, 'Total Investment Required: %.0f M %s\n', total_investment, config.currency_symbol);
    fprintf(fid, 'Total Portfolio NPV: %.0f M %s\n', total_npv, config.currency_symbol);
    fprintf(fid, 'Portfolio ROI: %.2f%%\n', portfolio_roi);
    fprintf(fid, 'Average IRR: %.2f%%\n', mean(results.irr));
    fprintf(fid, 'Total Population Served: %s people\n\n', ...
           addCommas(sum([stations.service_population])));
    
    % Individual Station Analysis
    fprintf(fid, 'INDIVIDUAL STATION ANALYSIS:\n');
    fprintf(fid, '%s\n', repmat('-', 1, 80));
    
    for i = 1:length(stations)
        station = stations(i);
        
        fprintf(fid, '\n%s (%s)\n', station.name, station.id);
        fprintf(fid, '%s\n', repmat('.', 1, 50));
        fprintf(fid, 'Setup Cost: %.0f M %s\n', station.setup_cost, config.currency_symbol);
        fprintf(fid, 'Annual Net Savings: %.0f M %s\n', station.net_annual_savings, config.currency_symbol);
        fprintf(fid, 'Service Population: %s people\n', addCommas(station.service_population));
        fprintf(fid, 'Cost per Capita: %.0f %s\n', station.cost_per_capita, config.currency_symbol);
        fprintf(fid, '\nFINANCIAL METRICS:\n');
        fprintf(fid, '  Net Present Value: %.0f M %s\n', results.npv(i), config.currency_symbol);
        fprintf(fid, '  Internal Rate of Return: %.2f%%\n', results.irr(i));
        fprintf(fid, '  Payback Period: %.1f years\n', results.payback_period(i));
        fprintf(fid, '  Benefit-Cost Ratio: %.2f\n', results.benefit_cost_ratio(i));
        fprintf(fid, '  Return on Investment: %.2f%%\n', results.roi(i));
        
        % Risk Metrics
        fprintf(fid, '\nRISK ANALYSIS:\n');
        fprintf(fid, '  NPV Standard Deviation: %.0f M %s\n', ...
               results.monte_carlo.npv_std(i), config.currency_symbol);
        fprintf(fid, '  Probability of Positive NPV: %.1f%%\n', ...
               results.monte_carlo.probability_positive_npv(i));
        fprintf(fid, '  Value at Risk (5%%): %.0f M %s\n', ...
               results.monte_carlo.value_at_risk_5(i), config.currency_symbol);
    end
    
    % Risk Assessment
    fprintf(fid, '\n\nRISK ASSESSMENT:\n');
    fprintf(fid, '%s\n', repmat('-', 1, 40));
    fprintf(fid, 'Monte Carlo Simulations: %d runs\n', config.monte_carlo_runs);
    
    overall_prob = mean(results.monte_carlo.probability_positive_npv);
    fprintf(fid, 'Overall Success Probability: %.1f%%\n', overall_prob);
    
    if overall_prob >= 80
        risk_level = 'LOW';
    elseif overall_prob >= 60
        risk_level = 'MODERATE';
    else
        risk_level = 'HIGH';
    end
    fprintf(fid, 'Portfolio Risk Level: %s\n', risk_level);
    
    % Recommendations
    fprintf(fid, '\n\nRECOMMENDations:\n');
    fprintf(fid, '%s\n', repmat('-', 1, 40));
    
    if total_npv > 0
        fprintf(fid, '1. PROCEED with the fire station investment portfolio\n');
        fprintf(fid, '2. Expected positive return of %.0f M %s over %d years\n', ...
               total_npv, config.currency_symbol, config.analysis_period);
    else
        fprintf(fid, '1. RECONSIDER the investment - negative expected NPV\n');
        fprintf(fid, '2. Review cost assumptions and benefit projections\n');
    end
    
    % Station Rankings
    [~, npv_ranking] = sort(results.npv, 'descend');
    fprintf(fid, '3. Station priority ranking (by NPV):\n');
    for i = 1:length(stations)
        rank_idx = npv_ranking(i);
        fprintf(fid, '   %d. %s (NPV: %.0f M %s)\n', i, stations(rank_idx).id, ...
               results.npv(rank_idx), config.currency_symbol);
    end
    
    % Sensitivity Insights
    fprintf(fid, '\n4. Key sensitivity factors:\n');
    fprintf(fid, '   - Discount rate changes significantly impact NPV\n');
    fprintf(fid, '   - Population growth drives long-term benefits\n');
    fprintf(fid, '   - Inflation affects both costs and benefits\n');
    
    % Risk Management
    fprintf(fid, '\n5. Risk management considerations:\n');
    fprintf(fid, '   - Monitor actual vs. projected service demand\n');
    fprintf(fid, '   - Implement cost control measures during construction\n');
    fprintf(fid, '   - Regular review of economic assumptions\n');
    
    % Implementation Timeline
    fprintf(fid, '\n\nIMPLEMENTATION TIMELINE:\n');
    fprintf(fid, '%s\n', repmat('-', 1, 40));
    fprintf(fid, 'Phase 1: Detailed design and permitting (6-12 months)\n');
    fprintf(fid, 'Phase 2: Construction (12-18 months)\n');
    fprintf(fid, 'Phase 3: Commissioning and operations (3-6 months)\n');
    fprintf(fid, 'Total Project Duration: 21-36 months\n');
    
    % Monitoring and Evaluation
    fprintf(fid, '\n\nMONITORING AND EVALUATION:\n');
    fprintf(fid, '%s\n', repmat('-', 1, 40));
    fprintf(fid, '- Annual review of actual vs. projected benefits\n');
    fprintf(fid, '- Quarterly cost tracking and variance analysis\n');
    fprintf(fid, '- Bi-annual update of economic assumptions\n');
    fprintf(fid, '- 5-year comprehensive evaluation and model recalibration\n');
    
    % Disclaimer
    fprintf(fid, '\n\nDISCLAIMER:\n');
    fprintf(fid, '%s\n', repmat('-', 1, 40));
    fprintf(fid, 'This analysis is based on current assumptions and projections.\n');
    fprintf(fid, 'Actual results may vary due to unforeseen circumstances,\n');
    fprintf(fid, 'economic conditions, and operational factors. Regular\n');
    fprintf(fid, 'monitoring and updating of assumptions is recommended.\n');
    
    fprintf(fid, '\n%s\n', repmat('=', 1, 80));
    fprintf(fid, 'End of Report - Generated by Professional CBA System v2.0\n');
    fprintf(fid, '%s\n', repmat('=', 1, 80));
    
    fclose(fid);
    fprintf('Executive report saved as: %s\n', report_filename);
end

%% ========================================================================
%  UTILITY FUNCTIONS
%% ========================================================================

function str = addCommas(num)
    % Add commas to large numbers for readability
    str = sprintf('%.0f', num);
    str = regexprep(str, '(\d)(?=(\d{3})+(?!\d))', '$1,');
end

%% ========================================================================
%  ADDITIONAL ANALYSIS FUNCTIONS
%% ========================================================================

function create_detailed_cash_flow_table(results, stations, config)
    % Create detailed cash flow table for export
    
    fprintf('\nDETAILED CASH FLOW ANALYSIS:\n');
    fprintf('%s\n', repmat('=', 1, 100));
    
    for i = 1:length(stations)
        fprintf('\n%s - %s\n', stations(i).id, stations(i).name);
        fprintf('%s\n', repmat('-', 1, 80));
        fprintf('Year\tCash Flow\tDiscounted CF\tCumulative NPV\n');
        fprintf('%s\n', repmat('-', 1, 80));
        
        cash_flows = results.cash_flows{i};
        discounted_cf = results.discounted_cash_flows{i};
        cumulative_cf = results.cumulative_cash_flows{i};
        
        for year = 0:config.analysis_period
            fprintf('%d\t%.0f\t\t%.0f\t\t%.0f\n', year, ...
                   cash_flows(year+1), discounted_cf(year+1), cumulative_cf(year+1));
        end
    end
end

%% ========================================================================
%  MAIN EXECUTION - Call this function to run the analysis
%% ========================================================================

% To run this analysis, execute the following command in MATLAB:
% fire_station_professional_cba()

% Alternatively, create a separate script file to call the main function