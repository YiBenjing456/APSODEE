%Npop: the swarm size
%funcid: the function id
%phi: the exploration balance parameter
clc
clear
Npop = 1000;
phi = 0.3;
runnum = 5;
k = 1;
for funcid = 1:15
    for run = 1:runnum
        bestval(funcid,run) = APSO_DBEE(Npop,funcid,phi,run);
    end
end
save bestval bestval
