function angles = get_angle_between_features(feature1, feature2)
% function angles = get_angle_between_features(feature1, feature2)
% calculate the angle of the ray connecting feature1 to feature2.
% feature1 and feature2 should both have field 'coordinates' referencing
% the same coordinate system.  this assumes the feature coordinates are
% pixel-referenced (row, column)=(-y,x) values and returns an angle 
% referenced to the positive x-axis with the usual convention

x1 = feature1.coordinates(:,2) + feature1.size(2)/2;
y1 = -(feature1.coordinates(:,1) + feature1.size(1)/2);

x2 = feature2.coordinates(:,2) + feature2.size(2)/2;
y2 = -(feature2.coordinates(:,1) + feature2.size(1)/2);

angles = arrayfun(@atan2,y2-y1,x2-x1);
for i = 1:length(angles)
    if angles(i)<0
        angles(i) = angles(i)+2*pi;
    end
end