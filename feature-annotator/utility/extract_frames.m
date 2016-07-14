function extract_frames(src, dest, good_frames)
% extract_frames(src, dest, good_frames)
%
%   src: directory containing images to extract along with a 'times.json'
%   file containing the times for each frame.
%
%   dest: target directory.  the extracted frames will be re-indexed and a
%   new 'times.json' file will keep track of the new frame times.

times = loadjson(fullfile(src,'times.json'));

new_times = struct('offset', times.offset, ...
                   'times', times.times(good_frames));
mkdir(dest);               
idx = 1;
for i = good_frames
    copyfile(fullfile(src, sprintf('T_%05d.tif', i)), ...
             fullfile(dest, sprintf('T_%05d.tif', idx)));
    new_times.times(idx) = times.times(i);
    idx = idx + 1;
end

savejson([], new_times, fullfile(dest, 'times.json'));

features = load_features(src);

if ~isempty(features)
    new_features = features;
    
    for i = 1:length(new_features)
        if isfield(new_features{i}, 'coordinates')
            new_features{i}.coordinates = ...
                features{i}.coordinates(good_frames, :);
        end
        if isfield(new_features{i}, 'modified_coordinates')
            new_features{i}.modified_coordinates = ...
                features{i}.modified_coordinates(good_frames, :);
        end
    end
    
    save_features(new_features, dest);
    
end

