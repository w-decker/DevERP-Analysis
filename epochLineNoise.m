function [EEG, com, ALLEEG, CURRENTSET] = epochLineNoise(EEG,ALLEEG, CURRENTSET, subject_list, workdir, txtdir, erpdir)

EEG = []
com= ''

%%%% DO NOT CHANGE %%%%
linenoise_str = {'_notch', '_IIR', '_cleanline'};
%%%%%%%%%%%%%%%%%%%%%%%

numparams = length(linenoise_str);
numsubject = length(subject_list);


for i = 1:numparams
    for s=1:numsubjects %change number of subjects as needed
        
                 eeglab nogui
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

for i = 1:numparams
    for s=1:numsubjects
    
         eeglab nogui
         subject = subject_list{s};
    
        EEG = pop_loadset('filename',[subject linenoise_str{i} '_epoch_ar.set'],'filepath',erpdir);
        ERP = pop_averager( EEG , 'Criterion', 'good', 'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
        ERP = pop_savemyerp(ERP, 'erpname',[subject linenoise_str{i} '.erp'], 'filename', [subject linenoise_str{i} '.erp'], ...
            'filepath', erpdir, 'Warning', 'on');
    
    end
end


end