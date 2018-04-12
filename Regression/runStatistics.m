Root = cd;

% 添加搜索路径
addpath(genpath('./datasets'));
addpath(genpath('./params'));
addpath(genpath('./model'));
addpath(genpath('./utils'));

% 加载数据集和网格搜索参数
load('LabMulti.mat');
load('LabReg.mat');
load('LabSVMReg.mat');
load('LabUCIReg.mat');
load('LabIParams.mat');

% 实验数据集
LabDataSets = {LabMulti, LabReg, LabSVMReg, LabUCIReg};

% 统计每个数据集上的多任务实验数据
m = length(LabDataSets);
for i = 1 : m
    DataSets = LabDataSets{i};
    n = length(DataSets);
    for j = 1 : n
        DataSet = DataSets(j);
        [ LabStat, HasStat ] = LabStatistics(Root, DataSet, IParams);
        if HasStat == 1
            SaveStatistics(Root, DataSet, LabStat);
        end
    end
end