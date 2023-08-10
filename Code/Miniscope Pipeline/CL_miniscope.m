%%
% Pipeline devloped for the analysis of dLight signal gathered from a 
% 0.5 mm GRIN lens in NAc under conditions where single units are not
% detectable. Assumption of a 20Hz picture capture.

% By Charltien Long for the Masmanidis Lab
% Written 05/2023

%% Import Data - Removes all existing variables and plots.
miniscope_loadfiles;

%% Cropping video files.
miniscope_crop_decimate;

%% Frames split up into individual trials, trial order determined from stimuli
miniscope_assignframes_totrials;

%% Miniscope Masking Based on Fixed Pixel Positions
miniscope_10pct_mask;

%% Choose wisely - can recreate photometry-like measurement, or single-pixel analysis

miniscope_singlepixel_traces;

miniscope_singlepixel_max;

%% Export to prism and save records - work in progress

x_crop_previous = x_crop;
y_crop_previous = y_crop;
QuantIndexn_previous = QuantIndexn;
pixel_factor_previous = 1/pixel_factor;
[filename, path] = uiputfile('*.mat', 'Save crop dimensions');
save(fullfile(path, filename), 'x_crop_previous', 'y_crop_previous','QuantIndexn_previous','pixel_factor_previous');
clear x_crop_previous y_crop_previous QuantIndexn_previous
