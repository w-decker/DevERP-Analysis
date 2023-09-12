function SME = calculateSME(ERP, timewindow)
%CALCULATESME Manually calculate SME values for single subjects
%   Detailed explanation goes here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% establish SME struct and get data
SME = struct();
SME.data = ERP.bindata;

% get SME scores
timewindow = 300:500;
SME.sme = [];
N = size(SME.data,3);
steps = linspace(1, size(SME.data, 2), 10);
SME.sme = std(mean(SME.data(:, timewindow, 1:N), 2) ;

SME.sme = ;

new = [x_1 x_2 x_3]

t = mean(new, 2)
std(t)














end