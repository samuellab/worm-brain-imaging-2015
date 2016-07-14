function feature = register_feature(feature, image_location, varargin)
% feature = register_feature(feature, image_location)
%
%   Performs registration for the given feature using data in
%   image_location.

default_options = struct(...
                    );
                
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

if ~isempty(options.reference_features)
    
    [reg_order, tree, reg_parents] = make_order_for_frames(feature, ...
        options.reference_features, ...
        'depth_penalty', 1.1);
    
    feature.registration_tree = tree;
    
else

    reg_order = 1:get_size_T(feature);
    reg_parents = reg_order - 2;
    reg_parents(1:2) = 1;

end


for i = 1:length(reg_order)

    feature.errors = struct('t',{}, 'error', {});

    try
        
        t = reg_order(i);
        feature = register_feature_frame(feature, image_location, ...
            t, 't_ref', reg_parents(t), input_options);

    catch err

        feature.errors{end+1}.t = reg_order(i);
        feature.errors{end}.error = err;

    end
end