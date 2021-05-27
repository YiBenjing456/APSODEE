function bestval = APSO_DBEE(Npop,funcid,phi,run)
    %Adaptive particle swarm optimizer with decoupling balance for
    %exploration and exploitation (APSO-DBEE)
    %Npop: the swarm size
    %funcid: the function id
    %phi: the exploration balance parameter
    %groupsize: the exploitation balance parameter which is adjusted by an
    %adaptive strategy in APSO-DBEE
    pause(rand)
    global initial_flag;
    initial_flag = 0;
    if funcid > 12 && funcid < 14
        Nvar = 905; % dimensionality of the objective function.
    else
        Nvar = 1000;
    end
    if(ismember(funcid, [1,4,7,8,11,12,13,14,15]))
        lb = -100;
        ub = 100;
    end
    if(ismember(funcid, [2,5,9]))
        lb = -5;
        ub = 5;
    end
    if(ismember(funcid, [3,6,10]))
        lb = -32;
        ub = 32;
    end
    vmax = ub;
    vmin = lb;
    gen = 1;
    [bestval,trace_val,trace_std,Position,Velocity,MaxFEs,Fitness,fes] = initialization(lb,ub,Npop,Nvar,funcid);
    trace_val(gen) = min(Fitness);
    mean_p = repmat(mean(Position),Npop,1);
    trace_std(gen) = sum(sqrt(sum((Position-mean_p).*(Position-mean_p),2)))/Npop;
    while fes < MaxFEs
        if fes <= 375000
            groupsize = 2;
        elseif fes <= 375000*2
            groupsize = 4;
        elseif fes <= 375000*3
            groupsize = 8;
        elseif fes <= 375000*4
            groupsize = 10;
        elseif fes <= 375000*5
            groupsize = 20;
        elseif fes <= 375000*6
            groupsize = 25;
        elseif fes <= 375000*7
            groupsize = 40;
        else
            groupsize = 50;
        end
        crowding = LSD(Fitness);
        [~, index_crowding] = sort(crowding);
        [converg_group, groupnum] = Grouping(groupsize, Npop);
        losers = zeros(1,Npop);
        con_winners = zeros(1,Npop);
        div_winners = zeros(1,Npop);
        cn = 1;
        count = 1;
        while cn <= groupnum
            temp_list = converg_group(cn, :);
            temp_list(temp_list == 0) = [];
            computing_size = length(temp_list);
            k = 2;
            while k <= computing_size
                pos_in_entropy = find(index_crowding == temp_list(k));
                if  pos_in_entropy <= rand*Npop
                    losers(count) = temp_list(k);
                    con_winners(count) = temp_list(1);
                    div_winners(count) = index_crowding(pos_in_entropy + ceil(rand*(Npop - pos_in_entropy)));
                    count = count + 1;
                end
                k = k + 1;
            end
            cn = cn + 1;
        end
        losers(losers == 0) = [];
        con_winners(con_winners == 0) = [];
        div_winners(div_winners == 0) = [];
        lenloser = length(losers);
        con_exemplar = Position(con_winners,:);
        div_exemplar = Position(div_winners,:);
        w = rand(lenloser, Nvar);
        r1 = rand(lenloser, Nvar);
        r2 = rand(lenloser, Nvar);
        Velocity(losers,:) = w.*Velocity(losers,:) + r1.*(con_exemplar - Position(losers,:)) ...
            + phi*r2.*(div_exemplar - Position(losers,:));
        Velocity(Velocity > vmax) = vmax;
        Velocity(Velocity < vmin) = vmin;
        Position(losers,:) = Position(losers,:) + Velocity(losers,:);
        Position = FeasibleFunction(Position,lb,ub);
        Fitness(losers) = benchmark_func(Position(losers,:)',funcid);
        [Fitness, index] = sort(Fitness);
        Position = Position(index,:);
        Velocity = Velocity(index,:);
        bestval = min(Fitness);
        fes = fes + lenloser;
        fprintf(['APSO-DEE: The best and FEs of Function ', num2str(funcid), ' (', num2str(run), '):%e'],bestval)
        fprintf(' %d', groupsize)
        fprintf(' %d\n', fes)
        gen = gen + 1;
        trace_val(gen) = min(Fitness);
        mean_p = repmat(mean(Position),Npop,1);
        trace_std(gen) = sum(sqrt(sum((Position-mean_p).*(Position-mean_p),2)))/Npop;
    end
    dlmwrite(['trace' num2str(funcid) '.txt'],trace_val,'-append','delimiter',' ','precision',30);
    dlmwrite(['std' num2str(funcid) '.txt'],trace_std,'-append','delimiter',' ','precision',30);
end

