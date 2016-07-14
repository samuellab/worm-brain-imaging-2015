function output = centroid(array)
% array can be 2 or 3 dimensional.  length of output is ndims(array)

N = numel(array);
S = sum(reshape(array,1,numel(array)));
array = double(array)/S;

switch ndims(array)
    case 2
        [X, Y] = meshgrid(1:size(array,2),1:size(array,1));
        X_c = sum(reshape(X.*array,1,N));
        Y_c = sum(reshape(Y.*array,1,N));
        output = [Y_c X_c];
    case 3
        [X, Y, Z] = meshgrid(1:size(array,2),...
                           1:size(array,1),...
                           1:size(array,3));
        X_c = sum(reshape(X.*array,1,N));
        Y_c = sum(reshape(Y.*array,1,N));
        Z_c = sum(reshape(Z.*array,1,N));
        output = [Y_c X_c Z_c];
end

end