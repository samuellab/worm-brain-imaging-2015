classdef MatfileArray
    
    properties (SetAccess = immutable)
        
        % matfile object that corresponds to where the data is located on
        % disk
        Matfile

        % Field in matfile this array will access.
        Field
        
        Size

        ElementClass
        
    end
    
    methods
        
        function obj = MatfileArray(filename, field)
            % x = MATFILEARRAY(filename, field)
            %
            %   Creates read-only reference to the array contained in a
            %   specified field of a .mat file.
            
            obj.Matfile = matfile(filename);
            obj.Field = field;
            obj.Size = size(obj.Matfile, field);
            
            % Determine the type and size of the array.
            mfile_info = whos(obj.Matfile);

            for i = 1:length(mfile_info)
                if strcmp(mfile_info(i).name, field)
                    array_info = mfile_info(i);     
                end
            end

            obj.Size = array_info.size;
            obj.ElementClass = array_info.class;
            
        end
        
        function [varargout] = subsref(this, S)

            varargout{1} = this.Matfile.(this.Field)(S.subs{:});

        end
        
        function s = size(this)
            s = this.Size;
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