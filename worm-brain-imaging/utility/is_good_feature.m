function good = is_good_feature(feature, times)
% good = is_feature_good(feature, times)
%
%   Returns true if a feature is not a bad frame and is registered at all
%   of the specified times.

good = ~any(feature.is_bad_frame(times)) && ...
       all(feature.is_registered(times));
    
    
    