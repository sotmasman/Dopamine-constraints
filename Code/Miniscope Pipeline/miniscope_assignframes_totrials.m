%%
% Check to make sure framecounts have been imported
if ~exist('Frame_counts', 'var')
    error('Please add the correct frame_counts file');
end
if ~exist('stimuli', 'var')
    error('Please add the stimuli file');
end

%Very important step where raw_data is split by trial!!
Trial_sorted_data = mat2cell(raw_mdata, Frame_counts, 1)';

% Extract timestamps
sol1times = stimuli.sol1times;
pulsetrainstart = stimuli.lasertimes.pulsetrainstart;
all_trials = zeros(2,length(sol1times));
% Find all pairwise differences between elements of sol1times and pulsetrainstart
diffs = abs(bsxfun(@minus, sol1times(:), pulsetrainstart(:)'));
% Find the indices of the pairs of elements that are within 0.1 of each other
[ind1, ind2] = find(diffs <= 0.1);
ind = [ind1, ind2];
ind = unique(sort(ind, 2), 'rows');
%Set Defaults
all_trials(1,:) = sol1times;
all_trials(2, :) = ones(size(sol1times(1, :)));

% iterate over indices in ind and set corresponding S+L elements in all_trials to 2
for i = 1:length(ind)
    all_trials(2, ind(i)) = 2;
end

laser_only = setdiff(1:length(pulsetrainstart), ind(:, 2));
% Add the unused elements (laser trials) to all_trials and set their trial type to 3
for i = 1:length(laser_only)
    all_trials(:, end+1) = [pulsetrainstart(laser_only(i)); 3];
end

[sorted_times, sort_idx] = sort(all_trials(1,:));
trial_order = all_trials(2,sort_idx);
sol_only_ind = find(trial_order == 1);
sol_laser_ind = find(trial_order == 2);
laser_only_ind = find(trial_order == 3);

% chosen_trial_type_ind = [];
% 
% % check which trial type was chosen and set index variable accordingly
% if strcmp(chosen_trial_type, 'sol_only')
%     chosen_trial_type_ind = sol_only_ind;
% elseif strcmp(chosen_trial_type, 'sol_laser')
%     chosen_trial_type_ind = sol_laser_ind;
% elseif strcmp(chosen_trial_type, 'laser_only')
%     chosen_trial_type_ind = laser_only_ind;
% else
%     error('Invalid trial type specified.');
% end
