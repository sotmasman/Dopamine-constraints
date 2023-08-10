function [result1,result2,result3,result4,svmInfo] = svmSingleAnimalData(data, timebins, trainSize, nReps, plotresults)
%**************************************************************************
% This program prepare data for single animal svm decoding, including
%   1. separate dms from ofc for each animal(set feature numbers equal within each animal;
%                 Instance number equal within each animal)
%   2. data scaling
%   3. data shuffle
%   4. data splitting (train/test set)
%   Input:  data is a structure, including 2 cells:
%               - data.spikecount_stim1: [1 X N], N neurons' response to stim1
%                   - data.spikecount_stim1{n}: nth neuron's response matrix [H X K], H
%                   is the trial number; K is the time bins
%               - data.spikecount_stim2: [1 X N], the same N neurons' response to stim2
%                   - data.spikecount_stim2{n}: same as above
%               - program requires equal number of stim1 and stim2 trials.
%           trainSize - split train/test, e.g. 0.8, 80% trials used for training; 20% trials for testing
%           nReps - repeat n times
%   output: result1 - mean svm decoding accuracy matrix [K 1], K is the time bins
%           result2 - decoding on shuffled data [K 3], K is the time bins,
%           1st column is 95%, 2nd column is mean, 3rd column is 5%
%           result3 - n reps decoding on data, [nReps,K]
%           result4 - n reps decoding on shuffled data, [nReps,K]

% Long Yang
% longyang830@gmail.com
% 8/4/2020
% example: [result1,result2,result3,result4,svmInfo] = svmSingleAnimalData(data,timebins,0.8,100,'y');
%**************************************************************************
%%
nFeature = length(data.spikecount_stim1); % number of features equal to neuron number
[nInstance,NB] = size(data.spikecount_stim1{1}); % number of Instance equal to trial number

raw_SVM_accur = zeros(nReps,NB); 
raw_SVM_accur_rnd = zeros(nReps,NB);

for ii = 1:NB % loop1 through time bins
    bn = poolData(data,nFeature,nInstance,ii);

    for jj = 1:nReps % loop2 through n reps

        [accur,accur_rnd] = calSVM(bn,trainSize,nFeature);
        raw_SVM_accur(jj,ii) = accur(1);
        raw_SVM_accur_rnd(jj,ii) = accur_rnd(1);
    end
end

% mean for 1000 repeats
result1 = mean(raw_SVM_accur)';
% 95% quantile, mean, 5% quantile for 1000 repeats
result2 = [quantile(raw_SVM_accur_rnd,0.95,1)',mean(raw_SVM_accur_rnd)',quantile(raw_SVM_accur_rnd,0.05,1)'];
result3 = raw_SVM_accur;
result4 = raw_SVM_accur_rnd;

svmInfo.instance = nInstance;
svmInfo.feature = nFeature;

if isempty(plotresults)==1
plotresults='n';
end

if plotresults=='y'
    close all
    plot(timebins, result1, 'k')
    hold on
    plot(timebins, result2(:,1),'r')
    axis([min(timebins) max(timebins) 0 100])
end


end

%% local function - caluclate SVM
function [accuracy,accuracy_rnd] = calSVM(data,trainSize,minFeature)

% randomly pick minFeatures from data
data = data(randperm(size(data,1),minFeature),:);

% scale fire rate to [0,1]
data = data';
data = (data-min(min(data)))./max(max(data));

% Label cue1 trials with 1; cue2 trials with -1
label = -1*ones(size(data,1),1);
label(1:size(data,1)/2) = 1; % Cue1

% shuffle data by trial
shuffleTrialInd = randperm(size(data,1));
data = data(shuffleTrialInd,:);
label = label(shuffleTrialInd);

% split train/test set
nTrain = round(size(data,1)*trainSize);
trainLabel = label(1:nTrain); testLabel = label(nTrain+1:end);
trainSet = data(1:nTrain,:);
testSet = data(nTrain+1:end,:);

% generate random data set
trainLabel_rnd = trainLabel(randperm(size(trainLabel,1)));
% testLabel_rnd = testLabel(randperm(size(testLabel,1)));

% test decoding performance
    model = train(trainLabel, sparse(trainSet), '-s 1 -c 1');
    [~, accuracy, ~] = predict(testLabel, sparse(testSet), model, '-b 1');
% test decoding performance for rnd data for comparision
    model_rnd = train(trainLabel_rnd, sparse(trainSet), '-s 1 -c 1');
    [~,accuracy_rnd,~] = predict(testLabel, sparse(testSet), model_rnd, '-b 1');

end

%% local function - pool data in each time bin
function result = poolData(data,nFeature,nInstance,nBin)

% pool stim1 and stim2 together
result = zeros(nFeature,nInstance*2);
for i = 1:nFeature
    d1 = data.spikecount_stim1{i}(:,nBin)';
    d2 = data.spikecount_stim2{i}(:,nBin)';
    result(i,:)= [d1, d2];
end
end


