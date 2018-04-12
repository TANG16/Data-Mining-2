addpath(genpath('./utils/'));


% 核函数参数
P1 = 2.^(-1:2:11)';
% 分类器网格搜索参数
C = 2.^(-1:2:11)';
C1 = 2.^(-1:2:11)';
C2 = 2.^(-1:2:11)';
C3 = 2.^(-1:2:11)';
C4 = 2.^(-1:2:11)';
EPS1 = 2.^(-1:2:11)';
EPS2 = 2.^(-1:2:11)';
RHO = 2.^(-1:2:11)';
LAMBDA = 2.^(-1:2:11)';
GAMMA = 2.^(-1:2:11)';
NU = 2.^(-1:2:11)';

% 核函数
kernel = struct('kernel', 'rbf', 'p1', P1);
% 任务参数
Params1 = struct('Name', 'PSVR', 'nu', NU, 'kernel', kernel);
Params2 = struct('Name', 'TWSVR', 'C1', C1, 'C2', C2, 'C3', C3, 'C4', C4, 'eps1', EPS1, 'eps2', EPS2, 'kernel', kernel);
Params3 = struct('Name', 'TWSVR_Xu', 'C1', C1, 'C2', C2, 'eps1', EPS1, 'eps2', EPS2, 'kernel', kernel);
Params4 = struct('Name', 'LS_TWSVR', 'eps1', EPS1, 'eps2', EPS2, 'kernel', kernel);
Params5 = struct('Name', 'MTL_PSVR', 'lambda', LAMBDA, 'nu', NU, 'kernel', kernel);
Params6 = struct('Name', 'MTL_LS_SVR', 'lambda', LAMBDA, 'gamma', GAMMA, 'kernel', kernel);
Params7 = struct('Name', 'MTL_TWSVR', 'C1', C1, 'C2', C2, 'eps1', EPS1, 'eps2', EPS2, 'kernel', kernel);
Params8 = struct('Name', 'MTL_TWSVR_Xu', 'C1', C1, 'C2', C2, 'eps1', EPS1, 'eps2', EPS2, 'kernel', kernel);
Params9 = struct('Name', 'MTL_TWSVR_Mei', 'C1', C1, 'C2', C2, 'eps1', EPS1, 'eps2', EPS2, 'rho', RHO, 'lambda', LAMBDA, 'kernel', kernel);

% 转换参数表
IParams = {
    Params1;Params2;Params3;Params4;
    Params5;Params6;Params7;Params8;
    Params9;
};

% 输出参数表信息
nParams = length(IParams);
for i = 1 : nParams
    nParams = GetParamsCount(IParams{i});
    Method = IParams{i};
    tic
    Params = GetParams(Method, 1);
    Time = toc;
    fprintf('%s:%d params %.2f.\n', Method.Name, nParams, nParams*Time);
end

% 保存参数表
save('./params/LabIParams-Large.mat', 'IParams');