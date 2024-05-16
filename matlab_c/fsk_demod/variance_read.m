% Define the directory containing the CSV files
directory = '/home/star13/ws/measurements/';

% Get a list of all CSV files in the directory
csvFiles = dir(fullfile(directory, '*.csv'));

variance = [];

% Loop through each CSV file
for i = 1:numel(csvFiles)
    % Parse the file name to extract distance
    fileNameParts = strsplit(csvFiles(i).name, '_');
    distanceStr = strrep(fileNameParts{3}, 'd', ''); % Remove the 'd' prefix
    distance = str2double(strrep(distanceStr, '-', '.')); % Replace '-' with '.'

    % Read the CSV file
    rssiData = csvread(fullfile(directory, csvFiles(i).name));
    
    % Calculate variance
    variances = var(rssiData(:));
    variance = [variance, variances];
    fprintf('dist: %f, var: %f\n', distance, variances);
end

disp(median(variance));