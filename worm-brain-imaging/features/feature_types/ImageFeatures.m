classdef ImageFeatures < FeatureCollection
    %IMAGEFEATURES Collection of PointFeatures with a common Image.

    properties

        % Common image
        Image

    end

    methods

        function obj = ImageFeatures(a)
            % obj = IMAGEFEATURES(features)
            %
            %   Creates a collection from a cell array of PointFeatures
            %   with a common Image field.
            %
            % obj = IMAGEFEATURES(feature_collection)
            %
            %   Promotes a feature collection to a collection of
            %   PointFeatures with a common Image field.
            %
            % obj = IMAGEFEATURES(image)
            %
            %   Creates a collection of PointFeatures associated with a
            %   given image.

            obj = obj@FeatureCollection();

            if isa(a, 'cell')

                obj.Image = a{1}.Image;
                obj.insert(a);

            elseif isa(a, 'FeatureCollection')

                f = a.find_random();
                obj.Image = f.Image;

                obj.insert(a);

            else

                obj.Image = a;

            end

        end

        function insert(this, f, condition)
            % obj.INSERT(feature)
            %
            %   Insert a given feature into this collection. The image
            %   field of the feature may be overwritten to match the image
            %   field of the collection.
            %
            % obj.INSERT(features)
            %
            %   Insert a collection or cell array of features into this
            %   collection.
            %
            % obj.INSERT(f, condition)
            %
            %   Only insert elements of f that satisfy the given condition.

            if nargin > 2
                condition = @(x) condition(x) && this.validate_feature(x);
            else
                condition = @(x) this.validate_feature(x);
            end

            insert@FeatureCollection(this, f, condition);

        end

        function make_time_indexes(this, times)
            % obj.MAKE_TIME_INDEXES(times)
            %
            %   This creates an index for each time in times.

            if nargin < 2
                times = 1:get_size_T(this.Image);
            end

            for t = times

                index_name = this.time_index_from_time(t);
                this.add_index(index_name, @(x) x.Time == t);

            end

        end

        function collection = get_time(this, t)
            % collection = obj.GET_TIME(t)
            %
            %   Returns a collection of features at a specified time. The
            %   result of this query is cached.
            %
            %   see also MAKE_TIME_INDEXES

            index_name = this.time_index_from_time(t);

            if ~isKey(this.Indexes, index_name)
                this.make_time_indexes(t);
            end

            collection = this.get_index(index_name);

        end

    end

    methods (Access = protected)

        function is_valid = validate_feature(this, f)
            % is_valid = VALIDATE_FEATURE(f)
            %
            %   Determines if f is a valid feature for this collection.

            is_valid = isa(f, 'PointFeature') && f.Image == this.Image;

        end

    end

    methods (Static)

        function time_index_string = time_index_from_time(t)
            % time_index_string = TIME_INDEX_FROM_TIME(t)
            %
            %   Generate a time index from an integer time value.

            time_index_string = ['t' num2str(t)];

        end

         function obj = from_legacy(legacy_features, image)
            % obj = ImageFeatures.FROM_LEGACY(features, image_location)
            %
            %   Create a feature collection from a cell array of legacy
            %   features. Legacy features are always boxes, and typically
            %   don't include an image context.
            %
            % obj = ImageFeatures.FROM_LEGACY(feature, image_location)
            %
            %   Create a feature collection from a single legacy feature.
            %   Each time point will generate a new feature in the
            %   returned collection.

            obj = ImageFeatures(image);

            if ~iscell(legacy_features)
                legacy_features = {legacy_features};
            end

            creator = struct('Method', 'legacy_conversion');

            for i = 1:length(legacy_features)

                f = legacy_features{i};
                size_T = size(f.coordinates, 1);

                for t = 1:size_T

                    sz = f.size + 1;
                    location = f.coordinates(t,:) + f.ref_offset;
                    name = f.name;

                    new_feature = BoxFeature(sz, location, t, image, ...
                        creator, name);

                    obj.insert(new_feature);

                end

            end

        end

    end

end