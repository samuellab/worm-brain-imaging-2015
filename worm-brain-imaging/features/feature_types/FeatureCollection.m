classdef FeatureCollection < handle
    %FEATURECOLLECTION Map of features, using feature IDs as a primary key.

    properties

        % Primary Map (ID -> Feature)
        FeatureMap
        
        % User-defined indexes (Index ID -> cell array of Feature IDs)
        Indexes

    end

    methods

        function obj = FeatureCollection(f)
            % obj = FEATURECOLLECTION(features)
            %
            %   Creates a collection from a cell array of features or


            obj.FeatureMap = containers.Map('KeyType', 'char', ...
                'ValueType', 'any');
            
            obj.Indexes = containers.Map('KeyType', 'char', ...
                'ValueType', 'any');
                
            if nargin > 0
                
                obj.insert(f);
                
            end

        end

        function k = keys(this)
            % k = obj.keys()
            %
            %   Returns a cell array containing all the keys in FeatureMap.
            k = keys(this.FeatureMap);
        end

        function feature = get(this, key)
            % feature = obj.GET(key)
            %
            %   Returns a feature with the given key.

            feature = this.FeatureMap(key);

        end

        function feature = find_random(this)
            % feature = obj.FIND_RANDOM()
            %
            %   Returns a random feature from this collection.

            all_keys = this.FeatureMap.keys;
            idx = randi(length(all_keys));

            feature = this.get(all_keys{idx});

        end

        function [collection, keys] = filter(this, fn)
            % collection = obj.FILTER(fn)
            %
            %   Return a FeatureCollection consisting of features where
            %   fn(feature) evaluates to true.
            %
            % [collection, keys] = obj.FILTER(fn)
            %
            %   keys contains a cell array of the valid keys.
            %
            % collection = obj.FILTER(keys)
            %
            %   Return a container containing features with the keys
            %   specified in a cell array.

            if isa(fn, 'cell')
                keys = fn;
            elseif isa(fn, 'char')
                keys = {fn};
            elseif isa(fn, 'function_handle')
                all_keys = this.FeatureMap.keys;
                all_values = this.cell_array(all_keys);
                valid = cellfun(fn, all_values);
                keys = all_keys(valid);
            end

            feature_array = values(this.FeatureMap, keys);

            collection = FeatureCollection(feature_array);

        end

        function f = cell_array(this, keys)
            % f = obj.CELL_ARRAY()
            %
            %   Converts this collection to a cell array of features.
            %
            % f = obj.CELL_ARRAY(keys)
            %
            %   Returns a cell array of features with the given keys.

            if nargin < 2
                f = values(this.FeatureMap);
            else
                f = values(this.FeatureMap, keys);
            end

        end

        function insert(this, f, condition)
            % obj.INSERT(feature)
            %
            %   Insert a given feature into this collection.
            %
            % obj.INSERT(features)
            %
            %   Insert a collection or cell array of features into this
            %   collection.
            %
            % obj.INSERT(f, condition)
            %
            %   Only insert elements of f that satisfy the given condition.

            if nargin < 3
                condition = @(x) true;
            end
            
            if isa(f, 'Feature')
                
                if condition(f)
                    this.FeatureMap(f.ID) = f;
                end
                    
            elseif isa(f, 'FeatureCollection')
                
                f = f.filter(condition);
                this.FeatureMap = [this.FeatureMap; f.FeatureMap];
                
            elseif isa(f, 'cell')
                
                for i = 1:length(f)
                    this.insert(f{i}, condition); 
                end
                
            end

        end

        function y = numel(this)
            % obj.NUMEL()
            %
            %   Returns the number of features stored in this collection.
            y = this.FeatureMap.Count;
        end
        
        function add_index(this, index_key, k)
            % obj.ADDINDEX(index_name, cell_array_of_feature_IDs)
            %
            %   Create an index with a specified name.
            %
            % obj.ADDINDEX(index_name, function_handle)
            %
            %   Create an index using the specified boolean function to
            %   identify valid keys.
            
            if isa(k, 'function_handle')
                [~, k] = this.filter(k);
            end
            
            this.Indexes(index_key) = k;
            
        end
        
        function collection = get_index(this, index_key)
            % collection = obj.GETINDEX(index_name)
            %
            %   Return a collection of features specified by a given index.
            
            collection = this.filter(this.Indexes(index_key));
            
        end

    end

    methods (Static)

       

    end

end

