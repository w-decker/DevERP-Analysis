function [EEG, com, ALLEEG, CURRENTSET] = epochChannelRej(EEG,ALLEEG, CURRENTSET, subject_list, workdir, txtdir, erpdir)

EEG = []
com = ''

%%%% DO NOT CHANGE %%%%
% set parameters
a = linspace(0.15, 0.975, 20);
aa = [0.15 0.975];
a1 = [a(1), a(4)];
a2 = [a(5), a(8)];
a3 = [a(9), a(12)];
a4 = [a(13), a(16)];
a5 = [a(17), a(20)];

params = {a1, a2, a3, a4, a5};
paramstr = {'_a1', '_a2', '_a3', '_a4', '_a5'};
%%%%%%%%%%%%%%%%%%%%%%%

numparams = length(params);
numsubjects = length(subject_list);

for i = 1:numparams
    for s=1:numsubjects %change number of subjects as needed
        
        eeglab nogui
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
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'savenew', [workdir filesep [subject paramstr{i} '_crd_channels_epoch']], 'gui', 'off');
        
        EEG  = pop_artmwppth( EEG , 'Channel',  [], 'Flag',  1, 'Threshold',  100, 'Twindow', [-500 1000], 'Windowsize',  200, 'Windowstep',  100 ); 
        [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET ,'savenew',[erpdir filesep [subject paramstr{i} '_crd_channels_epoch_ar.set']],'gui','off');
    end
end

for i = 1:numparams
    for s=1:numsubjects
        
        eeglab nogui
        subject = subject_list{s};
    
        EEG = pop_loadset('filename',[subject paramstr{i} '_crd_channels_epoch_ar.set'],'filepath',erpdir);
        ERP = pop_averager( EEG , 'Criterion', 'good', 'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
        ERP = pop_savemyerp(ERP, 'erpname',[subject paramstr{i} '_crd_channels.erp'], 'filename', [subject paramstr{i} '_crd_channels.erp'], ...
            'filepath', erpdir, 'Warning', 'off', 'overwriteatmenu', 'off');
    end
end
end