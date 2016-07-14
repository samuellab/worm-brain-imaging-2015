function set_bad_frames(filename, bad_frames)

if isempty(filename)
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
    savejson([], bad_frames, fullfile(filename, 'bad_frames.json'));
else
    mfile.Properties.Writable = true;
    mfile.bad_frames = bad_frames;
    mfile.Properties.Writable = false;
end