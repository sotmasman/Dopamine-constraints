The following is code used to perform analysis for the paper entitled "Physiological constraints on the rapid dopaminergic modulation of striatal reward activity"

1. get_selectivity_paired and get_selectivity_unpaired scripts (with roc_prepare_Data)
-Used to obtain selectivity index and p-value for ephys data. Paired is typically used when comparing a single event to baseline such as reward delivery to baseline or
optogenetic stimulation alone to baseline. Unpaired is typically used to compare two comparable conditions such as R and R+L trials, etc. Please note, paired script
is more computationally intesive.

2. get_SVM (and svmSingleAnimalData)
-Together used to run linear SVM on provided ephys data. Make sure to obtain liblinear matlab library (https://www.csie.ntu.edu.tw/~cjlin/liblinear/). Saves results as .mat
and .xlsx files.

3. char_sigroc_units
-Searches p-value matrix for cells with specified number of adjacents timebins below p-value threshold. Please refer to figure specific instructions.

4. Miniscope Pipeline
-Set of functions to run analysis on Miniscope data. Open "CL_miniscope" first. This is the main function.