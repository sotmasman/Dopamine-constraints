function count = char_sigroc_units(input_data, threshold, num_consecutive)
    % Create a logical matrix where 1's represent elements < threshold
    binaryMatrix = input_data < threshold;

    % Create a kernel of ones to find consecutive elements
    kernel = ones(1, num_consecutive);
    
    % Preallocate a count vector
    countVec = zeros(size(input_data, 1), 1);

    for i = 1:size(input_data, 1)
        convResult = conv(binaryMatrix(i, :), kernel, 'valid');
        if any(convResult == num_consecutive)
            countVec(i) = 1;
        end
    end
    % Total count of rows having at least num_consecutive elements < threshold
    count = sum(countVec);
end
