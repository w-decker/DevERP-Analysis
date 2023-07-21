%% DevERP Analysis Script
% EEG/ERP Operation(s): Bandpass filter, linenoise removal, rereferencing, clean rawdata (channels), clean rawdata (ASR) ICLabel with ICA
% Paradigm: Sequence Learning
% Author: Will Decker

%% Establish Directories

rawdir = '/Volumes/lendlab/projects/DevERP/analysis/sequence_learning/rawdir';
workdir = '/Volumes/lendlab/projects/DevERP/analysis/sequence_learning/workdir';
txtdir = '/Volumes/lendlab/projects/DevERP/analysis/sequence_learning/txtdir';
erpdir = '/Volumes/lendlab/projects/DevERP/analysis/sequence_learning/erpdir';
mutdir = '/Volumes/lendlab/projects/DevERP/analysis/sequence_learning/txtdir/mut';

%% Load subjects

subjectlist = '/Volumes/lendlab/projects/DevERP/analysis/sequence_learning/txtdir/subjectlist.xlsx';
[d,s,r] = xlsread(subjectlist);
subject_list = r(:,2);
numsubjects = length(s(:,2));
%% Bandbass filter

highpass = [0.01, 0.1, 0.25, 0.50, 0.75, 1];
highpass_str = {'pt01', 'pt1', 'pt25', 'pt5', 'pt75', '1'};

for i = 1:length(highpass)
    for s=1:numsubjects 
        
        subject = subject_list{s};

        EEG = pop_loadset ([subject '.set'],rawdir);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

        EEG  = pop_basicfilter( EEG,  1:129 , 'Boundary', 'boundary', 'Cutoff', [ highpass(i) 30], ...
            'Design', 'butter', 'Filter', 'bandpass', 'Order',4 );
 
        [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject 'H01_L30'],'gui','off'); 
        EEG = pop_saveset( EEG, [workdir filesep [subject '_highpass_' highpass_str{i} '.set']]); 
    end
end

%% ERPLAB

highpass_str = {'1', 'pt1', 'pt01', 'pt25', 'pt5', 'pt75'};

