classdef Registrar
    %REGISTRAR This performs feature registration.

    properties

        % This should be a pure function, or a cell array of functions.
        % They should always have the signature (parent, target_context,
        % options) -> (feature, quality, options)
        Methods

        % This is the parent feature used for registration.
        Parent

        % This is the target context for registration which should contain
        % the fields 'Image' and 'Time'.
        TargetContext

        % All arguments and options should be serializable and placed in
        % here.
        Options

    end

    methods

        function obj = Registrar(method, parent, context, opts)

            obj.Methods = method;
            obj.Parent = parent;
            obj.TargetContext = context;
            obj.Options = opts;

        end

        function output = register(this)

            [feature, quality, options] = this.Methods(...
                this.Parent, ...
                this.TargetContext, ...
                this.Options);
            
            R = Registrar(this.Methods, this.Parent, this.TargetContext, ...
                options);

            output = RegisteredFeature(R, feature, quality);

        end

    end

end

