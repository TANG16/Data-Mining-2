function [ OStat ] = CrossValid( Learner, X, Y, TaskNum, Kfold, ValInd, Params )
%CROSSVALID �˴���ʾ�йش˺�����ժҪ
% Cross Validation
%   �˴���ʾ��ϸ˵��

    % �����񽻲���֤ͳ��
    MTLStat = zeros(Kfold, 4, TaskNum);
    % ������֤
    for j = 1 : Kfold
        fprintf('CrossValid: %d\n', j);
        % �ָ�ѵ�����Ͳ��Լ�
        [ xTrain, yTrain, xTest, yTest ] = MTLTrainTest(X, Y, TaskNum, j, ValInd);
        % ��һ��������ѵ����Ԥ��
        [ y, ~ ] = Learner(xTrain, yTrain, xTest, Params);
        % ͳ�ƶ�����ѧϰ����
        MTLStat(j,:,:) = TaskStatistics(TaskNum, y, yTest);
    end
    
    % ͳ�ƶ����񽻲���֤���
    OStat = MTLStatistics(TaskNum, MTLStat);
        
    function [ xTrain, yTrain, xTest, yTest ] = TrainTest(X, Y, Kfold, ValInd)
        test = ValInd==Kfold;
        train = ~test;
        xTrain = X(train,:);
        yTrain = Y(train,:);
        xTest = X(test,:);
        yTest = Y(test,:);
    end

    function [ xTrain, yTrain, xTest, yTest ] = MTLTrainTest(X, Y, TaskNum, Kfold, ValInd)
        xTrain = cell(TaskNum, 1);
        yTrain = cell(TaskNum, 1);
        xTest = cell(TaskNum, 1);
        yTest = cell(TaskNum, 1);
        for t = 1 : TaskNum
            [ xTrain{t}, yTrain{t}, xTest{t}, yTest{t} ] = TrainTest(X{t}, Y{t}, Kfold, ValInd{t});
        end
    end

    function [ MAE, RMSE, SSE, SSR, SST ] = Statistics(y, yTest)
        y_bar = mean(yTest);
        E = yTest-y;
        E2 = E.^2;
        MAE = mean(abs(E));
        RMSE = sqrt(mean(E2));
        SSE = sum(E2);
        SST = sum((yTest-y_bar).^2);
        SSR = sum((y-y_bar).^2);
    end

    function [ OStat ]  = TaskStatistics(TaskNum, y, yTest)
        % ͳ������
        OStat = zeros(4, TaskNum);
        for t = 1 : TaskNum
            [ MAE, RMSE, SSE, SSR, SST ] = Statistics(y{t}, yTest{t});
            OStat(:, t) = [ MAE, RMSE, SSE/SST, SSR/SSE ];
        end
    end

    function [ OStat ] = MTLStatistics(TaskNum, IStat)
        % ������ͳ��
        OStat = zeros(4, TaskNum);
        for t = 1 : TaskNum
            % �õ�K��ƽ��ֵ
            OStat(:, t) = mean(IStat(:,:,t));
        end
    end

end