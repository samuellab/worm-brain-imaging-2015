classdef CachedArray < handle

    properties (SetAccess = immutable)

        % Original array. This has to support standard '()' indexing.
        BaseArray

        Size

        ElementClass

        % Dimension that caching will occur along. This is currently always
        % the last dimension.
        SlicedDimension

        % Number of elements along the cached dimension
        NSlices

    end
    
    properties (SetAccess = protected)

        % All data that has been accessed will be cached here
        LocalData

        % This bitvector keeps track of which slices have been cached. It
        % should match the size of the last dimension of the array
        IsCached
        
    end

    methods

        function obj = CachedArray(x)
            % y = CACHEDARRAY(x)
            %
            %   Read-only array that caches values in memory as they are
            %   read from a base array (typically a disk or function).
            %
            %   Caching occurs along the last dimension, so if you request
            %   y(1,5,8:10), y(:,:,8:10) will be loaded into memory and
            %   y(1,5,8:10) will be returned.

            obj.BaseArray = x;

            obj.ElementClass = element_class(x);

            obj.Size = size(obj.BaseArray);
            obj.SlicedDimension = length(obj.Size);
            obj.NSlices = obj.Size(obj.SlicedDimension);
            obj.LocalData = zeros(obj.Size, obj.ElementClass);
            obj.IsCached = false(obj.NSlices, 1);

        end

        function [varargout] = subsref(obj, S)

                assert(length(S) == 1, ...
                    'Cached arrays support only one level of indexing.');
                assert(strcmp(S(1).type, '()'), ...
                    'Cached arrays only support () indexing.');
                assert(length(S.subs)==length(obj.Size), ...
                    'Cached arrays require full indexing.');

                requested = false(obj.NSlices, 1);
                requested(S.subs{obj.SlicedDimension}) = true;

                needed = requested & ~obj.IsCached;

                % Convert logical indexing into numeric indexing.
                x = 1:length(needed);
                needed = x(needed);

                if any(needed)
                    idx = num2cell(repmat(':', 1, length(obj.Size)));
                    idx{obj.SlicedDimension} = needed;
                    obj.LocalData(idx{:}) = obj.BaseArray(idx{:});
                    obj.IsCached(needed) = true;
                end

                varargout{1} = subsref(obj.LocalData, S);

        end
        
        function s = size(obj, d)
            s = obj.Size;
            if nargin == 2
                s = s(d);
            end
        end
        
        function n = numel(obj)
            n = prod(obj.Size);
        end
        
        function n = ndims(this)
            n = length(this.Size);
        end
        
        function t = element_class(this)
            t = this.ElementClass;
        end

    end

end