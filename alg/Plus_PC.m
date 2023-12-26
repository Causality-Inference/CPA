function [RPF1_structure] = Plus_PC(Alg,data,skeleton,r_s,maxCset)
%---------------------------Run algorithm--------------------------
for i = 1:length(Alg)
    [cut_set,nodeA,nodeB,~] = Alg{i}(data,r_s);
    PA = unique([nodeA,cut_set]); 
    PB = unique([nodeB,cut_set]);
    %---------------------------   Run PC   ---------------------------
    [~,struA] = PC_part(data,PA,maxCset,@PaCoT);
    [~,struB] = PC_part(data,PB,maxCset,@PaCoT);
    for v = 1:size(skeleton,1)-1
        for w = v+1:size(skeleton,1)
            if struA(v,w) == 1 && struA(w,v) == 0 && struB(v,w) == 0 && struB(w,v) == 1
               struA(w,v) = 1;
               struB(v,w) = 1;
            end
        end
    end
    struC = struA.*struB;
    for p = 1:size(data,2)
        for q = 1:size(data,2)
            if struC(p,q) == 1 && struC(q,p) == 1
                if rand > 0.5
                    struC(q,p) = 0;
                else
                    struC(p,q) = 0;
                end
            end
        end
    end
    struC(nodeA,nodeB) = 0;struC(nodeB,nodeA) = 0;
    score{i} = [getRPF_stru(struC,skeleton),get_SHD(struC,skeleton)];
end
%----------------------------------results---------------------------------
RPF1_structure = [];
for k = 1:i
    RPF1_structure = [RPF1_structure;score{k}];
end
end