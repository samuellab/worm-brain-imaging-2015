function initialize_matfile(filename)
% Creates an empty MAT file with the given filename for storing data using
% the HDF5 (-v7.3) file type.

 % Create a file for saving using a dummy variable
DUMMY = 0;
save(filename, '-v7.3', 'DUMMY');

% Remove the dummy variable using MATLAB's low-level HDF5 
% interface.
fid = H5F.open(filename, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
H5L.delete(fid, 'DUMMY', 'H5P_DEFAULT');
H5F.close(fid);