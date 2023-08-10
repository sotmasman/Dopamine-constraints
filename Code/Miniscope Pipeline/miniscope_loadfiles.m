%%close existing things
close all
clear all

%%Load files first
[filename, path] = uigetfile({'*.nc'}, 'Select the miniscope NC file');
% Check if the user clicked cancel
if isequal(filename,0)
    error('User clicked Cancel');
else
    % Load the file into the workspace
    cd(path)
    myvar = ncread(filename,'varr_ref');
    disp('NC data loaded successfully');
end

[filename, path] = uigetfile({'*.mat'}, 'Select the stimuli file');
% Check if the user clicked cancel
if isequal(filename,0)
    error('User clicked Cancel');
else
    % Load the file into the workspace
    load(fullfile(path,filename));
    disp('Stimuli loaded successfully');
end
[filename, path] = uigetfile({'*.mat'}, 'Select the frame count file');
if isequal(filename,0)
    error('User clicked Cancel');
else
    % Load the file into the workspace
    load(fullfile(path,filename));
    disp('Frame Counts loaded successfully');
end

[filename, path] = uigetfile({'*.mat'}, 'Select the crop file');
if isequal(filename,0)
    disp('No crop file loaded. Proceeding.');
else
    % Load the file into the workspace
    load(fullfile(path,filename));
    disp('Crop file loaded successfully');
end