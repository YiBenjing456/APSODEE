function [bestval,trace_val,trace_std,Position,Velocity,MaxFEs,Fitness,fes] = initialization(lb,ub,Npop,Nvar,funcid)
    %Parameter initialization
    MaxFEs = 3000000;
    trace_val = [];
    trace_std = [];
    Position = lb + rand(Npop, Nvar)*(ub - lb);
    Velocity = zeros(Npop, Nvar);
    Fitness = benchmark_func(Position',funcid);
    [Fitness, index] = sort(Fitness);
    Position = Position(index,:);
    Velocity = Velocity(index,:);
    bestval = min(Fitness);
    fes = Npop;
end

