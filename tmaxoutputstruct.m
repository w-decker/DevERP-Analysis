function [tmaxstruct] = tmaxoutputstruct(varargin)
%TMAXOUTPUTSTRUCT Creates a structure for calcsigparams() to read from
%tmaxGND() .txt output.
%   varargin -- input the .txt files you wish to read in. Can be variables or
%   files paths or a dir name
% 
%   OPTIONAL INPUTS
%   'dir' -- ('yes|no') default: 'no' if you are reading in the

%% begin
% get length of varargin for later
lengvars = length(varargin);

% check if user input 'dir' as a parameter and return its position
isdir = false; % default
for i=1:lengvars
    if varargin{i} == 'dir'
        isdir = true;
    end
end
isdir = {isdir};

% if running function using a dir, 
if isdir == true
    txtdir = dir([varargin{1} filesep '*.txt']);
    tmaxstruct = struct([]);
     for i = 1:numel(txtdir)
        curr = readtable([txtdir(i).folder filesep txtdir(i).name], 'Delimiter', ' ');
        curr(130:end, :) = [];
        datapts = curr{2:end, 2:152};
        sigpts = datapts <= 0.05;
        currname = split(txtdir(i).name, '.').';
        currname = currname(1);
        tmaxstruct(i).(string(currname)) = curr;
    
        sumsigs = 0;
        for j = 1:length(sigpts)
            if sigpts(j) == 1
                sumsigs = sumsigs + 1;
            end
        end
        sumsigs = {sumsigs};
        tmaxstruct(i).sumsigs = sumsigs;
     end

elseif dir ~= true
    curr = readtable(varargin{1}, 'Delimiter', ' ');
    curr(130:end,:) = [];
    datapts = curr{2:end, 2:152};
    sigpts = datapts <= 0.05;

   for i = 1:length(sigpts)
       if sigpts(i) == 1
           sumsigs = sumsigs + 1;
       end
    end
    sumsigs = {sumsigs};
    disp(sumsigs(1))
%    
end

% end of function
end
