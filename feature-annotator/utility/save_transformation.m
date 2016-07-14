function save_transformation(tform_data, target_location, t)
% save_transformation(tform_data, target_location, t)
%
%   Saves the fields in tform_data as separate variables in the file
%   sprintf('target_location/u_%05d.mat', t) or ('target_location/u.mat')
%   if t is not specified

if nargin == 3
    filename = fullfile(target_location, sprintf('u_%05d.mat', t));
else 
    filename = fullfile(target_location, 'u.mat');
end

[D,~,~] = fileparts(filename);
if ~exist(D, 'dir')
    mkdir(D);
end

save(filename, '-struct', 'tform_data');
    