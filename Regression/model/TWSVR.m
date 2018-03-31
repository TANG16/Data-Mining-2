function [ yTest, Time ] = TWSVR(xTrain, yTrain, xTest, opts)
%TWSVR 此处显示有关此类的摘要
% Twin Support Vector Machine
% 
%   此处显示详细说明

%% Parse opts
    names = fieldnames(opts);
    [m, ~] = size(names);
    for i = 1 : m
        name = names{i};
        switch(name)
            case {'C1'}
                C1 = opts.C1;
            case {'C2'}
                C2 = opts.C2;
            case {'C3'}
                C3 = opts.C3;
            case {'C4'}
                C4 = opts.C4;
            case {'eps1'}
                eps1 = opts.eps1;
            case {'eps2'}
                eps2 = opts.eps2;
            case {'Kernel'}
                kernel = opts.Kernel;
        end
    end
    
%% Fit
    tic;
    % 得到H
    e = ones(size(yTrain));
    C = xTrain;
    H = [Kernel(xTrain, C, kernel) e];
    % 得到f,g
    f = yTrain + eps2;
    g = yTrain - eps1;
    % 得到Hu,Hv
    H2 = H'*H;
    Hu = (H2+C3)\H';
    Hv = (H2+C4)\H';
    % 得到Q1，Q2
    Q1 = H*Hu;
    Q2 = H*Hv;
    % 求解两个二次规划
    [m, ~] = size(yTrain);
    e = ones(m, 1);
    lb = zeros(m, 1);
    % TWSVR1
    ub1 = e*C1;
    Alpha = quadprog(-Q1,Q1'*f-g,[],[],[],[],lb,ub1,[]);
    % TWSVR2
    ub2 = e*C2;
    Gamma = quadprog(-Q2,f-Q2'*g,[],[],[],[],lb,ub2,[]);
    % 得到u,v
    u = Hu*(f-Alpha);
    v = Hv*(g+Gamma);
    % 得到w
    w = (u+v)/2;
    % 停止计时
    Time = toc;
    
%% Predict
    [m, ~] = size(xTest);
    e = ones(m, 1);
    yTest = [Kernel(xTest, C, kernel), e]*w;
    
end