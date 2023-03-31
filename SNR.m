%% Signal to Noise Ratio
% Author: Will Decker

%% Load files

eeglab nogui

% establish directories
dir = '/path/to/dir'

% establish subject list
[d,s,r] = xlsread ('icalist.xlsx'); % Type the name of the .xlsx file within the ''(quotes).
subject_list = r;
numsubjects = (length(s));

% import data
for i = 1:numsubjects
    subjects = subject_list{i};
    EEG = pop_loadset([subjects '.set'], dir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
end

%% Epoch data 


%% Extract mean amplitude from signal


%% Extract mean amplitude from noise


%% Calculate SNR