function ref = get_output_view(x_bounds, y_bounds)
% ref = GET_OUTPUT_VIEW(x_bounds, y_bounds)
%
%   Returns a spatial referencing object given x- and y- boundaries in the 
%   world coordinate system.
%
%   See also imref2d

y_range = round(range(y_bounds));
x_range = round(range(x_bounds));

ref = imref2d([y_range, x_range], x_bounds, y_bounds);