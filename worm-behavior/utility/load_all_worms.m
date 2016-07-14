function load_all_worms(root_directory, mfilename)
% worm_postures = load_all_worms(root_directory)
%
%   Loads all the data stored beneath root_directory into an array of
%   WormPosture objects.

if nargin < 2
    
    mfilename = fullfile(root_directory, 'all_worms');
    
end

all_files = get_all_files(root_directory);
N = length(all_files);

mkdir(fullfile(root_directory, 'worms'));

for i = 1:length(all_files)
    
    worm = WormPosture.from_mrc_matfile(all_files{i});
    
    save(fullfile(root_directory, 'worms', sprintf('worm_%04d.mat', i)), ...
        'worm');
    
    disp(sprintf('Completed worm %d of %d', i, N));
    
end