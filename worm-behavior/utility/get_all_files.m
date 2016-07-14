function files = get_all_files(root_directory)
% files = get_all_files(root_directory)
%
%   Recursively obtains all files in root_directory, storing the resulting
%   filenames in a cell array.

x = dir(root_directory);

files = {};
for i = 3:length(x)
    
    if ~x(i).isdir
        
        files{end+1} = fullfile(root_directory, x(i).name);
        
    elseif x(i).isdir
        
        files = [files ...
            get_all_files(fullfile(root_directory, x(i).name)) ...
        ];
        
    end
    
end