function [EEG, com, ALLEEG, CURRENTSET] = epochFilter(EEG,ALLEEG, CURRENTSET, subject_list, workdir, txtdir, erpdir)
%EPOCHFILTER Epochs filtered data. Hard coded to the analysis and cannot be
%transferred to other epoching operations of other parameters. This is
%because of the "filter string" used to name and save the files that have
%been epoched. Of course there are ways around this but this was the
%fastest thing to do because the source code for each epoch[operation]
%function was already written. A wrapper has been created (epochWrapper.m)
%which calls whatever epoching function for the specific signal processing
%operation.

EEG =[]
com = ''

%%%% DO NOT CHANGE %%%%
highpass = [0.01, 0.1, 0.25, 0.50, 0.75, 1];
highpass_str = {'pt01', 'pt1', 'pt25', 'pt5', 'pt75', '1'};
%%%%%%%%%%%%%%%%%%%%%%%

numparams = length(highpass);
numsubjects = length(subject_list);

for i = 1:numparams
    for s=1:numsubjects %change number of subjects as needed
        
                 eeglab nogui
            
                 subject = subject_list{s};
            
            % Create eventlist, apply binlist, extract epochs
            EEG = pop_loadset('filepath', workdir, 'filename', [subject '_highpass_' highpass_str{i} '.set']);
            
            EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, ...
                'Eventlist', [txtdir filesep [subject '_highpass_' highpass_str{i} '_eventlist.txt']]); 
            EEG = eeg_checkset( EEG );
            [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); 
            
            EEG  = pop_binlister( EEG , 'BDF', [txtdir filesep 'binlist.txt'], 'ExportEL', ...
                [txtdir filesep [subject '_highpass_' highpass_str{i} '_binlist.txt']],'ImportEL', ...
                [txtdir filesep [subject '_highpass_' highpass_str{i} '_eventlist.txt']], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG' );
            [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            
            EEG = pop_epochbin( EEG , [-500.0  1000.0],  'none'); % GUI: 07-Jun-2023 10:26:59
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'savenew', [workdir filesep [subject '_highpass_' highpass_str{i} '_epoch']], 'gui', 'off');
            
            EEG  = pop_artmwppth( EEG , 'Channel',  [], 'Flag',  1, 'Threshold',  100, 'Twindow', [-500 1000], 'Windowsize',  200, 'Windowstep',  100 ); 
            [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET ,'savenew',[erpdir filesep [subject '_highpass_' highpass_str{i} '_epoch_ar.set']],'gui','off');
    end
end
for i = 1:numparams
    for s=1:numsubjects
    
         eeglab nogui
    
         subject = subject_list{s};
    
        EEG = pop_loadset('filename',[subject '_highpass_' highpass_str{i} '_epoch_ar.set'],'filepath',erpdir);
        ERP = pop_averager( EEG , 'Criterion', 'good', 'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
        ERP = pop_savemyerp(ERP, 'erpname',[subject '_highpass_' highpass_str{i} '.erp'], 'filename', [subject '_highpass_' highpass_str{i} '.erp'], ...
            'filepath', erpdir, 'Warning', 'off');
    
    end
end

end