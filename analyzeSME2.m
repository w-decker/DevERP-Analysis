function [ERP, erpcom, SME] = analyzeSME2(ALLERP, erpnames, strnames, smenames, timerange, txtdir, erpdir)
% ANALYZESME2 Calculate and analyze SME values created during grandaveraging
% 
% Parameters
% ----------
% erpnames: cell, string
%   Cell of strings with names of erplists
% 
% strnames: cell, string
%   Cell of strings to use for naming grndavg .erps. 1) Should correspond to
%   parameter used during preprocess operation. 2) Must be same length as
%   erpnames. 3) must include an underscore (e.g., {'pt01_', 'pt02_'...}
%
% timerange: cell, int
%   custom time range to look into (e.g., timerange = [200 400]) in ms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set variables
erpcom = '';
ERP    = preloadERP;
numerpnames = length(erpnames);
SME = struct();
%DQ_spec_structure = {'aSME Pool ERPSETs', 'RMS GrandAvg combine Pool ERPSETs', 'RMS GrandAvg combine'}
target = timerange;

% create grandaverage
for i=1:numerpnames
    ERP = pop_gaverager([txtdir filesep erpnames{i}], 'DQ_flag', 1, 'DQ_spec', DQ_spec_structure );
    ERP = pop_savemyerp(ERP,...
     'erpname', [strnames{i} 'grandaverage'], 'filename', [strnames{i} 'grandaverage.erp'] , 'filepath', erpdir,...
     'Warning', 'on');
end

% get winner
epoch_start = ERP.times(1); epoch_end = ERP.times(end);
default_spec = make_DQ_spec([epoch_start epoch_end]);
custom_aSME_spec = default_spec;
DQ_n = struct2cell(custom_aSME_spec); %change to cell array
DQ_n = squeeze(DQ_n(1,:,:));















for i=1:numerpnames





































end