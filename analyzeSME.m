function [smeOutput] = analyzeSME(smeTable,timewindow)
%ANALYZESME Average SME across channels within a specified time window
%   smeTable (str or var) path to .mat or .xls output file created during SME calculation
%   timewindow (vector of ints) Time window, must be whole numbers in steps of 100.

% parse inputs
p = inputParser;
p.FunctionName = inputname(1);
p.CaseSensitive = false;
p.addRequired('smeTable', @ischar)
p.addRequired('timewindow', @(x) validateattributes(x, {'numeric', 'vector', 'integer'}, {'size', [1, 2]}));
p.parse(smeTable,timewindow)

% check the filetype and assign analysis based on that 
df = [];
todo = 1;
filextension = string(split(p.Results.smeTable, '.'))'; %checks file type

if filextension(1, 2) == 'mat'
    df = load(p.Results.smeTable, '-mat');
    numbins = size(df.dataquality.data);
    numbins = numbins(3);
    todo = 1;   
elseif filextension(1, 2) == 'xls'
    xlsdf = readtable(p.Results.smeTable);
    sheets = cell2mat(table2cell(xlsdf(:,3)));
    numsheets = sum(sheets ~= '"');
    numbins = numsheets(1);
    todo = 2;
end

% analyze .mat file data
smeOutput = struct(); % create output struct
if todo == 1
    % get times
    timecols = df.dataquality.times(:, 1).';
    indx1 = find(timecols == p.Results.timewindow(1));
    indx2 = find(timecols == p.Results.timewindow(2));
        if isempty(indx1) || isempty(indx2)
            error('Your time windows are incorrect. Time windows must be given in steps of 100. Example: [0 100] or [200 500].')
        end
    
    % calculate mean and std and output to struct
    for i = 1:numbins
        smeData = [timecols; df.dataquality.data(:, :, (i))];
        data2analyze = smeData(2:end, indx1:indx2);
        smeavg = mean(mean(data2analyze));
        smestd = std(mean(data2analyze));
        fprintf('Within the time window %d-%d in bin %d the mean is %f the std is %f.\n', timewindow(1), timewindow(2), i, smeavg, smestd);

        % add to smeOutput
       smeOutput(i).bin = i;
       smeOutput(i).mean = smeavg;
       smeOutput(i).std = smestd;
    end

% TODO: add xls version
        
end

end
