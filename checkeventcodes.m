%% Checks eventcodes and renames file from DevERP dataset
% Author: Will Decker

datadir = dir('/Volumes/lendlab/projects/DevERP/analysis/data/A00053375/EEG/raw/raw_format/'); % change for each subject
filedir = fullfile(datadir(1).folder, datadir(1).name);
datadir = dir(fullfile(filedir, '*.raw'));  % Filter only files with '.raw' extension
numfiles = numel(datadir);

codes = [90, 91, 92, 93, 94, 95, 96, 97, 81, 82, 83, 84, 85, 86];

for i = 1:numfiles
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'setname', 'test', 'gui', 'off');
    file = fullfile(filedir, datadir(i).name);
    EEG = pop_fileio(file, 'dataformat', 'auto');
    
    if ~isempty(EEG.event)
        first_event_code = EEG.event(1).type;
        if ismember(first_event_code, codes)
            [~, file_name, ext] = fileparts(file);
            new_file_name = [file_name '_' num2str(first_event_code) ext];
            EEG = pop_saveset(EEG, 'filename', new_file_name, 'filepath', filedir);
        end
    end
end
