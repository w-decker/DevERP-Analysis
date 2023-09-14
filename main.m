%% DevERP Analysis Script
% Author: Will Decker

% TO DO:
% - look at the ERPLAB DQ scripts on OSF and get custom RMS(aSME) values
% during grandaveraging! 
% - Write script to calculate min absolute difference for RMS(aSME) scores
% for each preprocessing step...i.e., GET THE WINNERS!

%% Initialize directories

sys = system('env'); % use if needed
user = getenv('USER'); % use if needed

rawdir = '/Volumes/lendlab/projects/DevERP/SPR_analysis/rawdir'; % should contain .set files. If not, see 'checkeventcodes.m'
workdir = '/Volumes/lendlab/projects/DevERP/SPR_analysis/workdir';
txtdir = '/Volumes/lendlab/projects/DevERP/SPR_analysis/txtdir';
erpdir = '/Volumes/lendlab/projects/DevERP/SPR_analysis/erpdir';

%% Load in subject list
% See https://github.com/w-decker/DevERP-Simplified/wiki/Additional-Resources for creating this subject lists

[N, T, R] = xlsread([txtdir filesep 'subjectlist.xlsx']);
subject_list = cellfun(@(x) string(x), T(:, 2)); % changes values in cell to strings

%% Remove unnecessary channels

chans2remove = [8, 14, 17, 21, 25, 48, 43, 68, 73, 81, 88, 94, 119, 120, 125, 126, 127, 128].'; % channels to remove a la Langer et al. (2017)
chanlist = [1:129].'; % total number of channels

numsubjects = length(subject_list);

for i=1:numsubjects
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

numsubjects = length(subject_list);
numparams = length(highpass);
for i = 1:numparams
    
    eeglab nogui

    for s=1:numsubjects
        subject = subject_list{s};

        % load in datasets
        EEG = pop_loadset([workdir filesep [subject '_chansrm_.set']]);

        % filter the data
        EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff', [ highpass(i) 30], ...
                'Design', 'butter', 'Filter', 'bandpass', 'Order',4 );

        % save dataset
        EEG = pop_saveset( EEG, [workdir filesep [subject '_highpass_' highpass_str{i} '.set']]);
    end
end

%% Epoch filter data

EEG = epochWrapper(EEG,ALLEEG, CURRENTSET, 'filter', subject_list, workdir, txtdir, erpdir);

%% Make ERP list for filter data

highpass_str = {'1', 'pt1', 'pt01', 'pt25', 'pt5', 'pt75'};
erpnames = {'1_erplist.txt', 'pt1_erplist.txt', 'pt01_erplist.txt', 'pt25_erplist.txt', 'pt5_erplist.txt', 'pt75_erplist.txt'};

for j = 1:numparams
    fileID = fopen([txtdir filesep erpnames{j}], 'w');
    for i = 1:numsubjects
        subject = subject_list{i};
        data = fullfile(erpdir, [subject '_highpass_' highpass_str{j} '.erp']);
        fprintf(fileID, '%s\n', data);
    end
    fclose(fileID);
end

%% Analyze SME for filtered data

filter_winner = ''

%% Remove Line noise

numsubjects = length(subject_list);

% notch
for s=1:numsubjects 

    eeglab nogui
    subject = subject_list{s};
    
    % load set 
    EEG = pop_loadset ([subject filter_winner '.set'],workdir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

    % remove line noise
    EEG  = pop_eegfiltnew( EEG, 'locutoff', 52, 'hicutoff', 48);

    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject '_notch'],'gui','off'); 
    EEG = pop_saveset( EEG, [subject '_notch.set'], workdir); 
end

% IIR

locutoff = 52;
hicutoff = 48;

for s=1:numsubjects 

    eeglab nogui
    subject = subject_list{s};

    % loadset
    EEG = pop_loadset ([subject filter_winner '.set'],workdir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

    EEG = pop_iirfilt( EEG, 48, 52);

    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject '_IIR' ],'gui','off'); 
    EEG = pop_saveset( EEG, [subject '_IIR.set'], workdir); 
