%% DevERP Analysis Script
% EEG/ERP Operation: Channel Rejection
% Paradigm: Symbol Search Task
% Author: Will Decker

%% Establish directories

workdir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/clean_rawdata_channels/workdir';
txtdir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/clean_rawdata_channels/txtdir';
erpdir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/clean_rawdata_channels/erpdir';

rerefdir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/rereference/workdir';

%% Load subjects

% Load subjects

subjectlist = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/scripts/subjectlist.xlsx';
[d,s,r] = xlsread(subjectlist);
subject_list = r;
numsubjects = length(s);

%% clean_rawdata channel rejection
a = linspace(0.15, 0.975, 20);
a1 = [a(1), a(4)];
a2 = [a(5), a(8)];
a3 = [a(9), a(12)];
a4 = [a(13), a(16)];
a5 = [a(17), a(20)];
params = {a1, a2, a3, a4, a5};
paramstr = {'_a1', '_a2', '_a3', '_a4', '_a5'};


for i = 1:length(params)
    for s = 6:22
    
        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
        eeglab('redraw')
    
        subject = subject_list{s};
    
        EEG = pop_loadset('filename',[subject  '_reref.set'],'filepath','/Volumes/lendlab/projects/DevERP/analysis/symbol_search/rereference/workdir/');
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        EEG = eeg_checkset( EEG );
        EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',params{i} ,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',[workdir filesep [subject paramstr{i} '_crd_channels.set']],'gui','off'); 
    end
end

%% ERPLAB 

params = {a1, a2, a3, a4, a5};
paramstr = {'_a1', '_a2', '_a3', '_a4', '_a5'};

for i = 1:length(paramstr)
for s=1:22 %change number of subjects as needed

         [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
         eeglab('redraw');
    
         subject = subject_list{s};
    
    % Create eventlist, apply binlist, extract epochs
    EEG = pop_loadset('filepath', workdir, 'filename', [subject paramstr{i} '_crd_channels.set']);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, ...
        'Eventlist', [txtdir filesep [subject paramstr{i} '_crd_channels_eventlist.txt']]); 
    EEG = eeg_checkset( EEG );
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); 
    
    EEG  = pop_binlister( EEG , 'BDF', [txtdir filesep 'binlist.txt'], 'ExportEL', ...
        [txtdir filesep [subject paramstr{i} '_crd_channels_binlist.txt']],'ImportEL', ...
        [txtdir filesep [subject paramstr{i} '_crd_channels_eventlist.txt']], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG' );
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    EEG = pop_epochbin( EEG , [-500.0  1000.0],  'none'); % GUI: 07-Jun-2023 10:26:59
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'savenew', [subject paramstr{i} '_crd_channels_epoch'], 'gui', 'off');
    
    EEG  = pop_artmwppth( EEG , 'Channel',  [], 'Flag',  1, 'Threshold',  100, 'Twindow', [-500 1000], 'Windowsize',  200, 'Windowstep',  100 ); 
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET ,'savenew',[erpdir filesep [subject paramstr{i} '_crd_channels_epoch_ar.set']],'gui','off');
end
end

for i = 1:length(paramstr)
for s=1:22

     [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
     eeglab('redraw');

     subject = subject_list{s};

    EEG = pop_loadset('filename',[subject paramstr{i} '_crd_channels_epoch_ar.set'],'filepath',erpdir);
    ERP = pop_averager( EEG , 'Criterion', 'good', 'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
    ERP = pop_savemyerp(ERP, 'erpname',[subject paramstr{i} '_cdr_channels.erp'], 'filename', [subject paramstr{i} '_cdr_channels.erp'], ...
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
        data = fullfile(erpdir, [subject paramstr{j} '_cdr_channels.erp']);
        fprintf(fileID, '%s\n', data);
    end
    fclose(fileID);
end



%%
paramstr = {'_a1', '_a2', '_a3', '_a4', '_a5'};
filenames = {'a1_erplist.txt', 'a2_erplist.txt', 'a3_erplist.txt', 'a4_erplist.txt', 'a5_erplist.txt'};

for j = 1:5
    fileID = fopen(filenames{j}, 'w');
    for i = 1:numsubjects
        data = fullfile(erpdir, [subject paramstr{j} '_cdr_channels.erp']);
        fprintf(fileID, '%s\n', data);
    end
    fclose(fileID);
end



%% MUT
%see documentation here: https://openwetware.org/wiki/Mass_Univariate_ERP_Toolbox:_Appendix

mutdir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/clean_rawdata_channels/txtdir/mut';
paramstr = {'a1', 'a2', 'a3', 'a4', 'a5'};


for i = 1:5
data = readtext([erpdir filesep filenames{i}]);
GND = erplab2GND(data, 'out_fname', [mutdir filesep paramstr{i} '_clean_rawdata_channels.GND']); % load in .erp files
GND = bin_dif(GND, 1, 2);
GND = bin_dif(GND, 2, 1);
tmaxGND(GND, 1, 'time_wind', [150 450], 'plot_gui', ...
    'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
    'output_file', [mutdir filesep paramstr{i} '_tmax_clean_rawdata_channels_bin1.txt'], 'save_GND', 'yes');
tmaxGND(GND, 2, 'time_wind', [150 450], 'plot_gui', ...
    'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
    'output_file', [mutdir filesep paramstr{i} '_tmax_clean_rawdata_channels_bin2.txt'], 'save_GND', 'yes');
tmaxGND(GND, 3, 'time_wind', [150 450], 'plot_gui', ...
    'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
    'output_file', [mutdir filesep paramstr{i} '_tmax_clean_rawdata_channels_bin3.txt'], 'save_GND', 'yes');
tmaxGND(GND, 4, 'time_wind', [150 450], 'plot_gui', ...
    'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
    'output_file', [mutdir filesep paramstr{i} '_tmax_clean_rawdata_channels_bin4.txt'], 'save_GND', 'yes');% computes tmax of bin (in this case, bin 1) within time window (in this case, 150ms-450ms)
end

struct = tmaxoutputstruct(mutdir, 'dir', 'yes');
