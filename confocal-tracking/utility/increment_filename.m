function new_filename = increment_filename(filename)
% new_filename = increment_filename(filename)
%
%   Takes a filename and determines a good name for the next one in a
%   sequence.  It finds the LAST contiguous substring of numbers and
%   replaces it with an incremented string, preserving the length unless
%   there is overflow:
%
%       file_001.xyz -> file_002.xyz
%       file_01.xyz -> file_02.xyz
%       file_9.xyz -> file_10.xyz

pattern = '[0123456789]+';

[start_indices, end_indices] = regexp(filename, pattern);

% start and stop indices for hte string being replaced
s = start_indices(end);
f = end_indices(end);

old_number = str2num(filename(s:f));
old_length = length(filename(s:f));

new_number = old_number + 1;

if length(num2str(new_number)) > old_length
    new_length = length(num2str(new_number));
else
    new_length = old_length;
end

new_filename = [filename(1:s-1) ...
                sprintf(['%0' num2str(new_length) 'd'], new_number) ...
                filename(f+1:end)];