end

% CleanLine

nchan = [1:EEG.nbchan];

for s = 1:numsubjects

    eeglab nogui
    subject = subject_list{s};

    EEG = pop_loadset ([subject filter_winner '.set'],workdir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

    EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist', nchan,'computepower',1,'linefreqs',60, ...
        'newversion',0,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',0, ...
        'sigtype','Channels','taperbandwidth',2,'tau',100,'verb',1,'winsize',4,'winstep',1);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject '_cleanline'],'gui','off'); 
    EEG = pop_saveset( EEG, [subject '_cleanline.set'], workdir); 

end

%% Epoch line noise data

EEG = epochWrapper(EEG,ALLEEG, CURRENTSET, 'linenoise', subject_list, workdir, txtdir, erpdir);

%% Make ERP list for Line noise data

linenoise_str = {'_notch', '_IIR', '_cleanline'};
erpnames = {'notch_erplist.txt', 'IIR_erplist.txt', 'cleanline_erplist.txt'};
numparams = length(linenoise_str);

for j = 1:numparams
    fileID = fopen([txtdir filesep erpnames{j}], 'w');
    for i = 1:numsubjects
        subject = subject_list{i};
        data = fullfile(erpdir, [subject linenoise_str{j} '.erp']);
        fprintf(fileID, '%s\n', data);
    end
    fclose(fileID);
end

%% Analyze SME for line-noise data

ln_winner = '';

%% Rereference to the Cz
for s = 1:numsubjects
    
    eeglab nogui
    subject = subject_list{s};

    EEG = pop_loadset([subject ln_winner '.set'], workdir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
 
    EEG = pop_reref( EEG, 129);

    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject '_reref.set' ],'gui','off'); 
    EEG = pop_saveset( EEG, [subject '_reref.set' ], workdir); 
end


%% clean_rawdata channel rejection

% set parameters
a = linspace(0.15, 0.975, 20);
aa = [0.15 0.975];
a1 = [a(1), a(4)];
a2 = [a(5), a(8)];
a3 = [a(9), a(12)];
a4 = [a(13), a(16)];
a5 = [a(17), a(20)];

% variables to be used
params = {aa, a1, a2, a3, a4, a5};
paramstr = {'_aa' '_a1', '_a2', '_a3', '_a4', '_a5'};

numparams = length(params);
numsubjects = length(subject_list);

for i = 1:numparams
    for s = 1:numsubjects
        
        eeglab nogui
        subject = subject_list{s};
    
        EEG = pop_loadset('filename',[subject  '_reref.set'],'filepath', workdir);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        EEG = eeg_checkset( EEG );
        
        % clean_raw_data
        EEG = clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',params{i} , ...
            'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off', ...
            'BurstRejection','off','Distance','Euclidian');
        
        % save
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew', ...
            [workdir filesep [subject paramstr{i} '_crd_channels.set']],'gui','off'); 
    end
end

%% Epoch clean_rawdata

EEG = epochWrapper(EEG,ALLEEG, CURRENTSET, 'channelrej', subject_list, workdir, txtdir, erpdir);

%% Make ERP List for clean_rawdata

paramstr = {'_a1', '_a2', '_a3', '_a4', '_a5'};
filenames = {'a1_erplist.txt', 'a2_erplist.txt', 'a3_erplist.txt', 'a4_erplist.txt', 'a5_erplist.txt'};

numparams = length(paramstr);
numsubjects = length(subject_list);

for j = 1:numparams
    fileID = fopen(filenames{j}, 'w');

    for i = 1:numsubjects
        subject = subject_list{i};
        data = fullfile(erpdir, [subject paramstr{j} '_crd_channels.erp']);
        fprintf(fileID, '%s\n', data);
    end

    fclose(fileID);
end

%% Analyze SME for clean_rawdata

crd_winner = '';

%% Artifact subspace rejection (ASR)

% set parameters
a = linspace(0, 100, 5);
a1 = 5;
a2 = a(2);
a3 = a(3);
a4 = a(4);
a5 = a(5);

