function [best_f, fitness_history,nfe, SRO2_counter] = Jaya2_withRP(pop_size, maxFEs, dim, capacity, weights, profit) % added fitness_history

max_pop_size = pop_size;
min_pop_size = 3;
SRO2_counter = 0;
%% Improving efficiency by calculating the RO ratio only once per dataset
weights = weights(:)';
profit  = profit(:)';

RO = profit ./ weights;
[~, repairOrder] = sort(RO,'ascend');
[~, improveOrder] = sort(RO,'descend');

%% Initialize population
x = randi([0 1], pop_size, dim);
x_new = x;

%% Initial evaluation
f = zeros(1,pop_size);
for i=1:pop_size
    f(i) = fobj(x(i,:), capacity, weights, profit);
end

nfe = pop_size;
f_new = f;

%added for convergence curve
fitness_history = [];
initial_best = max(f);
fitness_history = [fitness_history; 1 initial_best];
fitness_history = [fitness_history; nfe initial_best];

%% Main Loop
while nfe < maxFEs
    old_nfe = nfe;
    
    xr = x([2:pop_size,1],:);
    fr = f([2:pop_size,1]);
    
    xl = x([pop_size,1:pop_size-1],:);
    fl = f([pop_size,1:pop_size-1]);

    for i=1:pop_size

        % Creating the neighborhood
        xx = [xl(i,:); x(i,:); xr(i,:)];
        ff = [fl(i); f(i); fr(i)];
        
        [~,best_i]  = max(ff);
        [~,worst_i] = min(ff);
        
        best  = xx(best_i,:);
        worst = xx(worst_i,:);
       
        x_new(i,:) = x(i,:);
        
        % JAYA2 solution update mechanism
        
        for j = 1:dim
            if rand < 0.2
                if rand <= 0.5
                    x_new(i,j) = best(j);
                else
                    x_new(i,j) = 1 - worst(j);
                end
            else
                x_new(i,j) = x(i,j);
            end
        end

        %  Apply Repair Operator (RO) if solution is infeasible
        f_check = fobj(x_new(i,:), capacity, weights, profit);
        nfe = nfe + 1; 

        if f_check < 0
            SRO2_counter = SRO2_counter + 1;
            [x_new(i,:), f_val, currentWeight] = repair_phase(x_new(i,:),  capacity, weights, profit, repairOrder);  
            [x_new(i,:), f_new(i)] = improve_phase(x_new(i,:), capacity, weights, profit, improveOrder, f_val, currentWeight);  
        else
            f_new(i) = f_check;  
        end
       
        if nfe >= maxFEs  
            break;
        end 
    end
    
    % Greedy selection
    pos = find(f_new > f);
    x(pos,:) = x_new(pos,:);
    f(pos) = f_new(pos);
    
    % Population reduction
    if pop_size > min_pop_size
        plan_pop_size = round((((min_pop_size - max_pop_size)/maxFEs)*nfe) + max_pop_size);
        if pop_size > plan_pop_size
            reduction_ind_num = pop_size - plan_pop_size;
            pop_size = max(min_pop_size, pop_size - reduction_ind_num);
            
            [f, indices] = sort(f, 'descend');
            x = x(indices,:);
            
            indices = randperm(pop_size);
            f = f(indices);
            x = x(indices,:);
            
            f_new = f;
            x_new = x;
        end
    end
    %% re-initialize worst solution

    % 1- Re-initialize randomly
    %{
    if nfe < maxFEs  
        [wf, wi] = min(f);
        x(wi,:) = randi([0 1], 1, dim);
        f(wi) = fobj(x(wi,:), capacity, weights, profit);
        nfe = nfe + 1;
    end
    %}

    % 2- Re-initialize by combining info from two solutions (best + random)
    %{
    if nfe < maxFEs
        [~, wi] = min(f);
        p2 = randi([1 pop_size]);
        x(wi,:) = double(~xor(best, x(p2,:)));  % XNOR of the two parents
        f(wi) = fobj(x(wi,:), capacity, weights, profit);
        nfe = nfe + 1;
    end
    %}

    
    % 3- Re-initialize via greedy item selection with stochastic acceptance
    
    if nfe < maxFEs
        [~, wi] = min(f);
        n = size(x,2);
        
        % acceptance probability by rank: best-ranked items most likely to be taken
        accept_prob = linspace(1, 0.2, n);       % rank 1 -> 1.0, rank n -> 0.2

        child = zeros(1, n);
        total_weight = 0;
        for idx = 1:n
            item = improveOrder(idx);
            if total_weight + weights(item) <= capacity && rand() < accept_prob(idx)
                child(item) = 1;
                total_weight = total_weight + weights(item);
            end
        end

        x(wi,:) = child;
        f(wi) = fobj(x(wi,:), capacity, weights, profit);
        nfe = nfe + 1;
    end
    

    % 4- Take the opposite of the worst sol - OBL
    %{
    if nfe < maxFEs
        [~, wi] = min(f);
        x(wi,:) = 1 - x(wi,:); 
        f(wi) = fobj(x(wi,:), capacity, weights, profit);
        nfe = nfe + 1;
    end
    %}
   
    %added for convergece curve
    fitness_history = [fitness_history; nfe  max(f)];

end

best_f = max(f);

if nfe > maxFEs
    fprintf('WARNING: NFE exceeded the limit. nfe = %d, maxFEs = %d\n', nfe, maxFEs);
end

end

%% Repair Phase
function [sol, f_val, currentWeight] = repair_phase(sol, capacity, weights, profit, repairOrder)

    currentWeight = sol * weights(:);
    currentProfit = sol * profit(:);

    for k = 1:length(repairOrder)
        idx = repairOrder(k);

        if sol(idx)
            sol(idx) = 0;

            currentWeight = currentWeight - weights(idx);
            currentProfit = currentProfit - profit(idx);

            if currentWeight <= capacity
                f_val = currentProfit;
                return;
            end
        end
    end
end

%% Improvement Phase
%  Adds items with the highest RO while capacity allows
function [sol, f_val] = improve_phase(sol, capacity, weights, profit, improveOrder, initial_fit, currWeight)

    currentWeight = currWeight;
    currentProfit = initial_fit;

for k = 1:length(improveOrder) 
    idx = improveOrder(k); 
    if sol(idx) 
        continue; 
    end 
    newWeight = currentWeight + weights(idx); 
    if newWeight <= capacity 
        sol(idx) = 1; 
        currentWeight = newWeight; 
        currentProfit = currentProfit + profit(idx); 
    end 
end 

f_val = currentProfit; 
end

%% Knapsack Objective
function profit_val = fobj(X_BIN, capacity, weights, profit)
    if sum(X_BIN .* weights) > capacity
        profit_val = capacity - sum(X_BIN .* weights);
    else
        profit_val = sum(X_BIN .* profit);
    end
end