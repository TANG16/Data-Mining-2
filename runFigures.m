Root = cd;
Path = [ Root '/data/classify/rbf/' ];

% 添加搜索路径
addpath(genpath('./datasets'));
addpath(genpath('./params'));
addpath(genpath('./model'));
addpath(genpath('./utils'));

% 加载数据集和网格搜索参数
load('LabMTLClf.mat');

% 实验数据集
LabDataSets = {LabMTLClf};

% 实验设置
opts = struct('Statistics', @ClfStat, 'IndexCount', 1);

% 统计每个数据集上的多任务实验数据
m = length(LabDataSets);
for i = 1 : m
    DataSets = LabDataSets{i};
    n = length(DataSets);
    for j = 1 : n
        DataSet = DataSets(j);
        StatPath = [Path, './statistics/LabStat-', DataSet.Name, '.mat'];
        if exist(StatPath, 'file') == 2
            load(StatPath);
            SaveFigures(Path, DataSet, LabStat, LabTime, opts);
        end
    end
end