for i = 1:6
    for s=1:numsubjects %change number of subjects as needed
        
                 [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
                 eeglab('redraw');
            
                 subject = subject_list{s};
            
            % Create eventlist, apply binlist, extract epochs
            EEG = pop_loadset('filepath', workdir, 'filename', [subject '_highpass_' highpass_str{i} '.set']);
            [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
            
            EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, ...
                'Eventlist', [txtdir filesep [subject '_highpass_' highpass_str{i} '_eventlist.txt']]); 
            EEG = eeg_checkset( EEG );
            [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); 
            
            EEG  = pop_binlister( EEG , 'BDF', [txtdir filesep 'binlist.txt'], 'ExportEL', ...
                [txtdir filesep [subject '_highpass_' highpass_str{i} '_binlist.txt']],'ImportEL', ...
                [txtdir filesep [subject '_highpass_' highpass_str{i} '_eventlist.txt']], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG' );
            [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            
            EEG = pop_epochbin( EEG , [-500.0  1000.0],  'none'); % GUI: 07-Jun-2023 10:26:59
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'savenew', [workdir filesep [subject '_highpass_' highpass_str{i} 'epoch']], 'gui', 'off');
            
            EEG  = pop_artmwppth( EEG , 'Channel',  [], 'Flag',  1, 'Threshold',  100, 'Twindow', [-500 1000], 'Windowsize',  200, 'Windowstep',  100 ); 
            [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET ,'savenew',[erpdir filesep [subject '_highpass_' highpass_str{i} '_epoch_ar.set']],'gui','off');
    end
end
for i = 1:6
    for s=1:numsubjects
    
         [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
         eeglab('redraw');
    
         subject = subject_list{s};
    
        EEG = pop_loadset('filename',[subject '_highpass_' highpass_str{i} '_epoch_ar.set'],'filepath',erpdir);
        ERP = pop_averager( EEG , 'Criterion', 'good', 'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
        ERP = pop_savemyerp(ERP, 'erpname',[subject '_highpass_' highpass_str{i} '.erp'], 'filename', [subject '_highpass_' highpass_str{i} '.erp'], ...
            'filepath', erpdir, 'Warning', 'off');
    
    end
end

%% Maker ERP list

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


%% MUT
%see documentation here: https://openwetware.org/wiki/Mass_Univariate_ERP_Toolbox:_Appendix

highpass_str = {'1', 'pt1', 'pt01', 'pt25', 'pt5', 'pt75'};
erpnames = {'1_erplist.txt', 'pt1_erplist.txt', 'pt01_erplist.txt', 'pt25_erplist.txt', 'pt5_erplist.txt', 'pt75_erplist.txt'};

for i = 1:6
    data = readtext([txtdir filesep erpnames{i}]);
    GND = erplab2GND(data, 'out_fname', [mutdir filesep 'filter_' highpass_str{i} '.GND']); % load in .erp files
    bin_dif(GND, 1, 2)
    tmaxGND(GND, 1, 'time_wind', [150 550], 'plot_gui', ...
        'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
        'output_file', [mutdir filesep 'tmax' highpass_str{i} 'bin1.txt'], 'save_GND', 'yes');
    tmaxGND(GND, 2, 'time_wind', [150 550], 'plot_gui', ...
        'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
        'output_file', [mutdir filesep 'tmax' highpass_str{i} 'bin2.txt'], 'save_GND', 'yes');
    tmaxGND(GND, 3, 'time_wind', [150 550], 'plot_gui', ...
        'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
        'output_file', [mutdir filesep 'tmax' highpass_str{i} 'bin3.txt'], 'save_GND', 'yes');
    tmaxGND(GND, 4, 'time_wind', [150 550], 'plot_gui', ...
        'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
        'output_file', [mutdir filesep 'tmax' highpass_str{i} 'bin4.txt'], 'save_GND', 'yes');
    tmaxGND(GND, 5, 'time_wind', [150 550], 'plot_gui', ...
        'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
        'output_file', [mutdir filesep 'tmax' highpass_str{i} 'bin5.txt'], 'save_GND', 'yes');% computes tmax of bin (in this case, bin 1) within time window (in this case, 150ms-450ms)
end

%% Analyze MUT

struct = tmaxoutputstruct(mutdir, 'dir', 'yes');


%% Notch linear filter
% passband edges of 48, 52


for s=1:numsubjects 

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    eeglab('redraw');
        
    subject = subject_list{s};

    EEG = pop_loadset ([subject '_highpass_pt1.set'],workdir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

    EEG  = pop_eegfiltnew( EEG, 'locutoff', 52, 'hicutoff', 48);

    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject '_notch_'],'gui','off'); 
    EEG = pop_saveset( EEG, [subject '_notch.set'], workdir); 
end

%% IIR
locutoff = 52;
hicutoff = 48;

for s=1:numsubjects 

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    eeglab('redraw');
        
    subject = subject_list{s};

    EEG = pop_loadset ([subject '_highpass_pt1.set'],workdir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

    EEG = pop_iirfilt( EEG, 48, 52);

    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject '_IIR_' ],'gui','off'); 
    EEG = pop_saveset( EEG, [subject '_IIR.set'], workdir); 
end

%% Cleanline
% Cleanline plugin must be installed


for s = 1:numsubjects

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    eeglab('redraw');

    subject = subject_list{s};

    EEG = pop_loadset ([subject '_highpass_pt1.set'],workdir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

    EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:129] ,'computepower',1,'linefreqs',60, ...
        'newversion',0,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',0, ...
        'sigtype','Channels','taperbandwidth',2,'tau',100,'verb',1,'winsize',4,'winstep',1);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 

    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject '_cleanline_'],'gui','off'); 
    EEG = pop_saveset( EEG, [subject '_cleanline.set'], workdir); 

end

%% ERPLAB

linenoise_str = {'_notch', '_IIR', '_cleanline'};

