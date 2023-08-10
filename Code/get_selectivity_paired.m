%April 21 2021: divided all rates by timebinsize to convert to spike count.

ROCparams=[];
ROCparams.pair = 'paired';    %options: 'paired' or 'unpaired'.
ROCparams.nRand = 400;     
ROCparams.tail = 'two-sided';
ROCparams.plotROC = 'n';
%***********************************
    
data=[];  
for i = 1:length(SVMdata.spikecount_stim1)

    %compares e1 baseline to e1 trials. permutation test is slower than nonpaired
    data.spikecount_stim1{i}= SVMdata.spikecount_stim1{i}(:,1:end);   %for paired ROC analysis the baseline period per trial is not a constant; rather it is a vector of spike counts with the same duration as post-pre eventtime.
    data.spikecount_stim2{i}= SVMdata.spikecount_stim2{i}(:,1:end);   
    
    %added on 12/6/21 by SM: converts all spike counts to integer values for ROC analysis. corrects for smoothing or convolution of spike count which would lead to non-integer values.
    %note: checked and found this is not necessary for SVM decoder.
    nonzeros1 = data.spikecount_stim1{i};
    nonzeros1(nonzeros1==0) = [];
    nonzeros2 = data.spikecount_stim2{i};
    nonzeros2(nonzeros2==0) = [];
    min_nonzeros = min([min(nonzeros1) min(nonzeros2)]);
    if length(min_nonzeros)>0
    data.spikecount_stim1{i} = round(data.spikecount_stim1{i}/min_nonzeros);  %convert all spike counts to integers. corrects for smoothing effects.
    data.spikecount_stim2{i} = round(data.spikecount_stim2{i}/min_nonzeros);  %convert all spike counts to integers. corrects for smoothing effects.
    end

end

if strcmp(ROCparams.pair, 'paired')
    disp('***Note that the baseline rate per trial is not a constant; rather it is a vector of spike counts with the same length as e1.***')
end

tic
selectivity = roc_prepareData(data, ROCparams);
toc



