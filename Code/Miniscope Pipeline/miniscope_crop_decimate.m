%% Import Data To Cell Array
[width, height, num_frames] = size(myvar); % get dimensions of data
raw_mdata_orig = cell(num_frames, 1); % initialize cell array
for frame = 1:num_frames
    raw_mdata_orig{frame} = squeeze(myvar(:, :, frame)); % extract frame and store in cell
end 

if exist('pixel_factor_previous', 'var') 
   disp('Previous downscaling factor detected. Please verify.');
   pixel_factor = 1/pixel_factor_previous;
   disp(['You previously chose ' num2str(pixel_factor_previous)]);
else
    pixel_factor = input('Please enter an integer pixel downscaling value below 7: ');
    pixel_factor = 1/pixel_factor;
end

%% Decimate pixels
% Assuming your cell array is named 'original_data'
raw_mdata = cell(size(raw_mdata_orig));  % Initialize a new cell array for scaled data

% Iterate over each cell
for i = 1:numel(raw_mdata_orig)
    % Get the frame matrix from the current cell
    frame_matrix = raw_mdata_orig{i};
    
    % Perform the scaling operation using 'imresize' function
    scaled_matrix = imresize(frame_matrix, pixel_factor,'box');
    
    % Store the scaled matrix in the corresponding cell of the new cell array
    raw_mdata{i} = scaled_matrix;
end

clear raw_mdata_orig scaled_matrix frame_matrix

%%
%CROP This is destructive.
if exist('x_crop_previous', 'var') && exist('y_crop_previous', 'var') 
   disp('Previous crop dimensions detected.');
   y_crop_lower = y_crop_previous(1);
   y_crop_upper = y_crop_previous(2);
   x_crop_lower = x_crop_previous(1);
   x_crop_upper = x_crop_previous(2);
else
    close all
    disp('Previous crop dimensions not detected.')
    image(raw_mdata{10});% abitrary frame choice, feel free to change
    pbaspect([1 1 1]);
    y_crop_lower = input('Enter a lowerbound for the ycrop: ');
    y_crop_upper = input('Enter an upperbound for the ycrop: ');
    x_crop_lower = input('Enter a lowerbound for the xcrop: ');
    x_crop_upper = input('Enter an upperbound for the xcrop: ');
    close all
end

% close all
% image(raw_mdata{10});% abitrary frame choice, feel free to change
% pbaspect([1 1 1]);
% y_crop_lower = input('Enter a lowerbound for the ycrop: ');
% y_crop_upper = input('Enter an upperbound for the ycrop: ');
% x_crop_lower = input('Enter a lowerbound for the xcrop: ');
% x_crop_upper = input('Enter an upperbound for the xcrop: ');
% close all

if y_crop_lower > y_crop_upper || x_crop_lower > x_crop_upper
    error('Error: One of your lower crop bounds was higher than the upper.');
end

y_crop = [y_crop_lower y_crop_upper];
x_crop = [x_crop_lower x_crop_upper];
for i=1:length(raw_mdata)
    raw_mdata{i} = raw_mdata{i}(y_crop(1):y_crop(2),x_crop(1):x_crop(2));
end

image(raw_mdata{10});% abitrary frame choice, feel free to change
pbaspect([1 1 1]);
input("Check the crop to make sure it makes sense before continuing. CTRL+C to stop!");

clear('myvar') %Trust me this is worth it. This file is H U G E.
close all
