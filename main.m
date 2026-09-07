clear all; close all; clc;

%%
datasets = 31:48;          % Datasets 
nbExperiment = 30;         % Number of runs per dataset
pop_size = 15;             % Population size
maxFEs = 80000;            % Max fitness evaluations per run

%%
Summary = table();
ConvergenceTable = table();
RawRunsTable = table();
tol = 1e-2; 

for K = datasets

    [dim, fobj_handle, capacity, weights, profit, knapsack_struct] = KnapsackLarge(K);
    
    fprintf('\nDataset kp_%d\n', K);

    results = zeros(1, nbExperiment);
    time_runs = zeros(1, nbExperiment);
    nfe_runs = zeros(1, nbExperiment); 
    SRO2_counter_runs = zeros(1, nbExperiment); 
    SRO2_percentage_runs = zeros(1, nbExperiment);
    allHistories = cell(nbExperiment,1);
    
    for run = 1:nbExperiment
        rng(run);
        tic;
        [results(run), history, nfe_runs(run), SRO2_counter] = Jaya2_withRP(pop_size, maxFEs, dim, capacity, weights, profit); 
        SRO2_counter_runs(run) = SRO2_counter;
        time_runs(run) = toc;
        allHistories{run}=history;   %added for convergence curve
        SRO2_percentage_runs(run) = 100 * SRO2_counter / nfe_runs(run);
        fprintf('Run %2d: Final NFE = %d / %d | SRO2 used = %d times (%.2f%%)\n', run, nfe_runs(run), maxFEs, SRO2_counter, SRO2_percentage_runs(run));
    end

    instance_SRO2_percent = 100 * sum(SRO2_counter_runs) / sum(nfe_runs);
    fprintf('Dataset kp_%d: SRO2 usage over all runs = %.2f%%\n', K, instance_SRO2_percent);

    tempRaw = table(repmat({['kp_' num2str(K)]}, nbExperiment, 1), (1:nbExperiment)', results', nfe_runs', SRO2_counter_runs', SRO2_percentage_runs', repmat(instance_SRO2_percent, nbExperiment, 1), ...
    'VariableNames', {'Dataset','Run','FinalFitness','FinalNFE','SRO2Count','SRO2Percent','InstanceSRO2Percent'});
    RawRunsTable = [RawRunsTable; tempRaw];

    %% Convergence data
    maxNFE_recorded = 0;

    for r=1:nbExperiment
        h = allHistories{r};
        if ~isempty(h)
            maxNFE_recorded = max(maxNFE_recorded, max(h(:,1)));
        end
    end
    fitness_matrix = zeros(maxNFE_recorded, nbExperiment);

    for r=1:nbExperiment
        h = allHistories{r};
        nfe_vals = h(:,1);
        fit = h(:,2);
        [unique_nfe, idx] = unique(nfe_vals, 'first');
        unique_fit = fit(idx);
        fitness_matrix(:,r) = interp1(unique_nfe, unique_fit, 1:maxNFE_recorded, 'previous', 'extrap');
    end

    % Average convergence curve
    avgFitness = mean(fitness_matrix,2);
    temp = table(repmat({['kp_' num2str(K)]}, maxNFE_recorded,1), (1:maxNFE_recorded)', avgFitness,...
    'VariableNames', {'Dataset', 'nfe', 'AverageFitness'});
    ConvergenceTable = [ConvergenceTable;temp];

    %% Summary statistics
    best_run = max(results);
    worst_run = min(results);
    mean_run = mean(results);
    median_run = median(results);
    std_run = std(results);
    SR = sum(abs(results - knapsack_struct.optimum) <= tol)/nbExperiment * 100;
    GAP = (knapsack_struct.optimum - mean_run)/knapsack_struct.optimum * 100;
    avg_time = mean(time_runs);

    Summary = [Summary;
        table({['kp_', num2str(K)]},knapsack_struct.optimum,best_run,worst_run,mean_run,median_run,std_run,SR,GAP,avg_time, ...
        'VariableNames',{'Dataset','Optimal','Best','Worst','Mean','Median','STD','SR percent','GAP percent','Time sec'})];
end

disp(Summary);
writetable(ConvergenceTable, 'Jaya2_Convergence.csv'); % Convergece curve
writetable(RawRunsTable, 'Jaya2_Raw_Runs.csv'); % Raw run
writetable(Summary, 'Jaya2_Knapsack.csv'); % Summary statistics
