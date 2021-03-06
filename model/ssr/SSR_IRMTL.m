function [  CVStat, CVTime, CVRate ] = SSR_IRMTL( xTrain, yTrain, xTest, yTest, TaskNum, IParams, opts )
%SSR_IRMTL 此处显示有关此函数的摘要
% Safe Screening for IRMTL
%   此处显示详细说明

%% Fit
[ X, Y, T, ~ ] = GetAllData(xTrain, yTrain, TaskNum);
solver = opts.solver;
[ change, step ] = Change(IParams);
n = GetParamsCount(IParams);
CVStat = zeros(n, opts.IndexCount, TaskNum);
CVTime = zeros(n, 2);
CVRate = zeros(n, 6);
for i = 1 : n
    params1 = GetParams(IParams, i);
    params1.solver = opts.solver;
    tic;
    [ H1 ] = Prepare(X, Y, TaskNum, params1);
    C1 = params1.C;
    if mod(i, step) ~= 1
        C0 = params0.C;
        % solve the rest problem
        switch change
            case 'C'
                [ Alpha1 ] = DVI_C(H1, Alpha0, C1, C0);
            case 'H'
                [ Alpha1 ] = DVI_H(H0, H1, Alpha0, C1);
            otherwise
                throw(MException('SSR_IRMTL', 'Change: no parameter changed'));
        end
        [ Alpha0, S, CVRate(i,1:2) ] = Reduced(H1, Alpha1, C1);
    else
        % solve the first problem
        [ Alpha0 ] = Primal(H1, C1);
    end
    H0 = H1;
    CVTime(i, 1) = toc;
    % 检验筛选出来的0和C，是不是原有的0和C
    if mod(i, step) ~= 1
        [ Alpha1 ] = Primal(H1, params1.C);
        [ CVRate(i, 5:6) ] = Compare(Alpha1, Alpha0, S);
    end
    % 预测
    [ y_hat, CVRate(i, 3:4) ] = Predict(X, Y, xTest, Alpha0, params1);
    CVStat(i,:,:) = MTLStatistics(TaskNum, y_hat, yTest, opts);
    params0 = params1;
end

    function [ rate ] = Compare(Alpha1, Alpha0, S)
        DiffS = Alpha1(S)-Alpha0(S);
        DiffA = Alpha1-Alpha0;
        rate(1) = max(DiffS);
        rate(2) = max(DiffA);
    end

    function [ change, step ] = Change(IParams)
    % 得到最先变的参数
        p1 = GetParams(IParams, 1);
        p2 = GetParams(IParams, 2);
        if p1.C ~= p2.C
            change = 'C';
            step = length(IParams.C);
        elseif p1.mu ~= p2.mu
            step = length(IParams.mu);
            change = 'H';
        else
            k1 = p1.kernel;
            k2 = p2.kernel;
            if strcmp(k1.type, 'rbf') && strcmp(k2.type, 'rbf')
                if k1.p1 ~= k2.p1
                    change = 'H';
                    step = length(IParams.kernel.p1);
                else
                    throw(MException('SSR_CRMTL', 'Change: no parameter changed'));
                end
            else 
                throw(MException('SSR_CRMTL', 'Change: no parameter changed'));
            end
        end
    end

    function [ H ] = Prepare(X, Y, TaskNum, opts)
        % construct hessian matrix
        Q = Y.*Kernel(X, X, opts.kernel).*Y';
        P = cell(TaskNum, 1);
        for t = 1 : TaskNum
            Tt = T==t;
            P{t} = Q(Tt,Tt);
        end
        H = Cond(Q/opts.mu + spblkdiag(P{:}));
    end

    function [ Alpha1 ] = Primal(H1, C1)
        % primal problem
        e = ones(size(H1, 1), 1);
        lb = zeros(size(H1, 1), 1);
        [ Alpha1 ] = quadprog(H1,-e,[],[],[],[],lb,C1*e,[],solver);
    end

    function [ Alpha1, S, Rate ] = Reduced(H1, Alpha1, C1)
        % reduced problem
        R = Alpha1 == Inf;
        S0 = Alpha1 == 0;
        SC = Alpha1 == C1;
        S = S0 | SC;
        Rate = mean([S0, SC]);
        if mean(R) > 0
            f = H1(R,S)*Alpha1(S)-1;
            lb = zeros(size(f));
            ub = C1*ones(size(f));
            [ Alpha1(R) ] = quadprog(H1(R,R),f,[],[],[],[],lb,ub,[],solver);
        end
    end

    function [ yTest, Rate ] = Predict(X, Y, xTest, Alpha, opts)
        % extract opts
        mu = opts.mu;
        C = opts.C;
        % predict
        yTest = cell(TaskNum, 1);
        for t = 1 : TaskNum
            Tt = T==t;
            Ht = Kernel(xTest{t}, X, opts.kernel);
            y0 = predict(Ht, Y, Alpha);
            yt = predict(Ht(:,Tt), Y(Tt,:), Alpha(Tt,:));
            y = sign(y0/mu + yt);
            y(y==0) = 1;
            yTest{t} = y;
        end
        
        Rate = mean([abs(Alpha)<1e-7, abs(Alpha-C)<1e-7]);
        
        function [ y ] = predict(H, Y, Alpha)
            svi = Alpha~=0;
            y = H(:,svi)*(Y(svi,:).*Alpha(svi,:));
        end
    end

end