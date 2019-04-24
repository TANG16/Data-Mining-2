clc
clear

addpath(genpath('./utils/'));

% 网格搜索参数
C = 2.^(-3:1:8)';
C3 = 1e-7;% cond 矫正
EPS = [0.01;0.02;0.05;0.1];
RHO = 2.^(-3:1:8)';
MU = (0.1:0.1:1)';
ETA =(0:0.1:1)';
% MTL-aLS-SVM
RATE = [0.83,0.90,0.97]';
% MTCTSVM
P = (0.5:0.5:2.0)';
% VSTG-MTL
K = (3:2:13)';
k = (1:2:7)';

%% 核函数参数
P1 = 2.^(-3:8)'; % 核函数参数
[ linear ] = PackKernel('Linear');
[ poly ] = PackKernel('Poly', 2);
[ rbf ] = PackKernel('RBF', P1);

%% 回归器参数
RParams = cell(3, 1);
[ RParams{1} ] = PackRParams(C, EPS, RHO, linear);
[ RParams{2} ] = PackRParams(C, EPS, RHO, poly);
[ RParams{3} ] = PackRParams(C, EPS, RHO, rbf);
RParams = cellcat(RParams, 1);
[ RParams ] = PrintParams('./params/LabRParams.txt', RParams);
save('./params/LabRParams.mat', 'RParams');

%% 分类器参数
CParams = cell(3, 1);
[ CParams{1} ] = PackCParams(C, RHO, MU, ETA, P, RATE, linear);
[ CParams{2} ] = PackCParams(C, RHO, MU, ETA, P, RATE, poly);
[ CParams{3} ] = PackCParams(C, RHO, MU, ETA, P, RATE, rbf);
CParams = cellcat(CParams, 1);
[ CParams ] = PrintParams('./params/LabCParams.txt', CParams);
save('./params/LabCParams.mat', 'CParams');

%% 安全筛选参数
clear;clc;
[ linear0 ] = PackKernel('Linear');
[ poly0 ] = PackKernel('Poly', 2);
[ rbf0 ] = PackKernel('RBF', 64);
SParams = cell(3, 1);
% 2019年4月8日15:42:01
[ SParams{1} ] = PackSParams(2.^(0:0.03:5)', (0:0.01:1)', linear0);
[ SParams{2} ] = PackSParams(2.^(0:0.03:5)', (0:0.01:1)', poly0);
[ SParams{3} ] = PackSParams(2.^(0:0.03:5)', (0:0.01:1)', rbf0);
SParams = cellcat(SParams, 1);
[ SParams ] = PrintParams('./params/LabSParams.txt', SParams);
[ IParams ] = CreateParams(SParams{9});
save( './params/LabSParams.mat', 'SParams');

%% 核参数
function [ kernel ] = PackKernel(name, p1)
    switch name
        case 'Linear'
            kernel = struct('type', 'linear');
        case 'Poly'
            kernel = struct('type', 'poly', 'p1', p1);
        otherwise
            kernel = struct('type', 'rbf', 'p1', p1);
    end
end

%% 回归参数
function [ RParams ] = PackRParams(C, EPS, RHO, kernel)
    RParams = {
        struct('Name', 'SVR', 'C', C, 'eps', EPS, 'kernel', kernel);...
        struct('Name', 'PSVR', 'C', C, 'kernel', kernel);...
        struct('Name', 'LS_SVR', 'C', C, 'kernel', kernel);...
        struct('Name', 'TWSVR', 'C1', C, 'C3', C, 'eps1', EPS, 'kernel', kernel);... 
        struct('Name', 'TWSVR_Xu', 'C1', C, 'eps1', EPS, 'kernel', kernel);...
        struct('Name', 'LSTWSVR_Mei', 'C1', C, 'eps1', EPS, 'kernel', kernel);...
        struct('Name', 'LSTWSVR_Huang', 'eps1', EPS, 'kernel', kernel);...
        struct('Name', 'MTLS_SVR', 'lambda', RHO, 'C', C, 'kernel', kernel);...
        struct('Name', 'MTPSVR', 'lambda', RHO, 'C', C, 'kernel', kernel);...
        struct('Name', 'MTL_TWSVR', 'C1', C, 'eps1', EPS, 'rho', RHO, 'kernel', kernel);...
        struct('Name', 'MTL_TWSVR_Xu', 'C1', C, 'eps1', EPS, 'rho', RHO, 'kernel', kernel);...
        struct('Name', 'MTLS_TWSVR', 'C1', C, 'eps1', EPS, 'rho', RHO, 'kernel', kernel);...
        struct('Name', 'LSTWSVR_Xu', 'C1', C, 'eps1', EPS, 'kernel', kernel);...
        struct('Name', 'MTLS_TWSVR_Xu', 'C1', C, 'eps1', EPS, 'rho', RHO, 'kernel', kernel)...
    };
    for  i = 1 : length(RParams)
        RParams{i}.ID = RParams{i}.Name;
    end
