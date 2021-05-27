function [converg_group,groupnum] = Grouping(groupsize, Npop)
    groupnum = ceil(Npop/groupsize);
    converg_group = zeros(groupnum, groupsize);
    init_index = 1 : Npop;
    cn = 1;
    while cn <= groupnum - 1
        len = length(init_index);
        pos = sort(randperm(len,groupsize));
        converg_group(cn,:) = init_index(pos);
        init_index(pos) = [];
        cn = cn + 1;
    end
    work_list = length(init_index);
    converg_group(cn,1:work_list) = init_index;
end

