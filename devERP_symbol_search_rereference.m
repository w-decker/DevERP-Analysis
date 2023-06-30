%% DevERP Analysis Script
% EEG/ERP Operation: Rereference
% Paradigm: Symbol Search Task
% Author: Will Decker

%% Directories

% dirs for linenoise removal data
notch = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/notch';
IIR = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/IIR';
cleanline = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/cleanline';
% zp = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/zp';
% nochange = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/linenoise/workdir/nochange';

% dirs for rereference
avg = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/rereference/workdir/avg';
REST = '/Volumes/lendlab/projects/DevERP/analysis/symbol_search/reference/workdir/avg';

%% load in subjects
linedirs = {notch, IIR, cleanline}; % current directories
notchsubs = {};
IIRsubs = {};
cleanlinesubs = {};
subdirs = {notchsubs, IIRsubs, cleanlinesubs}; % new variables

for i=1:3
    test = dir(fullfile(linedirs{i}, '*.set'));
    subdirs{i} = {test.name}.';
    subdirs{i} = split(subdirs{i}, '.');
    subdirs{i} = subdirs{i}(:, 1);
end
   
notchsubs = subdirs{1};
IIRsubs = subdirs{2};
cleanlinesubs = subdirs{3};

%% Rereference to the avereage

linedirs = {notch, IIR, cleanline};
subdirs = {notchsubs, IIRsubs, cleanlinesubs}; 
numsubjects = length(notchsubs);


for i=1:3
    for s = 1:numsubjects

        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
        eeglab('redraw')

        subject = subdirs{i}{s};

        EEG = pop_loadset([subject '.set'], linedirs{i});
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        EEG = eeg_checkset( EEG );

        EEG = pop_reref( EEG, []);

%         [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'savenew',[linedirs{i} filesep [subject '_reref.set']],'gui','off'); 
%         EEG = pop_saveset( EEG, [subject '_reref.set'], avg); 

        [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject '_reref.set' ],'gui','off'); 
        EEG = pop_saveset( EEG, [subject '_reref.set' ], avg); 
    end
end


