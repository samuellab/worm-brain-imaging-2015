function s = merge_struct(s, s0)
% s = MERGE_STRUCT(s, s0)
%
%   Combines the data from two structures into a single structure. Data
%   from s0 will have precedence over data from s when fields clash.

new_fields = fieldnames(s0);

for i=1:length(new_fields)
    s = setfield(s, new_fields{i}, getfield(s0, new_fields{i}));
end

