function out_opts = merge_options(set_opts, default_opts)
% out_opts = merge_options(set_opts, default_opts)
%
% Takes in a struct containing options passed to a function and another
% struct of defaults and returns a merged struct that contains all options,
% with set options taking precedence over defaults
% 
% This will often be used with varargin2struct() to allow name-value pairs 
% to be passed to a function

out_opts = set_opts;

f = fieldnames(default_opts);
for i = 1:length(f)
    if ~isfield(out_opts, f{i})
        out_opts = setfield(out_opts, f{i}, getfield(default_opts, f{i}));
    end
end