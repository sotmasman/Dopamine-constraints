%% Single Pixel Analysis - Maxima
% Pixels chosen follow a pre-made mask.
%
% We are going to work with Trial_sorted_data

single_pixel_data_trialsorted = cell(1, size(Trial_sorted_data, 2));

% Iterate through each column of data cell array
for i = 1:size(Trial_sorted_data, 2)
    % Iterate through each cell in current column
    grouped_good_pixels = [];
    for j = 1:(numel(Trial_sorted_data{i}))
        good_pixels = Trial_sorted_data{i}{j}(QuantIndex);
        good_pixels(good_pixels == 0) = NaN; %This probably isn't needed
        grouped_good_pixels(:,j) = good_pixels;
    end
    
    % Assign averages to corresponding cell in data cell array
    single_pixel_data_trialsorted{i} = grouped_good_pixels;
end
clear grouped_good_pixels good_pixels

pre_pixel_mean = [];
post_pixel_max = [];
single_pixel_postminuspre = cell(1, size(single_pixel_data_trialsorted, 2));

% Max delta for single pixels on a single trial level
% 1.Calculate the baseline mean for a single trial for each pixel
% 2.Determine the maximum value for each pixel in the time window of interest
% 3.Note that this is determined in arbitrary pixel values not delta yet
% 4.Calculate the delta for that max value at the single trial level
% 5.File it away by trial into a cell corresponding to the trial
% 6.Each cell in the output single_pixel_postminuspre should contain
%   a max for every pixel expressed as a delta value.

for i = 1:size(single_pixel_data_trialsorted, 2)
    pre_pixel_mean = mean(single_pixel_data_trialsorted{i}(:,21:40),2);
    post_pixel_max = max(single_pixel_data_trialsorted{i}(:,41:50),[],2);
    hold = (post_pixel_max - pre_pixel_mean)./pre_pixel_mean;
    single_pixel_postminuspre{i} = hold;
end
clear hold pre_pixel_mean post_pixel_max

%% Split data by trial types and calculate means of observed maxima

% Concatenate data from chosen trials and calculate average
sol_only_singlepixel = [];
for i = 1:length(sol_only_ind)
    sol_only_singlepixel = [sol_only_singlepixel; single_pixel_postminuspre{sol_only_ind(i)}];
end
% This line of code creates a collection of averages for the post-pre for
% single pixels across all the trials of a specific type. The numel term is
% the number of "good pixels", and the length term is the number of trials
% (generally 40).
sol_only_sp_max = mean(reshape(sol_only_singlepixel, numel(single_pixel_postminuspre{1}), length(sol_only_ind)),2);
clear sol_only_singlepixel

% Concatenate data from chosen trials and calculate average
sol_laser_singlepixel = [];
for i = 1:length(sol_laser_ind)
    sol_laser_singlepixel = [sol_laser_singlepixel; single_pixel_postminuspre{sol_laser_ind(i)}];
end
sol_laser_sp_max = mean(reshape(sol_laser_singlepixel, numel(single_pixel_postminuspre{1}), length(sol_laser_ind)),2);
clear sol_laser_singlepixel

% Concatenate data from chosen trials and calculate average
laser_only_singlepixel = [];
for i = 1:length(laser_only_ind)
    laser_only_singlepixel = [laser_only_singlepixel; single_pixel_postminuspre{laser_only_ind(i)}];
end
laser_only_sp_max = mean(reshape(laser_only_singlepixel, numel(single_pixel_postminuspre{1}), length(laser_only_ind)),2);
clear laser_only_singlepixel

clear single_pixel_postminuspre

%normalized data to mean
sol_only_sp_max_norm = (sol_only_sp_max/mean(sol_only_sp_max));
sol_laser_sp_max_norm = (sol_laser_sp_max/mean(sol_only_sp_max));

% Plot histogram
figure;
histogram(sol_only_sp_max_norm,'BinWidth',0.05,'FaceColor','black','Normalization','probability');
xline(mean(sol_only_sp_max*100)/mean(sol_only_sp_max*100));
xline(mean(sol_laser_sp_max*100)/mean(sol_only_sp_max*100));
hold on
histogram(sol_laser_sp_max_norm,'BinWidth',0.05,'FaceColor','#F28C28','Normalization','probability');
% hold on
% histogram(laser_only_sp_max,'BinWidth',0.002,'FaceColor','red');
title('Histogram of Average Maximum DF/F For Single Pixels');
legend('Reward','Reward+Laser')
xlabel('Normalized DeltaF/F by Pixel');
ylabel('Pixel Count');
yticklabels(yticks*100);

figure;
scatter(sol_only_sp_max_norm,sol_laser_sp_max_norm, 4, 'filled');
xlabel('Solenoid Only');
ylabel('Solenoid Plus Laser');
title('Comparison of Average Maximum DF/F For Single Pixels');
xlim([0 2.5])
ylim([0 2.5])
pbaspect([1 1 1])
hold on
plot(xlim,ylim,'-b')