function bad_frames = get_bad_frames(filename)

if nargin == 0 || isempty(filename)
    global feature_annotator_data;
    filename = feature_annotator_data.image_location;
end

using_TIFs = false;
if isa(filename, 'matlab.io.MatFile')
    mfile = filename;
elseif exist(filename, 'dir')
    using_TIFs = true;
elseif exist(filename, 'file')
    mfile = matfile(filename);
end

if using_TIFs
    bad_frames = loadjson(fullfile(filename, 'bad_frames.json'));
else
    bad_frames = mfile.bad_frames;
end