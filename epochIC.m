function [EEG, com, ALLEEG, CURRENTSET]  = epochIC(EEG, ALLEEG, CURRENTSET, subject_list, workdir, txtdir, erpdir)

EEG = []
com = ''

%%%% DO NOT CHANGE %%%%
thresholds = {[0.5 0.9], [0.5 1], [0.7 0.9], [0.7 1]};
tstrings = {'_59', '_51', '_79', '_71', '_man' };
%%%%%%%%%%%%%%%%%%%%%%%

numparams = length(thresholds);
numsubjects = length(subject_list);


for i=1:numparams
    for s=1:numsubjects
    
        eeglab nogui    
        subject = subject_list{s};
    
    % Create eventlist, apply binlist, extract epochs
    EEG = pop_loadset('filepath', workdir, 'filename', [subject tstrings{i} '_ICLABEL.set']);
    
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, ...
        'Eventlist', [txtdir filesep [subject tstrings{i} '_ICLABEL_eventlist.txt']]); 
    EEG = eeg_checkset( EEG );
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); 
    
    EEG  = pop_binlister( EEG , 'BDF', [txtdir filesep 'binlist.txt'], 'ExportEL', ...
        [txtdir filesep [subject tstrings{i} '_ICLABEL_binlist.txt']],'ImportEL', ...
        [txtdir filesep [subject  tstrings{i} '_ICLABEL_eventlist.txt']], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG' );
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    EEG = pop_epochbin( EEG , [-500.0  1000.0],  'none'); % GUI: 07-Jun-2023 10:26:59
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'savenew', [workdir filesep [subject tstrings{i} '_ICLABEL_epoch']], 'gui', 'off');
    
    EEG  = pop_artmwppth( EEG , 'Channel',  [], 'Flag',  1, 'Threshold',  100, 'Twindow', [-500 1000], 'Windowsize',  200, 'Windowstep',  100 ); 
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET ,'savenew',[erpdir filesep [subject tstrings{i} '_ICLABEL_epoch_ar.set']],'gui','off');

    end

end

for i = 1:numparams
    for s=1:numsubjects
    
         eeglab nogui
    
         subject = subject_list{s};
    
        EEG = pop_loadset('filename',[subject tstrings{i} '_ICLABEL_epoch_ar.set'],'filepath',erpdir);
        ERP = pop_averager( EEG , 'Criterion', 'good', 'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
        ERP = pop_savemyerp(ERP, 'erpname',[subject tstrings{i} '_ICLABEL' '.erp'], 'filename', [subject tstrings{i} '_ICLABEL' '.erp'], ...
            'filepath', erpdir, 'Warning', 'off');
    
    end
end


end