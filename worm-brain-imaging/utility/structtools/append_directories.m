function s = append_directories(s)
% s = APPEND_DIRECTORIES(s)
%
%   If s has fieldnames 'blah' and 'blah_directory', s.blah is prepended
%   with s.blah_directory (and the necessary file separator).

fields = fieldnames(s);

for i = 1:length(fields)
    
    f = fields{i};
    
    f_dir = [f '_directory'];
    
    f_dir_idx = strcmp(f_dir, fields);
    
    if any(f_dir_idx)
        
        s.(f) = fullfile(s.(f_dir), s.(f));
        
        s = rmfield(s, f_dir);
        
    end
    
end