function s = convert_cells_to_arrays(s)
% s = CONVERT_CELLS_TO_ARRAYS(s)
%
%   This method will attempt to convert every field of s that is a cell
%   array of numbers into a numeric array.

fields = fieldnames(s);

for i = 1:length(fields)

    f = fields{i};

    if iscell(s.(f)) && all(cellfun(@isnumeric, s.(f)))

        s.(f) = cell2mat(s.(f));

    end

end