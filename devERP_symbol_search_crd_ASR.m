%% DevERP Analysis Script
% EEG/ERP Operation: ASR
% Paradigm: Symbol Search Task
% Author: Will Decker

%% Establish directories
workdir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/clean_rawdata_ASR/workdir';
txtdir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/clean_rawdata_ASR/txtdir';
erpdir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/clean_rawdata_ASR/erpdir';

channelsdir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/clean_rawdata_channels/workdir';

%% Load subjects

% Load subjects

subjectlist = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/scripts/subjectlist.xlsx';
[d,s,r] = xlsread(subjectlist);
subject_list = r;
numsubjects = length(s);

%% clean_rawdata ASR
a = linspace(0, 100, 5);
a1 = 5;
a2 = a(2);
a3 = a(3);
a4 = a(4);
a5 = a(5);
params = {a1, a2, a3, a4, a5};
paramstr = {'_a1', '_a2', '_a3', '_a4', '_a5'};


for i = 1:length(params)
    for s = 1
    
    subject = subject_list{s};

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_loadset('filename',[subject '_crd_channels.set'],'filepath',channelsdir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    EEG = clean_asr(EEG, params{i});
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',[workdir filesep [subject paramstr{i} '_crd_ASR.set']],'gui','off'); 
    end
end

%%