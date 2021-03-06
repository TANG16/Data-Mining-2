data = './data/';
images = './images/';
weights = './weights/';

% 添加搜索路径
addpath(genpath('./datasets'));
addpath(genpath('./params'));
addpath(genpath('./model'));
addpath(genpath('./utils'));

% 加载数据集和网格搜索参数
load('LabReg.mat');
load('LabIParams.mat');

% 数据集
DataSetIndices = [1:14];
ParamIndices = [9 11];
BestParams = 1024;

% 实验设置
solver = []; % optimoptions('fmincon', 'Display', 'off');
opts = struct('solver', solver);

% 实验开始
fprintf('runTaskRelation\n');
for i = DataSetIndices
    DataSet = LabReg(i);
    fprintf('DataSet: %s\n', DataSet.Name);
    [ X, Y, ValInd ] = GetMultiTask(DataSet);
    [ X ] = Normalize(X);
    for j = ParamIndices
        Method = IParams{j};
        Name = [ DataSet.Name, '-', Method.Name, '-W' ];
        try
            % 多任务学习
            Params = GetParams(Method, BestParams);
            Params.solver = opts.solver;
            [ xTrain, yTrain, xTest, yTest ] = MTLTrainTest(X, Y, DataSet.TaskNum, 1, ValInd);
            [~, ~, W] = MTL(xTrain, yTrain, xTest, Params);
            % 任务相关性对比
            imshow(TaskRelation(W), 'InitialMagnification', 'fit');
            save([ weights, Name ], 'W');
            saveas(gcf, [ images , Name ], 'png');
        catch Exception
            fprintf('Exception in %s\n', Name);
        end
    end
end