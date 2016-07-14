function varargout = local_mean(array, window)
% local_means = local_mean(array,window)
%   returns the mean of array in a region of size window centered around 
%   each element.
%
% [local_means, local_stds] = local_mean(array,window)
%   returns the mean and approximate standard deviation of array in a 
%   region of size window centered around each element.  The standard
%   deviation is calculated using different means for each element for
%   speedup.
means_unnormalized = convn(array,ones(window,class(array)),'same');



% figure out the truesize for each dimension
A = size(array);
W = window;


%%%%
% this is slow way to compute normalization for each element individually to
% handle edge cases from using convn.  unfortunately, it seems to be very
% slow.  maybe it can be improved by expanding the original array and
% cropping post-processing?  

% takes an index (r) into a dimension (a) with a corresponding window
% dimension (w) and returns the number of elements that would actually be
% used by convn using the 'same' option
truesize = @(r,w,a) 1+floor(min((w-1)/2,r-1)+min((w-1)/2,a-r));

switch ndims(array)
    case 2
        f = @(x,y) truesize(x,W(1),A(1)) * ...
             truesize(y,W(2),A(2));
        [X,Y] = ndgrid(1:A(1),1:A(2));
        normalization = arrayfun(f,X,Y);
    case 3
        f = @(x,y,z) truesize(x,W(1),A(1)) * ...
             truesize(y,W(2),A(2)) * ...
             truesize(z,W(3),A(3));
        [X,Y,Z] = ndgrid(1:A(1),1:A(2),1:A(3));
        normalization = arrayfun(f,X,Y,Z);
end
%%%%

%normalization = prod(window);

local_means = cast(means_unnormalized ./ normalization, class(array));
varargout{1} = local_means;


if nargout==2 % also calculate variances
    array_2 = array-local_means;
    variances_unnormalized = convn(array_2.^2,ones(window,class(array)),'same');
    local_stds = cast(sqrt(variances_unnormalized ./ normalization),...
                      class(array));
    varargout{2} = local_stds;
end


