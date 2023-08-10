Trial_sorted_data_Averages = cell(1, size(Trial_sorted_data, 2));

% Delta conversion has to happen on a per trial basis. So they occur
% within these 2 loops. Before collapsing to a single averaged matrix, we
% have to have DF/F context.
% Here we first ascertain the deltas using a similar method to earlier good pixel masking.
delta_factors_photo = cell(size(Trial_sorted_data));
for i = 1:size(Trial_sorted_data, 2)
deltafactor_raw = zeros(size(Trial_sorted_data{1}{1}));
    for j = 21:40 %May need to change down the line
        data_to_add = double(cell2mat(Trial_sorted_data{i}(j)));
        deltafactor_raw = deltafactor_raw + data_to_add;
    end
deltafactor_raw = deltafactor_raw/length(21:40);
delta_factors_photo{i} = deltafactor_raw;
end

%Housekeeping
clear data_to_add deltafactor_raw

%End result is to store deltas for all pixels for all trials
% Iterate through each column of trial sorted data cell array
for i = 1:size(Trial_sorted_data, 2)
    
    % Initialize array to store averages
    averages = zeros(sum(QuantIndex,'all'),numel(Trial_sorted_data{i}));
    
    % Iterate through each cell in current column
    for j = 1:(numel(Trial_sorted_data{i}))
        % Calculate average of current matrix
        good_pixels = double(Trial_sorted_data{i}{j}(QuantIndex));
        good_pixels_delta = delta_factors_photo{i}(QuantIndex);
        averages(:,j) = (good_pixels-good_pixels_delta)./good_pixels_delta;
    end
    % Assign averages to corresponding cell in trial sorted data cell array
    Trial_sorted_data_Averages{i} = averages; %Recycled variable names, don't get confused.
end
clear good_pixels good_pixels_delta averages delta_factors_photo


% Initialize the output matrix
trace_storage = cell(1,numel(Trial_sorted_data_Averages));

% Iterate over the cells in the cell array
for i = 1:numel(Trial_sorted_data_Averages)
    % Iterate over the desired columns
    final_traces = zeros(size(Trial_sorted_data_Averages{1}, 1), length(21:min(Frame_counts))); %This line's placement is critical. Do not move.
    for j = 21:min(Frame_counts)
        % Extract the jth column of the current cell and add it to the appropriate column of the output matrix
        final_traces(:, j-20) = final_traces(:, j-20) + Trial_sorted_data_Averages{i}(:, j);
    end
    trace_storage{i} = final_traces;
end
clear final_traces Trial_sorted_data_Averages

%% Random pixel selection and isolating traces for each trial type for 
%  selected pixels

lines_to_plot = 20;
%Adding timestamps
timebins = ((20:min(Frame_counts)-1)*(1/20))-2;
%Determining which pixels to plot
rand_index = randperm(length(trace_storage{1})); % randomly shuffle integers from 1 to number of pixels
rand_index = rand_index(1:lines_to_plot); % select first 50 integers

% From here our goal is to pull out specific trial types and then pull out
% pixels from them. The same pixels will be pulled for all trial types.

traces_laser_only = zeros(lines_to_plot, length(timebins)); % initialize output variable
for i = 1:length(laser_only_ind) % iterate over all trials of specified type
    temp1=[];
    for j = 1:length(timebins) %access each cell of the desired trial type
    temp1 = [temp1 trace_storage{laser_only_ind(i)}(rand_index,j)];
    end
traces_laser_only = traces_laser_only + temp1;
end
traces_laser_only = traces_laser_only/length(laser_only_ind);%average at the single pixel level but for ALL trials of that type.

traces_sol_laser = zeros(lines_to_plot, length(timebins)); % initialize output variable
for i = 1:length(sol_laser_ind) % iterate over all trials of specified type
    temp1=[];
    for j = 1:length(timebins) %access each cell of the desired trial type
    temp1 = [temp1 trace_storage{sol_laser_ind(i)}(rand_index,j)];
    end
traces_sol_laser = traces_sol_laser + temp1;
end
traces_sol_laser = traces_sol_laser/length(sol_laser_ind);

traces_sol_only = zeros(lines_to_plot, length(timebins)); % initialize output variable
for i = 1:length(sol_only_ind) % iterate over all trials of specified type
    temp1=[];
    for j = 1:length(timebins) %access each cell of the desired trial type
    temp1 = [temp1 trace_storage{sol_only_ind(i)}(rand_index,j)];
    end
traces_sol_only = traces_sol_only + temp1;
end
traces_sol_only = traces_sol_only/length(sol_only_ind);

clear temp1 trace_storage

%% Plotting

trace_plots = figure();
trace_plots.Position(3) = 1600;
trace_plots.Position(4) = 400;

% Plot sol_only subplot
subplot(1, 3, 1);
hold on;
for i = 1:size(traces_sol_only, 1)
    plot(timebins, traces_sol_only(i,:), 'Color', rand(1,3)); % Plot each row with a random color
end
ylim([-0.1 0.1])
hold off;
% Add labels and title
xlabel('Timebins');
ylabel('DeltaF/F');
title('Sol');

% Plot sol_laser subplot
subplot(1, 3, 2);
hold on;
for i = 1:size(traces_sol_laser, 1)
    plot(timebins, traces_sol_laser(i,:), 'Color', rand(1,3)); % Plot each row with a random color
end
ylim([-0.1 0.1])
hold off;
% Add labels and title
xlabel('Timebins');
ylabel('DeltaF/F');
title('Sol Plus Laser');

% Plot laser_only subplot
subplot(1, 3, 3);
hold on;
for i = 1:size(traces_laser_only, 1)
    plot(timebins, traces_laser_only(i,:), 'Color', rand(1,3)); % Plot each row with a random color
end
ylim([-0.1 0.1])
hold off;
% Add labels and title
xlabel('Timebins');
ylabel('DeltaF/F');
title('Laser');