% variables to be used
params = {a1, a2, a3, a4, a5};
paramstr = {'_a1', '_a2', '_a3', '_a4', '_a5'};

numparams = length(params);
numsubjects = length(subject_list);

for i=1:numparams
    for s=1:numsubjects
    
    eeglab nogui
    subject = subject_list{s};

    % load data
    EEG = pop_loadset('filename',[subject crd_winner '.set'],'filepath',workdir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );

    % run ASR
    EEG = clean_asr(EEG, params{i});
    
    % save
    EEG = pop_saveset(EEG, 'filename',[subject paramstr{i} '_asr.set'],'filepath',workdir); 
    end
end

%% Epoch ASR

EEG = epochWrapper(EEG,ALLEEG, CURRENTSET, 'asr', subject_list, workdir, txtdir, erpdir);

%% Make ERP List for ASR

paramstr = {'_a1', '_a2', '_a3', '_a4', '_a5'};
filenames = {'a1_erplist.txt', 'a2_erplist.txt', 'a3_erplist.txt', 'a4_erplist.txt', 'a5_erplist.txt'};

numparams = length(paramstr);
numsubjects = length(subject_list);

for j = 1:numparams
    fileID = fopen(filenames{j}, 'w');

    for i = 1:numsubjects
        subject = subject_list{i};
        data = fullfile(erpdir, [subject paramstr{j} '_asr.erp']);
        fprintf(fileID, '%s\n', data);
    end

    fclose(fileID);
end

%% Analyze SME for clean_rawdata

asr_winner = '';

%% ICA

numsubjects = length(subject_list);

for s=1:numsubjects

    eeglab nogui
    subject = subject_list{s};

    % load set
    EEG = pop_loadset('filename',[subject asr_winner '.set'],'filepath',workdir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    
    % run ICA
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

    % save set
    EEG = pop_saveset(EEG, 'filename',[subject '_ICA.set'],'filepath',workdir); 

end


%% ICLABEL

% parameters
thresholds = {[0.5 0.9], [0.5 1], [0.7 0.9], [0.7 1]};
tstrings = {'_59', '_51', '_79', '_71' };

numparams = length(thresholds);
numsubjects = length(subject_list);

for i=1:numparams
    for s = 1:numsubjects

    subject = subject_list{s};
    eeglab nogui

    % load set
    EEG = pop_loadset('filename',[subject '_ICA.set'],'filepath',workdir);

    % get channel location file
    EEG = pop_editset(EEG, 'run', [], 'chanlocs', '/Volumes/lendlab/projects/DevERP/analysis/data/GSN-HydroCel-129.sfp');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = eeg_checkset( EEG );

    % run IC Label
    EEG = pop_iclabel(EEG, 'default');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

    % flag components
    EEG = pop_icflag(EEG, [NaN NaN;thresholds{i};thresholds{i};NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = eeg_checkset( EEG );

    % remove artifacts and save
    EEG = pop_subcomp( EEG, [], 0);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'savenew',[workdir filesep [ subject tstrings{i} '_ICLABEL.set']],'gui','off'); 
    end

end

%% Epoch IC Label

EEG = epochWrapper(EEG,ALLEEG, CURRENTSET, 'ic', subject_list, workdir, txtdir, erpdir);

%% Make ERP list for IC Label

tstrings = {'_59_ic', '_51_ic', '_79_ic', '_71_ic' };
erpnames = {'59_ic_erplist.txt', '51_ic_erplist.txt', '79_ic_erplist.txt', '71_ic_erplist.txt'};

numparams = length(tstrings);
numsubjects = length(subject_list);

for j = 1:numparams
    fileID = fopen([txtdir filesep erpnames{j}], 'w');
    for i = 1:numsubjects
        subject = subject_list{i};
        data = fullfile(erpdir, [subject tstrings{j} '_ICLABEL.erp']);
        fprintf(fileID, '%s\n', data);
    end
    fclose(fileID);
end

%% Analyze SME for IC Label

ic_winner = '';


