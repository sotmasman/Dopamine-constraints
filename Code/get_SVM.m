%***********************************

numberofunits = [50];   %number of randomly drawn units in each drawing. can be a list[n1 n2 n3..].

numberofdrawings = 50; %number of random drawings of units. default = 50.
nRand = 100;          %default = 100. number of train-test trial selections used in each random drawing of units.

train_trialratio = 0.8;  %default train trial ratio = 0.8. SVM performance drops slightly if ratio is reduced.

SVM_tmin = 0; %time window over which the max SVM is calculated.
SVM_tmax = 1; 

pairing = 'unpaired';  %options: 'unpaired' or 'paired'.
%***********************************

SVM_filename = input('Specify filename for SVM files: ', 's'); 

results = [];

results.timebins = timebins;
results.numberofunits = numberofunits;
results.numberofdrawings = numberofdrawings;
results.nRand = nRand;         
results.train_trialratio = train_trialratio;  

for cellcountind = 1:length(numberofunits)
    
    n_units = numberofunits(cellcountind); 
    
    realSVM = zeros(numberofdrawings, length(timebins));
    shuffledSVM_mean = zeros(numberofdrawings, length(timebins));
    shuffledSVM_95CI = zeros(numberofdrawings, length(timebins));
    % shuffledSVM_5CI = zeros(numberofdrawings, length(timebins));

    totalcells = length(SVMdata.spikecount_stim1);  %total number of cells across the pooled population across all selected animals.

    %SVMdata is defined in get_triggered_firingrates. Allows for creation of
    %pseudo-population using data from multiple animals. Just make sure to
    %match the number of trials per animal.

    for drawing = 1:numberofdrawings

        randomdrawing=datasample(1:totalcells, n_units, 'replace', false);  %samples without replacement to avoid duplicates

        subsampled_data=[];
        for i = 1:n_units
             pseudouniti = randomdrawing(i);

             subsampled_data.spikecount_stim1{i} = SVMdata.spikecount_stim1{pseudouniti};  
             subsampled_data.spikecount_stim2{i} = SVMdata.spikecount_stim2{pseudouniti};

        end

         [result1,result2,result3,result4,svmInfo] = svmSingleAnimalData(subsampled_data, timebins, train_trialratio, nRand, 'y');   %original Long's code.

        realSVM(drawing,:) = result1;

        shuffledSVM_mean(drawing,:)=result2(:,2);
        shuffledSVM_95CI(drawing,:)=result2(:,1);
    %     shuffledSVM_5CI(drawing,:)=result2(:,3);

    end

    mean_shuffledSVM = mean(result2);
    mean_shuffledSVM_95CI = mean_shuffledSVM(1); %mean of 95th percentile of shuffled SVM.
    
    timeinds_inrange = find(timebins <= SVM_tmax & timebins > SVM_tmin);
    SVM_inwindow = realSVM(:,timeinds_inrange);
    max_SVM_inwindow = max(SVM_inwindow');  %MAX of the SVM within the specified time window.
    mean_SVM_inwindow = mean(SVM_inwindow'); %MEAN of the SVM within the specified time window.
    
    results.SVM{cellcountind} = realSVM;
    results.shuffledSVM_mean{cellcountind} = shuffledSVM_mean;
    results.shuffledSVM_95CI{cellcountind} = shuffledSVM_95CI;
    results.SVM_tmin = SVM_tmin;
    results.SVM_tmax = SVM_tmax;
    results.maxSVM_inwindow(cellcountind, :) = max_SVM_inwindow;   %MAX of the SVM within the specified time window.
    results.mean_SVM_inwindow(cellcountind, :) = mean_SVM_inwindow; %MEAN of the SVM within the specified time window.
    results.mean_maxSVM(cellcountind) = mean(max_SVM_inwindow);
    results.sd_maxSVM(cellcountind) = std(max_SVM_inwindow);
    results.mean_shuffledSVM_95CI(cellcountind) = mean_shuffledSVM_95CI;
    
    
    close all
    figure(1)
    plot(timebins, mean(realSVM), 'k')
    hold on
    plot(timebins, mean(shuffledSVM_mean), 'r')
    plot(timebins, mean(shuffledSVM_95CI), 'r')
    % plot(timebins, mean(shuffledSVM_5CI), 'r')
    axis([min(timebins) max(timebins) 0 100])
    xlabel('Time (s)')
    ylabel('SVM accuracy (%)')
    set(gca,'FontSize',10,'TickDir','out')
    set(gca,'TickLength',[0.02, 0.02])
    
end

disp('saving SVM results as a MAT and XLS file...')

if exist(['SVMtable_' SVM_filename '.xlsx'], 'file');
  delete(['SVMtable_' SVM_filename '.xlsx']);
end

xlswrite(['SVMtable_' SVM_filename '.xlsx'], results.maxSVM_inwindow)

save(['SVMresults_' SVM_filename '.mat'], 'results', '-MAT')