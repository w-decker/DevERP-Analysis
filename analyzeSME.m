function [smeOutput] = analyzeSME(smeTable,filetype,timewindow)
%ANALYZESME Average SME across channels within a specified time window
%   smeTable (str or var) path to .mat or .xls output file created during SME calculation
%   timewindow (vector of ints) Time window, must be whole numbers

p = inputParser;
p.FunctionName('analyzeSME')
p.CaseSensitive = false;
p.addRequired('smeTable')
p.addParamValue('smeTable', @ischar)
p.addRequired('filetype')
p.addParamValue('filetype', @ischar)
p.addRequired('timewindow')
t1 = timewindow(1);
t2 = timewindow(2);
p.addParamValue('timewindow', [t1 t2], @isnumeric);
p.parse(p, smeTable, filetype, timewindow)


df = [];
todo = 1;
if p.Results.filetype == 'mat'
    df = load(p.Results.smeTable, '-mat');
    numbins = size(df.dataquality.data);
    numbins = numbins(3);
    todo = 1;   
elseif p.results.filetype == 'xls'
    xlsdf = readtable(p.Results.smeTable);
    sheets = cell2mat(table2cell(xlsdf(:,3)));
    numsheets = sum(sheets ~= '"');
    numbins = numsheets(1);
    todo = 2;
end

if todo == 1
    timecols = df.dataquality.times(:, 1).';
    data2analyze = df.dataquality.data;
    newdf = struct;
    for i = 1:numbins
        newdf(i).string({i}) = [timecols; df.dataquality.data(:, :, 1)];
    end
    
    % begin analysis
    
    smeOutput = [];
    
    for i = 1:numbins
        
       
z = cell(num2str(timecols));



for i = 1:length(timecols)
    timecols(i) = num2str(timecols(1)))
    
end

% dd = array2table(data2analyze(:, :, 1), 'VariableNames', t.');
% 
% t = cellstr(num2str(timecols.'))
% t.'






















end