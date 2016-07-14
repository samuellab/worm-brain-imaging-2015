function s = distribute_globals(s)
% s = DISTRIBUTE_GLOBALS(s)
%
%   If 'globals' is present in a structure, the structure beneath it will
%   be distributed to each element of any top-level fields that are cell
%   arrays of structures.

if isfield(s, 'globals')

    globals = s.globals;
    s = rmfield(s, 'globals');
    fields = fieldnames(s);

    for i = 1:length(fields)

        f = fields{i};

        if iscell(s.(f)) && isstruct(s.(f){1})

            s.(f) = structtools.distribute_struct(globals, s.(f));

        end

    end

end