images = './images/';

addpath(genpath('./model'));
addpath(genpath('./utils'));

load('LabUCIReg.mat', 'LabUCIReg');
load('LabIParams.mat', 'LabIParams');
load('Colors.mat', 'Colors');

% run regression
kernel = struct('kernel', 'rbf', 'p1', 1888.2);
opts1 = struct('Name', 'TWSVR', 'C1', 2, 'C2', 2, 'C3', 2, 'C4', 2, 'eps1', 0.4, 'eps2', 0.4, 'Kernel', kernel);
opts2 = struct('Name', 'MTL_TWSVR', 'C1', 2, 'C2', 2, 'eps1', 0.34, 'eps2', 0.34, 'Kernel', kernel);
opts = {opts1, opts2};

perf = zeros(4, 5);
h = figure('Visible', 'on');
% 对每一个数据集
for i = [4]
    DataSet = LabUCIReg(i);
    [X, Y] = MultiTask(DataSet, 4);
    [X, Y] = Normalize(X, Y);
    % 对每一组MTL参数
    for j = [1 2]
        % 多任务学习
        opt = opts{j};
        [ y, Time] = MTL(X, Y, X, opt);
        clf(h);
        % 绘制多任务学习结果
        perf(j, 5) = Time;
        for t = 1 : 4
            perf(j, t) = std(y{t}-Y{t});
            PlotCurve( X{t}, Y{t}, ['Task-', num2str(t)], 2, 2, t, 1, Colors(1,:));
            PlotCurve( X{t}, y{t}, ['Task-', num2str(t)], 2, 2, t, 2, Colors(2,:));
        end
        % 保存图片
        name = ['runRegression-', DataSet.Name, '-', opt.Name];
        saveas(h, [images, name, '.png']);
        savefig(h, [images, name]);
    end
end