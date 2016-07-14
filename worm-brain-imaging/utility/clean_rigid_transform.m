function tform = clean_rigid_transform(tform)
% tform = clean_rigid_tform(tform)
%
%   Takes a supposedly rigid transform and reconstructs it to actually be
%   rigid by determining the angle (using atan2) and regenerating the
%   rotation part of the matrix.

if tform.isRigid
    return
end

n = 0;
while n < 100
    
    theta = atan2(tform.T(2), tform.T(1));
    theta = theta + eps*n;
    tform.T(1:2, 1:2) = [cos(theta), -sin(theta); sin(theta), cos(theta)];
   
    n = n + 1;
    
    if tform.isRigid
        return
    end
end

error(['Could not generate a rigid transformation for theta = ' ...
    num2str(theta)]);