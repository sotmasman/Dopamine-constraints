%% Cutoff mask for the pixels
% This is based on the first 5 trials, agnostic of trial type
% From frame 21:35.
%Set these based on your desired cutoff parameters

cutoff_trials = 1:5;
cutoff_frames = 21:35;

summed_data = zeros(size(Trial_sorted_data{1}{1}));

for i = cutoff_trials
    for j = cutoff_frames
        data_to_add = double(cell2mat(Trial_sorted_data{i}(j)));
        summed_data = summed_data + data_to_add;
    end
end

% Divide by the number of elements to get the element-wise average
num_elements = length(cutoff_trials) * length(cutoff_frames);
averaged_data = summed_data / num_elements;

hold = quantile(averaged_data,10,"all");
QuantIndex1 = averaged_data > hold(1);
QuantIndex2 = averaged_data > hold(2);
QuantIndex3 = averaged_data > hold(3);
QuantIndex4 = averaged_data > hold(4);
QuantIndex5 = averaged_data > hold(5);

masking_plots = figure();
masking_plots.Position(3) = 1400;
masking_plots.Position(4) = 400;

subplot(1,5,1);
imshow(QuantIndex1);
title('20th - 2');
subplot(1,5,2);
imshow(QuantIndex2);
title('30th - 3');
subplot(1,5,3);
imshow(QuantIndex3);
title('40th - 4');
subplot(1,5,4);
imshow(QuantIndex4);
title('50th - 5');
subplot(1,5,5);
imshow(QuantIndex5);
title('60th - 6');

if exist('QuantIndexn_previous', 'var')
    disp('Previous cutoff percentile detected.')
    QuantIndexn = QuantIndexn_previous;
    disp(['You previously chose ' num2str(QuantIndexn)]);
    input("Check the cutoff to make sure it makes sense before continuing. CTRL+C to stop!");
else
    disp('No previous cutoff percentile detected.')
    QuantIndexn = input('Enter an integer for the cutoff or CTRL+C to halt: ');
end
QuantIndex = averaged_data > hold(QuantIndexn);

% Housekeeping to free up RAM
% Note to any future grad students reading this: you might think this 
% is silly, but trust me when I say the RAM usage is insane otherwise.
close all
clear QuantIndex1 QuantIndex2 QuantIndex3 QuantIndex4 QuantIndex5 masking_plots
clear summed_data data_to_add averaged_data
clear raw_mdata %This is a big file that can go. It's redundant with Trial_sorted_data.