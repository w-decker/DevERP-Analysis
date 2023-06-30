function [tmaxoutput] = tmaxoutputstruct(varargin)
%TMAXOUTPUTSTRUCT Creates a structure for calcsigparams() to read from
%tmaxGND() .txt output.
%   varargin -- input the .txt files you wish to read in. Can be variables or
%   files paths or a dir name
% 
%   OPTIONAL INPUTS
%   'dir' -- ('yes|no') default: 'no' if you are reading in the

%% begin
% create empty struct
tmaxoutput = struct([]);

% get length of varargin for later
lengvars = length(varargin);

% check if user input 'dir' as a parameter and return its position
isdir = false;
for i=1:lengvars
    if i == 'dir'
        isdir = true;
        dir2use = varargin(i);
    end
end

% if running function using a dir, 
if isdir == true
    txtdir = varargin{1};
    for i = 1:dir2use
        T = readtable(dir2use{i})
        T([130:end], :) = [];
        tmaxoutput(i) = T
    end
end





end