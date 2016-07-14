% A valid camera should be assigned to 'cam' before running this script.

clear data;
tic;

for i = 1:40
    
    data = cam.snap(25);
    %save_tiff_stack(data, sprintf('C:/Data/vol_%03d.tif', i));
    
end

toc