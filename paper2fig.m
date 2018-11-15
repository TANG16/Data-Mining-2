%%
MyStat = MyStat*100;
MyTime = MyTime*1000;
%%
h = figure();
load('MTL_UCI5.mat');
load('Caltech5.mat');
load('MLC5.mat');
load('LabCParams.mat');
labels = {'\nu-TWSVM','SVM','PSVM','LS-SVM','TWSVM','LS-TWSVM','MT-\nu-TWSVM II','MT-\nu-TWSVM I','MTPSVM','MTLS-SVM','DMTSVM','MTL-aLS-SVM','MCTSVM'};
% 单任务学习
STL_IDX = [2 3 4 5 6 1 8 7];
% 多任务学习
MTL_IDX = [9 10 12 11 13 8 7 ];
CUR_IDX = MTL_IDX;
IDX = 1;
%% Monk
xLabels = {'60', '90', '120', '150', '180', '210', '240', '270', 'All'};
DrawResult(MyStat(CUR_IDX,[2:9,1],IDX)', MyTime(CUR_IDX,[2:9 1])', labels(CUR_IDX), xLabels);

%% ISOLET
xLabels = {'ab', 'cd', 'ef', 'gh', 'ij', 'kl','mn','op'};
DrawResult(MyStat(CUR_IDX,10:17,IDX)', MyTime(CUR_IDX,10:17)', labels(CUR_IDX), xLabels);

%% Letter1
xLabels = {'3', '5', '7', '9', '11'};
DrawResult(MyStat(CUR_IDX,18:22,IDX)', MyTime(CUR_IDX,18:23)', labels(CUR_IDX), xLabels);

%% Letter2
xLabels = {'T1', 'T2', 'T3', 'T4', 'T5'};
DrawResult(MyStat(CUR_IDX,23:27,IDX)', MyTime(CUR_IDX,23:27)', labels(CUR_IDX), xLabels);

%% Caltech
xLabels = {'Birds_1','Insects_1','Flowers_1','Mammals_1','Instruments_1','Aircrafts','Balls','Bikes','Birds','Boats','Flowers','Instruments','Plants','Mammals','Vehicles'};
DrawResult(MyStat(CUR_IDX,:,IDX)', MyTime(CUR_IDX,:)', labels(CUR_IDX), xLabels, 45);

%% Caltech101
xLabels = {'Birds','Insects','Flowers','Mammals','Instruments'};
DrawResult(MyStat(CUR_IDX,1:5,IDX)', MyTime(CUR_IDX,1:5)', labels(CUR_IDX), xLabels, 45);

%% Caltech256
xLabels = {'Aircrafts','Balls','Bikes','Birds','Boats','Flowers','Instruments','Plants','Mammals','Vehicles'};
DrawResult(MyStat(CUR_IDX,6:15,IDX)', MyTime(CUR_IDX,6:15)', labels(CUR_IDX), xLabels, 45);

%% Flags
xLabels = {'100', '120', '140', '160', '180', '191'};
DrawResult(MyStat(CUR_IDX,1:6,IDX)', MyTime(CUR_IDX,1:6)', labels(CUR_IDX), xLabels);

%% Emotions
xLabels = {'100', '120', '140', '160', '180', '200'};
DrawResult(MyStat(CUR_IDX,7:12,IDX)', MyTime(CUR_IDX,7:12)', labels(CUR_IDX), xLabels);