end

%% 分类参数
function [ CParams ] = PackCParams(C, RHO, MU, ETA, P, RATE, kernel)
    CParams = {
        struct('Name', 'SVM', 'C', C, 'kernel', kernel);...
        struct('Name', 'PSVM', 'C', C, 'kernel', kernel);...
        struct('Name', 'LS_SVM', 'C', C, 'kernel', kernel);...
        struct('Name', 'TWSVM', 'C1', C, 'kernel', kernel);...
        struct('Name', 'LSTWSVM', 'C1', C, 'kernel', kernel);...
        struct('Name', 'vTWSVM', 'v1', MU, 'kernel', kernel);...
        struct('Name', 'ITWSVM', 'C1', C, 'C3', C, 'kernel', kernel);...
        struct('Name', 'RMTL', 'lambda1', RHO, 'lambda2', RHO, 'kernel', kernel);...
        struct('Name', 'MTPSVM', 'lambda', RHO, 'C', C, 'kernel', kernel);...
        struct('Name', 'MTLS_SVM', 'lambda', RHO, 'C', C, 'kernel', kernel);...
        struct('Name', 'MTL_aLS_SVM', 'C1', C, 'C2', C, 'rho', RATE, 'kernel', kernel);...
        struct('Name', 'DMTSVM', 'C1', C, 'rho', RHO, 'kernel', kernel);...
        struct('Name', 'MCTSVM', 'C1', C, 'rho', RHO, 'p', P, 'kernel', kernel);...
        struct('Name', 'MTLS_TWSVM', 'C1', C, 'rho', RHO, 'kernel', kernel);...
        struct('Name', 'MTvTWSVM', 'nv', MU, 'mu', RHO, 'kernel', kernel);...
        struct('Name', 'MTvTWSVM2', 'nv', MU, 'mu', ETA, 'kernel', kernel);...
    };
    for  i = 1 : length(CParams)
        CParams{i}.ID = CParams{i}.Name;
    end
end

%% 安全筛选参数
function [ SParams ] = PackSParams(C, NV, k0)
    c = 2.^(0:5)';
    mu = 2.^(-5:5)';
    nv = (0:0.1:1)';
    [ rbf ] = PackKernel('RBF', 2.^(5:0.01:7)');
    SParams = {
%         SVM
        struct('ID', 'SVM', 'Name', 'SVM', 'C', C, 'kernel', k0);...
        struct('ID', 'PSVM', 'Name', 'PSVM', 'C', C, 'kernel', k0);...
        struct('ID', 'LS_SVM', 'Name', 'LS_SVM', 'C', C, 'kernel', k0);...
        struct('ID', 'TWSVM', 'Name', 'TWSVM', 'C1', C, 'kernel', k0);...
%         MTSVM
        struct('ID', 'MTPSVM', 'Name', 'MTPSVM', 'C', C, 'lambda', mu, 'kernel', k0);...
        struct('ID', 'MTLS_SVM', 'Name', 'MTLS_SVM', 'C', C, 'lambda', mu, 'kernel', k0);...
%         CRMTL
        struct('ID', 'CRMTL_C', 'Name', 'CRMTL', 'C', C, 'mu', nv, 'kernel', k0);...
        struct('ID', 'SSRC_CRMTL', 'Name', 'SSR_CRMTL', 'C', C, 'mu', nv, 'kernel', k0);...
        struct('ID', 'CRMTL_M', 'Name', 'CRMTL', 'mu', NV, 'C', c, 'kernel', k0);...
        struct('ID', 'SSRM_CRMTL', 'Name', 'SSR_CRMTL', 'mu', NV, 'C', c, 'kernel', k0);...
        struct('ID', 'CRMTL_P', 'Name', 'CRMTL', 'kernel', rbf, 'C', c, 'mu', 0.5);...
        struct('ID', 'SSRP_CRMTL', 'Name', 'SSR_CRMTL', 'kernel', rbf, 'C', c, 'mu', 0.5);...
    };
end