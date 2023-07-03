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



% dirs for linenoise data
notch = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/notch';
IIR = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/IIR';
cleanline = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/cleanline';
zp = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/zp';
nochange = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/nochange';

% text dirs
txtdir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/txtdir';
txtnotch = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/txtdir/cleanline';
txtIIR = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/txtxidr/IIR';
txtcleanline = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/txtdir/cleanline';

% erp dirs 
erpnotch = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/erpdir/notch';
erpIIR = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/erpdir/IIR';
erpcleanline = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/erpdir/cleanline';

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

%% ERPLAB

dirnames = {cleanline, IIR, notch};
highpass_str = {'1', 'pt1', 'pt01', 'pt25', 'pt5', 'pt75'};
filtstrings = {'_cleanline_', '_IIR_', '_notch_'};
txtdirnames = {txtcleanline, txtIIR, txtnotch};
erpdirnames = {erpcleanline, erpIIR, erpnotch};

for i = 1:3
    for j = 1:6
        for s=1:numsubjects %change number of subjects as needed
            
                     [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
                     eeglab('redraw');
                
                     subject = subject_list{s};
                
                % Create eventlist, apply binlist, extract epochs
                EEG = pop_loadset('filepath', dirnames{i}, 'filename', [subject filtstrings{i} highpass_str{j} '.set']);
                [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
                
                EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, ...
                    'Eventlist', [txtdirnames{i} filesep [subject filtstrings{i} highpass_str{j} '_eventlist.txt']]); 
                EEG = eeg_checkset( EEG );
                [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); 
                
                EEG  = pop_binlister( EEG , 'BDF', [txtdir filesep 'binlist.txt'], 'ExportEL', ...
                    [txtdirnames{i} filesep [subject filtstrings{i} highpass_str{j} '_binlist.txt']],'ImportEL', ...
                    [txtdirnames{i} filesep [subject filtstrings{i} highpass_str{j} '_eventlist.txt']], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG' );
                [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                
                EEG = pop_epochbin( EEG , [-500.0  1000.0],  'none'); % GUI: 07-Jun-2023 10:26:59
                [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'savenew', [subject filtstrings{j} highpass_str{j}], 'gui', 'off');
                
                EEG  = pop_artmwppth( EEG , 'Channel',  [], 'Flag',  1, 'Threshold',  100, 'Twindow', [-500 1000], 'Windowsize',  200, 'Windowstep',  100 ); 
                [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET ,'savenew',[erpdirnames{i} filesep [subject filtstrings{i} highpass_str{j} '_epoch_ar.set']],'gui','off');
        end

    end
end

for i = 1:6
    for s=1:numsubjects
    
         [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
         eeglab('redraw');
    
         subject = subjects{s};
    
        EEG = pop_loadset('filename',[subject filtstrings{i} highpass_str{j} '_epoch_ar.set'],'filepath',erpdirnames{i});
        ERP = pop_averager( EEG , 'Criterion', 'good', 'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
        ERP = pop_savemyerp(ERP, 'erpname',[subject filtstrings{i} highpass_str{j} '.erp'], 'filename', [subject filtstrings{i} highpass_str{j} '.erp'], ...
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

%% Analyze MUT output

mutdir = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/txtdir/mut';

struct = tmaxoutputstruct(mutdir, 'dir', 'yes');

%



























