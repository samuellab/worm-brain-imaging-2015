function center = get_modified_center(feature, t, varargin)
% center = get_feature_center(feature, t)
%
%   Returns the center of a feature are the specified time.

center = feature.modified_coordinates(t,:) + 0.5 * feature.size;