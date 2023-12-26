clc;clear;addpath('.\alg');addpath('.\dataset');addpath(genpath('.\SADA'));
n = 50;
pM = [1 1;1 2;1 3;2 1;2 2;2 3;3 3;4 4;5 5];
Alg = {@CPA};
nsamples = 100;
maxCset = 3;
for u = 1:size(pM)
    p = pM(u,:)
    parfor T = 1:100
        T;
        rng(T); % fixed rand
        skeleton = zeros(n,n);skeleton(1,2) = 1;skeleton(2,3) = 1;skeleton(3,4) = 1;skeleton(4,5) = 1;
        for m = 6:n
            r = randperm(5);
            temp = [m-5,m-4,m-3,m-2,m-1];
            r = temp(r);
            if rand > 0.2
                skeleton(r(1:p(1)),m) = 1;
            else
                skeleton(r(1:p(2)),m) = 1;
            end
        end
        data = genData(skeleton,nsamples);
        % ---------------------- run PC ----------------------------------
        tic;[skeC,struC] = PC_part(data,1:size(data,2),maxCset,@PaCoT);  % rough_skeleton
        for pp = 1:size(data,2)
            for q = 1:size(data,2)
                if struC(pp,q) == 1 && struC(q,pp) == 1
                    if rand > 0.5
                        struC(q,pp) = 0;
                    else
                        struC(pp,q) = 0;
                    end
                end
            end
        end
        cell_PC{T} = [[getRPF_stru(struC,skeleton),get_SHD(struC,skeleton)],toc];
        % ---------------------- rough_skeleton----------------------------
        tic;[r_s,~] = PC_part(data,1:size(data,2),2,@PaCoT);trs = toc;
        % ---------------------- run CPA ----------------------------------
        tic;cell_CPA{T} = [Plus_PC(Alg(1),data,skeleton,r_s,maxCset),toc+trs];
    end
    printS = [get_Mean(cell_PC)',get_Mean(cell_CPA)']
end
