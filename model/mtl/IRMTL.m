function [ yTest, Time ] = IRMTL( xTrain, yTrain, xTest, opts )
%IRMTL 此处显示有关此函数的摘要
% Regularized MTL
%   此处显示详细说明

%% Parse opts
C = opts.C;
mu = opts.mu;
kernel = opts.kernel;
TaskNum = length(xTrain);
[ X, Y, T, ~ ] = GetAllData(xTrain, yTrain, TaskNum);

%% Prepare
tic;
Q = Y.*Kernel(X, X, kernel).*Y';
P = cell(TaskNum, 1);
for t = 1 : TaskNum
    Tt = T==t;
    P{t} = Q(Tt,Tt);
end
% 二次规划求解
e = ones(size(Y));
lb = zeros(size(Y));
H = Cond(Q/mu + spblkdiag(P{:}));
[ Alpha ] = quadprog(H,-e,[],[],[],[],lb,C*e,[],opts.solver);
% 停止计时
Time = toc;

%% Predict
TaskNum = length(xTest);
yTest = cell(TaskNum, 1);
for t = 1 : TaskNum
    Tt = T==t;
    Ht = Kernel(xTest{t}, X, kernel);
    y0 = predict(Ht, Y, Alpha);
    yt = predict(Ht(:,Tt), Y(Tt,:), Alpha(Tt,:));
    y = sign(y0/mu + yt);
    y(y==0) = 1;
    yTest{t} = y;
end

    function [ y ] = predict(H, Y, Alpha)
        svi = Alpha~=0;
        y = H(:,svi)*(Y(svi,:).*Alpha(svi,:));
    end
end