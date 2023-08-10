function result = roc_prepareData(data, params)
% this function does ROC analysis for each animal and return result
% Input
% 1. data is a structure, including 2 cells:
%       - data.spikecount_stim1: [1 X N], N neurons' response to stim1
%           - data.spikecount_stim1{n}: nth neuron's response matrix [H X K], H
%           is the trial number; K is the time bins
%       - data.spikecount_stim2: [1 X N], the same N neurons' response to stim2
%           - data.spikecount_stim2{n}: same as above
% 2. params is a structure, including 3 parameters used for permutation
% test
%       - pair, 'paired' or 'unpaired'
%       - tail, 'two-sided' or 'one-sided
%       - nRand, N time
% Output
% result is structure, including 2 items:
%       - AUC, area under curve
%           [N X M] matrix, N is the neuron number; M is the time bins
%       - p_SI, permutation test for significant
%           [N X M] matrix, permutation test p value
%
% LongYang
% longyang830@gmail.com
% 8/3/2020
% ref: http://www.mbfys.ru.nl/~robvdw/DGCN22/PRACTICUM_2011/LABS_2011/ALTERNATIVE_LABS/Lesson_10.html
% updata: 8/18/2020 - fix the bug of abnormal high significance for sparse matrix
%                     length(meanRand(find(meanRand>=meanObs)))/n ----> length(find(meanRand>=meanObs))/n;
% updata: 9/19/2020 - add params.pair, for paired test V.S. unpaired test
%
%% check input arguments
NN = length(data.spikecount_stim1); % neuron number
[NT,NB] = size(data.spikecount_stim1{1}); % NT: number of trial; NB: number of time bins

%% initialization
AUC = zeros(NN,NB); % area under curve
p_SI = zeros(NN,NB); % permutation test

%% ROC 
for ii = 1:NB % loop1 for time bins

%     thresholdList = globalThList(data,NN,NT,ii);    %original code.
    
    for jj = 1:NN % loop2 for neurons in each time bin
        
         thresholdList = globalThList(data, 1, jj);     %new code by sotiris. threshold list is same as the criterion list.
         
        d2 = data.spikecount_stim2{jj}(:,ii)';
        d1 = data.spikecount_stim1{jj}(:,ii)';
        AUC(jj,ii) = calROC(d2,d1,thresholdList,params);
        p_SI(jj,ii) = permutationTest(d2,d1,params);
        
    end
end

result.selectivity_index = AUC;
result.p_SI = p_SI;
end

%% local function - find global threshold list    original function, calculates max across all neurons but not timebins.
% function result = globalThList(data,n,nt,timeBin)
%     d2 = zeros(n,nt);
%     for i = 1:n
%         d2(i,:) = data.spikecount_stim2{i}(:,timeBin)'; 
%     end
%     result = 0:max(d2(:));
% end

%% new function by sotiris, calculates max only across timebins but not neurons. 
%% note the results are virtually indistinguishable from original function, but there are some very minor differences for a small subset of cells.
function result = globalThList(data, stepsize, jj)
     d2 = data.spikecount_stim2{jj}; 
     result = 0:stepsize:max(d2(:));  %default is for spike count criterion to vary in steps of 1 since spike count is usually an integer value. Exception: spike count will be non-integral when convolution is used.
end


%% local function - calculate ROC
%% positive auROC means event1 data are higher; negative auROC means event2 data are higher.
function result = calROC(st1,st2,thresholdList, params)
p_stim1 = zeros(length(thresholdList),1);  %p_stim1 is technically not a hit probability but just the probability that the rates in st1 are >= the threshold criterion. 
p_stim2 = zeros(length(thresholdList),1);   %p_stim2 is technically not a false alarm probability but just the probability that the rates in st2 are >= the threshold criterion.
for jj = 1:length(thresholdList)
    threshold = thresholdList(jj);
    p_stim1(jj) = sum(st1 >= threshold)/length(st1);  
    p_stim2(jj) = sum(st2 >= threshold)/length(st2);

end 

if params.plotROC=='y'
figure
clf
plot(p_stim2, p_stim1,'.-')
xlim([0,1]); ylim([0,1]);
xlabel('False Alarm Rate'); ylabel('Hit Rate')
hold on
plot([0,1],[0,1],'k-');
axis square
input('d')
end

if max(thresholdList)==0
    result = 0;
else
%     result = -trapz(p_stim2,p_stim1);    %default area under the curve, with area = 0.5 indicating e1=e2.
    result = 2*(-trapz(p_stim2,p_stim1)-0.5);  %selectivity index: modifed area under the curve such that area = 0 indicates e1=e2. factor of 2 is to make range from -1 to +1.
end
end

%% local function - permutation test
function pvalue = permutationTest(XA,XB,params)
% this function perform permutation test
% input:            XA: observations from group A
%                   XB: observations from group B
%                   params: same as main function
% output:           pvalue
%Ref: https://en.wikipedia.org/wiki/Resampling_(statistics)#Permutation_tests
n = params.nRand;
tail = params.tail;
pair = params.pair;

meanObs = mean(XA)-mean(XB);   %this is the experimentally observed difference in mean between group A and group B.
nA = length(XA);
obsPool = [XA XB]; %put data from group A and group B into one common pool. used for unpaired test.
nObs = length(obsPool);  %number of data points in the common pool. should be twice the value of nA.
meanRand = zeros(n,1);
for ii = 1:n
    if strcmp(pair,'paired') % for paired test, only shuffle paired elements between two groups
        if size(XA,2) > size(XA,1)
            temp = [XA',XB'];  %put data from group A and group B into two columns. used for paired test.
        else
            temp = [XA,XB];
        end
        for i = 1:nA
            temp(i,:) = temp(i,randperm(2)); %randomly decides to flip the assignment of group A and group B data, but keeps the trial assignments intact.
        end
        randA = temp(:,1); 
        randB = temp(:,2);
    elseif strcmp(pair,'unpaired') 
        obsPool = obsPool(randperm(nObs));  %randomly permuted data from the common pool. used for unpaired test.
        randA = obsPool(1:nA); 
        randB = obsPool(nA+1:end);  
    else
    end
    meanRand(ii) = mean(randA)-mean(randB);   %this is the difference in mean between randomly drawn data. 
end
if strcmp(tail,'one-sided')
    pvalue = length(find(meanRand>=meanObs))/n;
elseif strcmp(tail,'two-sided')
    pvalue = length(find(abs(meanRand)>=abs(meanObs)))/n;
else
end
end