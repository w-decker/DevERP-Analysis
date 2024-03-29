function [ERP, erpcom, SME] = analyzeSME2(ALLERP, erpnames, strnames, txtdir, erpdir)
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
%
% NOTE: indices are 7,8,9 for time range of P2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set variables
erpcom = '';
ERP    = preloadERP;
numerpnames = length(erpnames);
SME = struct();
target = timerange;


% create grandaverage
for i=1:numerpnames
    ERP = pop_gaverager([txtdir filesep erpnames{i}], 'DQ_flag', 1);
    ERP = pop_savemyerp(ERP,...
     'erpname', [strnames{i} 'grandaverage'], 'filename', [strnames{i} 'grandaverage.erp'] , 'filepath', erpdir,...
     'Warning', 'off');
end

if ERP.nchan == 111
    nchan = 110;
else 
    nchan = ERP.nchan;
end

% get winner
for i=1:numerpnames
    
    % load in ERP set
    ERP = pop_loaderp( 'filename', [strnames{i} 'grandaverage.erp'], 'filepath', erpdir );

    % set bins
    b = {ERP.dataquality(3).data};
    b1 = b{1, 1}(:, :, 1);
    b2 = b{1, 1}(:, :, 2);
    max1 = mean(max(b1(:, 7:9)));
    min1 = mean(min(b1(1:110, 7:9)));
    max2 = mean(max(b2(1:110, 7:9)));
    min2 = mean(min(b2(1:110, 7:9)));
    max_hat = (max1 + max2)/ sqrt(2); %divide my sqrt of number of bins...it is hard coded here for this project
    min_hat = (min1 + min2)/sqrt(2);
    win = abs(max_hat - min_hat);

    % input into struct
    SME(i).type = strnames{i};
    SME(i).val = win;

end

[t,l] = min([SME.val]);
winner = SME(l).type;
sprintf('The winner of this operation is %s', winner)

% add SME to workspace
assignin('base', 'SME', SME)

% add winner2 to workspace for main.m to use
winner2 = winner;
assignin('base', 'winner2', winner2)

if evalin('base', ('exist("smeoutput", "var")'))
    try
        evalin('base', "smeoutput", smeoutput);
        fieldlen = length(fieldnames(smeoutput));
        smeoutput(fieldlen)
    catch
    end
elseif evalin('base', ('~exist("smeoutput", "var")'))
    smeoutput = struct();
    smeoutput(1).winner = '';
    assignin('base', 'smeoutput', smeoutput)
end

















end