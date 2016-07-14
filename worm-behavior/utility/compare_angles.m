function fits = compare_angles(posture_1, posture_2, segments)
% fits = compare_angles(posture_1, posture_2)
%
%   Calculates the correlation coefficient between angles in two postural
%   histories, smoothing and ignoring NaNs.

if nargin < 3
    
    segments = 3:100;
    
end

angles_1 = posture_1.angles();
angles_2 = posture_2.angles();

for t = 1:size(angles_1, 2)

    smoothed_1(:,t) = smooth(angles_1(:,t), 40);
    smoothed_2(:,t) = smooth(angles_2(:,t), 40);

    bad_1 = union(...
        find(isnan(angles_1(:,t))), ...
        find(abs(smoothed_1(:,t)) > 0.25));
    smoothed_1(bad_1, t) = NaN;

    bad_2 = union(...
        find(isnan(angles_2(:,t))), ...
        find(abs(smoothed_2(:,t)) > 0.25));
    smoothed_2(bad_2, t) = NaN;

end

for i = segments-2

    good_1 = find(~isnan(angles_1(i,:)));
    good_2 = find(~isnan(angles_2(i,:)));

    good = intersect(good_1, good_2);

    a = angles_1(i, good);
    b = angles_2(i, good);

    r = corrcoef(a, b);

    fits(i) = r(1,2);

end