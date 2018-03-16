function [ Output ] = GridSearch( Clf, X, Y, k, P1, P2 )
%GRIDSEARCH 此处显示有关此函数的摘要
% 网格搜索
%   此处显示详细说明
% 参数：
%     Clf   -分类器
%       D   -数据集
%       k   -k折
%  Params   -参数数组

    nP1 = length(P1);
    nP2 = length(P2);
    nIndex = 0;
    Output = cell(nP1*nP2, 6);
    fprintf('GridSearch: on %s\n', DataSet.Name);
    for i = 1 : nP1
        for j = 1 : nP2
            nIndex = nIndex + 1;
            fprintf('GridSearch:%d %d %d\n', nIndex, P1(1, i), P2(1, j));
            [ Accuracy, Precision, Recall, Time ] = CrossValid( Clf, X, Y, ValInd, k );
            Output(nIndex, :) = {
                P1(i), P2(j), Accuracy, Precision, Recall, Time
            };
        end
    end
end