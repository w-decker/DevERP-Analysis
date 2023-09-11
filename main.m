%% DevERP Analysis Script
% Author: Will Decker

%% Initialize directories

rawdir = '/Users/lendlab/Box Sync/willdecker/Projects/DevERP/DevERP-working-analysis/testset/rawdir'; % should contain .set files. If not, see 'checkeventcodes.m'
workdir = '/Users/lendlab/Box Sync/willdecker/Projects/DevERP/DevERP-working-analysis/testset/workdir';
txtdir = '/Users/lendlab/Box Sync/willdecker/Projects/DevERP/DevERP-working-analysis/testset/txtdir';
erpdir = '/Users/lendlab/Box Sync/willdecker/Projects/DevERP/DevERP-working-analysis/testset/erpdir';
smedir = '/Users/lendlab/Box Sync/willdecker/Projects/DevERP/DevERP-working-analysis/testset/smedir';

%% Load in subject list
% See https://github.com/w-decker/DevERP-Simplified/wiki/Additional-Resources for creating this subject lists

[N, T, R] = xlsread("/Users/lendlab/Box Sync/willdecker/Projects/DevERP/DevERP-working-analysis/testset/txtdir/subjectlist.xlsx");
subject_list = cellfun(@(x) string(x), T(:, 2)); % changes values in cell to strings

%% Remove unnecessary channels

chans2remove = [8, 14, 17, 21, 25, 48, 43, 68, 73, 81, 88, 94, 119, 120, 125, 126, 127, 128, 129].'; % channels to remove a la Langer et al. (2017)
chanlist = [1:129].'; % total number of channels


for i=1
    % set subject variable
    subject = subject_list{i};

    % start EEGLAB 
    eeglab nogui

    % load in data
    EEG = pop_loadset([subject '.set'],rawdir);

    % remove channels
    EEG.data(chans2remove, :) = [];

    % save new set
    EEG = pop_saveset(EEG, [workdir filesep [subject '_chansrm' '_.set']]);
end

%% Filter

% filter parameters
highpass = [0.01, 0.1, 0.25, 0.50, 0.75, 1];
highpass_str = {'pt01', 'pt1', 'pt25', 'pt5', 'pt75', '1'};

for i = 1
    eeglab nogui

    for s = 1%:length(highpass)

        subject = subject_list{s};

        % load in datasets
        EEG = pop_loadset([workdir filesep [subject '_chansrm_.set']]);

        % filter the data
        EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff', [ highpass(s) 30], ...
                'Design', 'butter', 'Filter', 'bandpass', 'Order',4 );

        % save dataset
        EEG = pop_saveset( EEG, [workdir filesep [subject '_highpass_' highpass_str{s} '.set']]);
    end
end

%% Epoch filter data

EEG = epochWrapper(EEG,ALLEEG, CURRENTSET, 'filter', subject_list, workdir, txtdir, erpdir);

%% Make ERP list for filter data

highpass_str = {'1', 'pt1', 'pt01', 'pt25', 'pt5', 'pt75'};
erpnames = {'1_erplist.txt', 'pt1_erplist.txt', 'pt01_erplist.txt', 'pt25_erplist.txt', 'pt5_erplist.txt', 'pt75_erplist.txt'};

for j = 1:6
    fileID = fopen([txtdir filesep erpnames{j}], 'w');
    for i = 1:numsubjects
        subject = subject_list{i};
        data = fullfile(erpdir, [subject '_highpass_' highpass_str{j} '.erp']);
        fprintf(fileID, '%s\n', data);
    end
    fclose(fileID);
end

%% Analyze SME for filtered data

%% Remove Line noise

%% Epoch line noise data

%% Make ERP list for Line noise data

%% Analyze SME for filtered data

