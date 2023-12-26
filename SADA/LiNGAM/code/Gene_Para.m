function [ X,B,S] = Gene_Para( dims,samples,indegree ,distribution)
X=zeros(dims,samples);
B = zeros(dims,dims);
% distribution = 'A';
switch(distribution)
    case 'A'%%%������˹�ֲ�
        fprintf('Laplace distrubution!\n' );
        for i=1:dims
            if ~isinf(indegree),
                if i<=indegree,
                    par = 1:(i-1);
                else
                    par = randperm((i-1));
                    change=round(rand(1))+1;
                    par = par(1:change);
                end
            else
                par = 1:(i-1);
            end
            if i==1
%                 S(i,:)=laprnd(0,1,1,samples);
                S(i,:)= laprnd(0,1,1,samples);%%%mu=0;��ֵ��sigma=1;��׼�����Ŀ�ƽ����m��n�ֱ��ʾ����������������������
                X(i,:)= S(i,:);
            else
                w = randn(length(par),1);%%%��׼��̬�ֲ�
                wfull = zeros(i-1,1); wfull(par) = w;
                B(i,par) = w';
                S(i,:)=laprnd(0,1,1,samples);
                X(i,:) = wfull'*X(1:(i-1),:)+S(i,:);
            end
        end
    case 'B'
        fprintf('Hyperbolic secant distribution!' );
        for i=1:dims
            if ~isinf(indegree),
                if i<=indegree,
                    par = 1:(i-1);
                else
                    par = randperm((i-1));
                    change=round(rand(1))+1;
                    par = par(1:change);
                end
            else
                par = 1:(i-1);
            end
            if i==1
                S(i,:)=laprnd(0,1,1,samples);
                X(i,:)= S(i,:);
            else
                w = randn(length(par),1);%%%��׼��̬�ֲ�
                wfull = zeros(i-1,1); wfull(par) = w;
                B(i,par) = w';
                S(i,:)=laprnd(0,1,1,samples);
                X(i,:) = wfull'*X(1:(i-1),:)+S(i,:);
            end
        end
    case 'C'
        fprintf('Logistic distribution!' );
    case 'D'%%%��̬�ֲ�
        fprintf('Normal distribution!' );
        for i=1:dims
            if ~isinf(indegree),
                if i<=indegree,
                    par = 1:(i-1);
                else
                    par = randperm((i-1));
                    change=round(rand(1))+1;
                    par = par(1:change);
                end
            else
                par = 1:(i-1);
            end
            if i==1
                S(i,:)=normrnd (0,1,1, samples);%normrnd (a,b,m, n),���ɾ�ֵΪa,����Ϊb��m*n�׾�����̬�ֲ�
                X(i,:)= S(i,:);
            else
                w = randn(length(par),1);%%%��׼��̬�ֲ�
                wfull = zeros(i-1,1); wfull(par) = w;
                B(i,par) = w';
                S(i,:)=normrnd (0,1,1, samples);%normrnd (a,b,m, n),���ɾ�ֵΪa,����Ϊb��m*n�׾�����̬�ֲ�
                X(i,:) = wfull'*X(1:(i-1),:)+S(i,:);
            end
        end
    case 'E'
        fprintf('Raised cosine distribution!' );
    case 'F'%%%���ȷֲ�
        fprintf('Uniform distribution!' );
        for i=1:dims
            if ~isinf(indegree),
                if i<=indegree,
                    par = 1:(i-1);
                else
                    par = randperm((i-1));
                    change=round(rand(1))+1;
                    par = par(1:change);
                end
            else
                par = 1:(i-1);
            end
            if i==1
                S(i,:)=unifrnd (-1,1,1, samples);%unifrnd (a,b,m, n),m*n�ף�a��b�ݾ��ȷֲ�U��a��b���������䷽��Ϊ��b-a��^2/12,��b=sqrt(3),a=-sqrt(3),�������1;
                X(i,:)= S(i,:);
            else
                w = randn(length(par),1);%%%��׼��̬�ֲ�
                wfull = zeros(i-1,1); wfull(par) = w;
                B(i,par) = w';
                S(i,:)=unifrnd (-1,1,1, samples);%unifrnd (a,b,m, n),m*n�ף�a��b�ݾ��ȷֲ�U��a��b��
                X(i,:) = wfull'*X(1:(i-1),:)+S(i,:);
            end
        end  
    otherwise
        fprintf('Wigner semicircle distribution!' );
        
end

