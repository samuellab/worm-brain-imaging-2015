function save_wrap(filename, name, value)
    m = matfile(filename, 'Writable', true);
    m.(name) = value;
end