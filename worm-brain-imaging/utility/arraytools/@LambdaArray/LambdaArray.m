classdef LambdaArray
    
    properties (SetAccess = immutable)
        
        Preimage
        
        PreimageSize
                
        Size
        
        ElementClass
        
        % Access function, or cell array of access functions for each
        % slice. If a cell array is provided, the image for each slice must
        % be the same size.
        Lambda
        
        % Always the last dimension
        SlicedDimension
        
        NSlices
        
    end
    
    methods
        
        function obj = LambdaArray(array, slice_function)
            % y = LAMBDAARRAY(x, slice_function)
            %
            %   Read-only array that applies an access function to x.
            %
            %     x: d-dimensional array of size [Sx, NSlices], which will
            %       be sliced and processed along its last dimension. 
            %
            %     slice_function: takes in an array with d-1 dimensions and
            %       returns an array of fixed size Sy.
            %
            %   Subsequently, y(...) will index into a new array of size
            %   [Sy, NSlices], with processing occuring on the fly.
            %
            %   To cache the result of this computation, consider putting
            %   the output in a CachedArray.
            
            
            obj.Preimage = array;
            obj.PreimageSize = size(obj.Preimage);
            obj.Lambda = slice_function;
            
            preimage_size = size(obj.Preimage);
            obj.NSlices = preimage_size(end);
            
            sample_slice = obj.get_slice(1);
            obj.Size = [size(sample_slice) obj.NSlices];
            obj.SlicedDimension = length(obj.Size);
            obj.ElementClass = element_class(sample_slice);
            
        end
        
        function [varargout] = subsref(this, S)
            
            % Determine which slices we will need to transform
            requested = S.subs{this.SlicedDimension};

            data = zeros([this.Size(1:end-1) length(requested)], ...
                this.ElementClass);

            idx = num2cell(repmat(':', 1, length(this.Size)));
            for i = 1:length(requested)
                
                idx{end} = i;
                data(idx{:}) = this.get_slice(requested(i));
                
            end
            
            new_S = S;
            new_S.subs{this.SlicedDimension} = ':';
            varargout{1} = subsref(data, new_S);
            
        end
        
        function data = get_slice(this, t)
            
            assert(numel(t)==1, ...
                'get_slice can only be called on single slices');
            
            idx = num2cell(repmat(':', 1, length(this.PreimageSize)));
            idx{end} = t;
            
            preimage_slice = subsref(this.Preimage, ...
                struct('type', '()', 'subs', {idx}));
            
            if ~iscell(this.Lambda)
                data = this.Lambda(preimage_slice);
            else
                data = this.Lambda{t}(preimage_slice);
            end
            
        end
        
        function s = size(obj, d)
            s = obj.Size;
            if nargin == 2
                s = s(d);
            end
        end
        
        function n = numel(this)
            n = prod(this.Size);
        end
        
        function n = ndims(this)
            n = length(this.Size);
        end
        
        function t = element_class(this)
            t = this.ElementClass;
        end
        
    end
    
end
        