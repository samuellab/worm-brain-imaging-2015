function fit = get_image_overlap(A, B)
% fit = GET_IMAGE_OVERLAP(A, B)
%
%   Evaluates the match between images A and B by calculating a correlation
%   coefficient.

r = corrcoef(row(double(A)), row(double(B)));
fit = r(1,2);