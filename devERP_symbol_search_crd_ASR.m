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

%%

a = linspace(0, 100, 5);
a1 = 5;
a2 = a(2);
a3 = a(3);
a4 = a(4);
a5 = a(5);
params = {a1, a2, a3, a4, a5};
paramstr = {'_a1', '_a2', '_a3', '_a4', '_a5'};

for i = 1:length(params)
    for s = 1:numsubjects

        subject = subject_list{s};
        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
        eeglab('redraw');

        EEG = pop_loadset('filename',[subject '_crd_channels.set'],'filepath','/Volumes/lendlab/projects/DevERP/analysis/symbol_search/clean_rawdata_channels/workdir/');
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        EEG = eeg_checkset( EEG );
        EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',params{i},'WindowCriterion','off','BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances','off','fusechanrej','off');
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',[workdir filesep [subject paramstr{i} '_crd_ASR.set']],'gui','off');
    end
end
%% ERPLAB 

params = {a1, a2, a3, a4, a5};
paramstr = {'_a1', '_a2', '_a3', '_a4', '_a5'};

for i = 1:length(paramstr)
for s=1:numsubjects %change number of subjects as needed

         [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
         eeglab('redraw');
    
         subject = subject_list{s};
    
    % Create eventlist, apply binlist, extract epochs
    EEG = pop_loadset('filepath', workdir, 'filename', [subject paramstr{i} '_crd_ASR.set']);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, ...
        'Eventlist', [txtdir filesep [subject paramstr{i} '_crd_ASR_eventlist.txt']]); 
    EEG = eeg_checkset( EEG );
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); 
    
    EEG  = pop_binlister( EEG , 'BDF', [txtdir filesep 'binlist.txt'], 'ExportEL', ...
        [txtdir filesep [subject paramstr{i} '_crd_ASR_binlist.txt']],'ImportEL', ...
        [txtdir filesep [subject paramstr{i} '_crd_ASR_eventlist.txt']], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG' );
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    EEG = pop_epochbin( EEG , [-500.0  1000.0],  'none'); % GUI: 07-Jun-2023 10:26:59
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'savenew', [erpdir filesep [subject paramstr{i} '_crd_ASR_epoch']], 'gui', 'off');
    
    EEG  = pop_artmwppth( EEG , 'Channel',  [], 'Flag',  1, 'Threshold',  100, 'Twindow', [-500 1000], 'Windowsize',  200, 'Windowstep',  100 ); 
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET ,'savenew',[erpdir filesep [subject paramstr{i} '_crd_ASR_epoch_ar.set']],'gui','off');
end
end

for i = 1:length(paramstr)
for s=1:numsubjects

     [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
     eeglab('redraw');

     subject = subject_list{s};

    EEG = pop_loadset('filename',[subject paramstr{i} '_crd_ASR_epoch_ar.set'],'filepath',erpdir);
    ERP = pop_averager( EEG , 'Criterion', 'good', 'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
    ERP = pop_savemyerp(ERP, 'erpname',[subject paramstr{i} '_cdr_channels.erp'], 'filename', [subject paramstr{i} '_cdr_ASR.erp'], ...
        'filepath', erpdir, 'Warning', 'off', 'overwriteatmenu', 'off');
end
end

%% create erplist

paramstr = {'_a1', '_a2', '_a3', '_a4', '_a5'};
filenames = {'a1_erplist.txt', 'a2_erplist.txt', 'a3_erplist.txt', 'a4_erplist.txt', 'a5_erplist.txt'};



for j = 1:5
    fileID = fopen(filenames{j}, 'w');
    for i = 1:numsubjects
        subject = subject_list{i};
        data = fullfile(erpdir, [subject paramstr{j} '_cdr_ASR.erp']);
        fprintf(fileID, '%s\n', data);
    end
    fclose(fileID);
end

