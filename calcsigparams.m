function [sigparams] = calcsigparams(tmaxoutput,bin, numparams, param)
%CALCSIGPARAMS Determine channel significance relative to another dataset
%   tmaxoutput -- (struct) output space deliminated .txt file that is produced as
%   part of the output from tmaxGND() in the Mass Univariate Analysis
%   Toolbox
%   bin -- (str or char) the bin number used in the tmax test 
%   numparams -- (int) the number of parameters that you wish to see are
%   greater than another
%   param -- (str) the parameter used in the signal processing operation

for i=1:length(tmaxoutput)
    sigs = {i} <= 0.05;
    sigs = numel(sigs);
end

disp(['There are ' num2str(sigs) 'channels in  ' num2str(bin) 'for the parameter ' param '.'])









end