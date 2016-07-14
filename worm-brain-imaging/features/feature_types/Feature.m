classdef Feature
    %FEATURE Identifies a feature in an ND image.

    properties (SetAccess = immutable)

        ID

        Image

        Creator

        Name

    end

    methods

        function obj = Feature(A, creator, name)

            obj.ID = generate_uuid(10);
            obj.Image = A;
            obj.Creator = creator;

            if nargin < 3
                name = obj.ID;
            end

            obj.Name = name;

        end

        function obj = clone_feature(this, varargin)
            % obj = Feature.from_feature('Name', 'AFD')
            %
            %   This copies a feature, allowing properites be modified in
            %   the process.

            input_options = varargin2struct(varargin{:}); 

            default_creator = struct(...
                'Method', 'Clone', ...
                'Parent', this, ...
                'Options', input_options);

            default_options = struct(...
                'Name', this.Name, ...
                'Image', this.Image, ...
                'Creator', default_creator ...
            );

            options = mergestruct(default_options, input_options);

            obj = Feature(options.Image, options.Creator, options.Name);

        end

    end

end

