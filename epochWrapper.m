function [EEG, com, ALLEEG, CURRENTSET] = epochWrapper(EEG, ALLEEG, CURRENTSET, epochtype, subject_list, workdir, txtdir, erpdir)
%EPOCHDATA Epochs data to requisite parameters for DevERP project
%   EEG -- EEG dataset to input
%   subs -- subject list
% ---------
% Additional optional args
% ---------
% operation -- (char) specify the type of signal processing ('filter',
% 'linenoise', 'channelrej', 'asr', 'ic')s
% operation that was conducted on the to-be epoched data
% parameterStrings -- (array or cell of string or char) the different parameter strings used
% to name different iterations of the preprocessing step.
% ---------
% Example
% ---------
% filter_strings = {'0.1', '0.75', '1.0'};
% [N, T, R] = xlsread('subjects.xlsx')
% subject_list = T
% EEG = epochData(EEG, subject_list, 'operation', 'filter', 'parameterStrings', filter_strings)

EEG = [];
com = '';

subject_list=subject_list;
workdir=workdir;
txtdir=txtdir;
erpdir=erpdir;

if strcmp(epochtype, 'filter')
    epochFilter(EEG, ALLEEG, CURRENTSET, subject_list, workdir, txtdir, erpdir)
elseif strcmp(epochtype, 'linenoise')
    epochLineNoise(EEG, ALLEEG, CURRENTSET,subject_list, workdir, txtdir, erpdir)
elseif strcmp(epochtype, 'channelrej')
    epochChannelRej(EEG, ALLEEG, CURRENTSET, subject_list, workdir, txtdir, erpdir)
elseif strcmp(epochtype, 'asr')
    epochASR(EEG, ALLEEG, CURRENTSET, subject_list, workdir, txtdir, erpdir)
elseif strcmp(epochtype, 'ic')
    epochIC(EEG, ALLEEG, CURRENTSET,subject_list, workdir, txtdir, erpdir)
end















end