for i = 1:3
    for s=1:numsubjects %change number of subjects as needed
        
                 [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
                 eeglab('redraw');
            
                 subject = subject_list{s};
            
            % Create eventlist, apply binlist, extract epochs
            EEG = pop_loadset('filepath', workdir, 'filename', [subject linenoise_str{i} '.set']);
            [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
            
            EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, ...
                'Eventlist', [txtdir filesep [subject linenoise_str{i} '_eventlist.txt']]); 
            EEG = eeg_checkset( EEG );
            [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); 
            
            EEG  = pop_binlister( EEG , 'BDF', [txtdir filesep 'binlist.txt'], 'ExportEL', ...
                [txtdir filesep [subject linenoise_str{i} '_binlist.txt']],'ImportEL', ...
                [txtdir filesep [subject linenoise_str{i}  '_eventlist.txt']], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG' );
            [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            
            EEG = pop_epochbin( EEG , [-500.0  1000.0],  'none'); % GUI: 07-Jun-2023 10:26:59
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'savenew', [workdir filesep [subject subject linenoise_str{i} 'epoch']], 'gui', 'off');
            
            EEG  = pop_artmwppth( EEG , 'Channel',  [], 'Flag',  1, 'Threshold',  100, 'Twindow', [-500 1000], 'Windowsize',  200, 'Windowstep',  100 ); 
            [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET ,'savenew',[erpdir filesep [subject linenoise_str{i} '_epoch_ar.set']],'gui','off');
    end
end

for i = 1:3
    for s=1:numsubjects
    
         [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
         eeglab('redraw');
    
         subject = subject_list{s};
    
        EEG = pop_loadset('filename',[subject linenoise_str{i} '_epoch_ar.set'],'filepath',erpdir);
        ERP = pop_averager( EEG , 'Criterion', 'good', 'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
        ERP = pop_savemyerp(ERP, 'erpname',[subject linenoise_str{i} '.erp'], 'filename', [subject linenoise_str{i} '.erp'], ...
            'filepath', erpdir, 'Warning', 'on');
    
    end
end
%% make ERP list
linenoise_str = {'_notch', '_IIR', '_cleanline'};
erpnames = {'notch_erplist.txt', 'IIR_erplist.txt', 'cleanline_erplist.txt'};
for j = 1:3
    fileID = fopen([txtdir filesep erpnames{j}], 'w');
    for i = 1:numsubjects
        subject = subject_list{i};
        data = fullfile(erpdir, [subject linenoise_str{j} '.erp']);
        fprintf(fileID, '%s\n', data);
    end
    fclose(fileID);
end


%% MUT
%see documentation here: https://openwetware.org/wiki/Mass_Univariate_ERP_Toolbox:_Appendix

linenoise_str = {'_notch', '_IIR', '_cleanline'};
strs4output = {'notch', 'IIR', 'cleanline'};

erpnames = {'notch_erplist.txt', 'IIR_erplist.txt', 'cleanline_erplist.txt'};

for i = 1:3
    data = readtext([txtdir filesep erpnames{i}]);
    GND = erplab2GND(data, 'out_fname', [mutdir filesep strs4output{i} '.GND']); % load in .erp files
    tmaxGND(GND, 1, 'time_wind', [150 450], 'plot_gui', ...
        'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
        'output_file', [mutdir filesep 'tmax' linenoise_str{i} 'bin1.txt'], 'save_GND', 'yes');             
    tmaxGND(GND, 2, 'time_wind', [150 450], 'plot_gui', ...
        'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
        'output_file', [mutdir filesep 'tmax' linenoise_str{i} 'bin2.txt'], 'save_GND', 'yes');
    tmaxGND(GND, 3, 'time_wind', [150 450], 'plot_gui', ...
        'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
        'output_file', [mutdir filesep 'tmax' linenoise_str{i} 'bin3.txt'], 'save_GND', 'yes');
    tmaxGND(GND, 4, 'time_wind', [150 450], 'plot_gui', ...
        'no', 'plot_raster', 'no', 'plot_mn_topo', 'no', ...
        'output_file', [mutdir filesep 'tmax' linenoise_str{i} 'bin4.txt'], 'save_GND', 'yes');% computes tmax of bin (in this case, bin 1) within time window (in this case, 150ms-450ms)
end
%% Analyze MUT

struct = tmaxoutputstruct(mutdir, 'dir', 'yes');

