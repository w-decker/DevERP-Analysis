%% DevERP Analysis Script
% Paradigm: Symbol Search Task
% Author: Will Decker

%% Directories

rawdir ='/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/renamedir';

dir1 = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/workdir/1';
pt1dir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/workdir/pt1';
pt01dir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/workdir/pt01';
pt25dir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/workdir/pt25';
pt5dir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/workdir/pt5';
pt75dir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/workdir/pt75';

dir1erp = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/erpdir/erp_1';
pt1erp = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/erpdir/erp_pt1';
pt01erp = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/erpdir/erp_pt01';
pt25erp = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/erpdir/erp_pt25';
pt5erp = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/erpdir/erp_pt5';
pt75erp = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/erpdir/erp_pt75';

dir1txt = '/Volumes/LENDLAB/projects/DevERP/analysis/symbol_search/filter/txtdir/1';
pt1txt = '/Volumes/LENDLAB/projects/DevERP/analysis/symbol_search/filter/txtdir/pt1';
pt01txt ='/Volumes/LENDLAB/projects/DevERP/analysis/symbol_search/filter/txtdir/pt01';
pt25txt = '/Volumes/LENDLAB/projects/DevERP/analysis/symbol_search/filter/txtdir/pt25';
pt5txt = '/Volumes/LENDLAB/projects/DevERP/analysis/symbol_search/filter/txtdir/pt5';
pt75txt = '/Volumes/LENDLAB/projects/DevERP/analysis/symbol_search/filter/txtdir/pt75';

txtdir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/txtdir';
mutdirtxt = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/txtdir/mut';
mutdirerp = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/erpdir/mut';

%% Load subjects

% Load subjects

subjectlist = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/filter/scripts/subjectlist.xlsx';
[d,s,r] = xlsread(subjectlist);
subject_list = r;
numsubjects = length(s);
subjects = subject_list(:, 2);


%% Bandbass filter

highpass = [0.01, 0.1, 0.25, 0.50, 0.75, 1];
highpass_str = {'pt01', 'pt1', 'pt25', 'pt5', 'pt75', '1'};

for i = 1:length(highpass)
    for s=1:numsubjects 
        
        subject = subjects{s};

        EEG = pop_loadset ([subject '.set'],rawdir);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

        EEG  = pop_basicfilter( EEG,  1:129 , 'Boundary', 'boundary', 'Cutoff', [ highpass(i) 30], ...
            'Design', 'butter', 'Filter', 'bandpass', 'Order',4 );
 
        [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject 'H01_L30'],'gui','off'); 
        EEG = pop_saveset( EEG, [subject '_highpass_' highpass_str{i} '.set'], [workdir filesep (i)]); 
    end
end

%% ERPLAB

dirnames = {dir1, pt1dir, pt01dir, pt25dir, pt5dir, pt75dir};
highpass_str = {'1', 'pt1', 'pt01', 'pt25', 'pt5', 'pt75'};
txtdirnames = {dir1txt, pt1txt, pt01txt, pt25txt, pt5txt, pt75txt};
erpdirnames = {dir1erp, pt1erp, pt01erp, pt25erp, pt5erp, pt75erp};


for i = 1:6
    for s=1:numsubjects %change number of subjects as needed
        
                 [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
                 eeglab('redraw');
            
                 subject = subjects{s};
            
            % Create eventlist, apply binlist, extract epochs
            EEG = pop_loadset('filepath', dirnames{i}, 'filename', [subject '_highpass_' highpass_str{i} '.set']);
            [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
            
            EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, ...
                'Eventlist', [txtdirnames{i} filesep [subject '_highpass_' highpass_str{i} '_eventlist.txt']]); 
            EEG = eeg_checkset( EEG );
            [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); 
            
            EEG  = pop_binlister( EEG , 'BDF', [txtdir filesep 'binlist.txt'], 'ExportEL', ...
                [txtdirnames{i} filesep [subject '_highpass_' highpass_str{i} '_binlist.txt']],'ImportEL', ...
                [txtdirnames{i} filesep [subject '_highpass_' highpass_str{i} '_eventlist.txt']], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG' );
            [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            
            EEG = pop_epochbin( EEG , [-500.0  1000.0],  'none'); % GUI: 07-Jun-2023 10:26:59
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'savenew', [subject '_highpass_' highpass_str{i}], 'gui', 'off');
            
            EEG  = pop_artmwppth( EEG , 'Channel',  [], 'Flag',  1, 'Threshold',  100, 'Twindow', [-500 1000], 'Windowsize',  200, 'Windowstep',  100 ); 
            [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET ,'savenew',[erpdirnames{i} filesep [subject '_highpass_' highpass_str{i} '_epoch_ar.set']],'gui','off');
    end
end
%%
for i = 1:6
    for s=1:numsubjects
    
         [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
         eeglab('redraw');
    
         subject = subjects{s};
    
        EEG = pop_loadset('filename',[subject '_highpass_' highpass_str{i} '_epoch_ar.set'],'filepath',erpdirnames{i});
        ERP = pop_averager( EEG , 'Criterion', 'good', 'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
        ERP = pop_savemyerp(ERP, 'erpname',[subject '_highpass_' highpass_str{i} '.erp'], 'filename', [subject '_highpass_' highpass_str{i} '.erp'], ...
            'filepath', erpdirnames{i}, 'Warning', 'on');
    
    end
end

%% MUT
%see documentation here: https://openwetware.org/wiki/Mass_Univariate_ERP_Toolbox:_Appendix

dirnames = {dir1, pt1dir, pt01dir, pt25dir, pt5dir, pt75dir};
highpass_str = {'1', 'pt1', 'pt01', 'pt25', 'pt5', 'pt75'};
txtdirnames = {dir1txt, pt1txt, pt01txt, pt25txt, pt5txt, pt75txt};
erpdirnames = {dir1erp, pt1erp, pt01erp, pt25erp, pt5erp, pt75erp};


for i = 2:6
    data = readtext([erpdirnames{i} '/erplist.txt']);
    GND = erplab2GND(data, 'out_fname', [mutdirerp filesep 'filter_' highpass_str{i} '.GND']); % load in .erp files
    GND = bin_dif(GND, 1, 2);
    tmaxGND(GND, 1, 'time_wind', [150 450], 'plot_gui', ...
        'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
        'output_file', [mutdirtxt filesep 'tmax' highpass_str{i} 'bin1.txt'], 'save_GND', 'yes');
    tmaxGND(GND, 2, 'time_wind', [150 450], 'plot_gui', ...
        'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
        'output_file', [mutdirtxt filesep 'tmax' highpass_str{i} 'bin2.txt'], 'save_GND', 'yes');
    tmaxGND(GND, 3, 'time_wind', [150 450], 'plot_gui', ...
        'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
        'output_file', [mutdirtxt filesep 'tmax' highpass_str{i} 'bin3.txt'], 'save_GND', 'yes');% computes tmax of bin (in this case, bin 1) within time window (in this case, 150ms-450ms)
end
