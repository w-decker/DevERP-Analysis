%% DevERP Analysis Script
% EEG/ERP Operation: Filter
% Paradigm: Symbol Search Task
% Author: Will Decker

%% Directories

% dirs for filtered data
filtdatadir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/workdi';
filtdir1 = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/workdir/1';
filtpt1dir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/workdir/pt1';
filtpt01dir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/workdir/pt01';
filtpt25dir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/workdir/pt25';
filtpt5dir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/workdir/pt5';
filtpt75dir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/workdir/pt75';

notch = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/notch';
IIR = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/IIR';
cleanline = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/cleanline';
zp = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/zp';
nochange = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/nochange';

%% Load subjects

% Load subjects

subjectlist = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/scripts/subjectlist.xlsx';
[d,s,r] = xlsread(subjectlist);
subject_list = r;
numsubjects = length(s);

%% Notch linear filter
% passband edges of 48, 52


filtdirnames = {filtdir1, filtpt1dir, filtpt01dir, filtpt25dir, filtpt5dir, filtpt75dir};
highpass = [1, 0.01, 0.01, 0.25, 0.50, 0.75];
highpass_str = {'1', 'pt1', 'pt01', 'pt25', 'pt5', 'pt75'};

for i = 1:6
    for s=1:numsubjects 

        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
        eeglab('redraw');
            
        subject = subject_list{s};

        EEG = pop_loadset ([subject '_highpass_' highpass_str{i} '.set'],filtdirnames{i});
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

        EEG  = pop_eegfiltnew( EEG, 'locutoff', 52, 'hicutoff', 48);
 
        [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject '_notch_' highpass_str{i} ],'gui','off'); 
        EEG = pop_saveset( EEG, [subject '_notch_' highpass_str{i} '.set'], notch); 
    end
end

%% Notch IIR
% IIRFilt plugin must be installed

locutoff = 52;
hicutoff = 48;
filtdirnames = {filtdir1, filtpt1dir, filtpt01dir, filtpt25dir, filtpt5dir, filtpt75dir};
highpass = [1, 0.01, 0.01, 0.25, 0.50, 0.75];
highpass_str = {'1', 'pt1', 'pt01', 'pt25', 'pt5', 'pt75'};

for i = 1:6
    for s=1:numsubjects 

        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
        eeglab('redraw');
            
        subject = subject_list{s};

        EEG = pop_loadset ([subject '_highpass_' highpass_str{i} '.set'],filtdirnames{i});
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

        EEG = pop_iirfilt( EEG, 48, 52);
 
        [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject '_IIR_' highpass_str{i} ],'gui','off'); 
        EEG = pop_saveset( EEG, [subject '_IIR_' highpass_str{i} '.set'], IIR); 
    end
end

%%


























