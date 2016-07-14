function array = trim_nans(array, varargin)
% array = trim_nans(array)
%
%   Removes NaN values from the end of an array (in both the row- and
%   column- dimensions). The last row will only only be eliminated from the
%   end of an array if all(isnan(array(end,:)).


if all(isnan(array(end,:))) && options.trim_rows
    array = trim_nans(array(1:end-1, :));
elseif all(isnan(array(:,end))) && options.trim_columns
    array = trim_nans(array(:, 1:end-1));
end