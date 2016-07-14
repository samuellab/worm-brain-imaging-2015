function output = load_yaml(filename, varargin)
% output = LOAD_YAML(filename)
%
%   Loads a yaml file, wrapping ReadYaml.

import structtools.*;

default_options = struct(...
    'distribute_globals', true, ...
    'append_directories', true, ...
    'convert_cells_to_arrays', true ...
);
input_options = varargin_to_struct(varargin{:});
options = merge_struct(default_options, input_options);

output = ReadYaml(filename);

if options.distribute_globals

    output = crawl(output, @distribute_globals);

end

if options.append_directories

    output = crawl(output, @append_directories);

end

if options.convert_cells_to_arrays

    output = crawl(output, @convert_cells_to_arrays);

end