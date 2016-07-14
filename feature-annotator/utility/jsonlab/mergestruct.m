function s = mergestruct(s1,s2)
% s = MERGESTRUCT(s1, s2)
%
%   Combines the data from two structures into a single structure. Data
%   from s2 will have precedence over data from s1.

if(~isstruct(s1) || ~isstruct(s2))
    error('mergestruct requires two structs as input');
end

if(length(s1)>1 || length(s2)>1)
    error('can not merge struct arrays');
end

fn=fieldnames(s2);
s=s1;
for i=1:length(fn)              
    s=setfield(s,fn{i},getfield(s2,fn{i}));
end

