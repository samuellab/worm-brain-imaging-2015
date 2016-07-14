function tform = check_tform(tform, moving, fixed, R)
% check_tform(tform, moving, fixed, R)
%
%   Visualize and tweak the fit between a moving and fixed image. Currently
%   assumes the transform is rigid.

if nargin < 4
    S = size(fixed);
    R = imref2d(S, [0.5, 0.5+S(1)], [0.5, 0.5+S(2)]);
end

theta = atan2(tform.T(2), tform.T(1));
center = size(moving)/2;

ref_tform = rotation_tform(theta, center);
displacement = tform.T(3,1:2) - ref_tform.T(3,1:2);


new_im = imwarp(moving, tform, 'OutputView', R);
fit = ssim(new_im, fixed);

h = figure(101); clf;

set(h, 'KeyPressFcn', @keypress_function);

function keypress_function(~, evt)

    switch evt.Key
        case 'leftarrow'
            displacement(1) = displacement(1) - 2;
        case 'rightarrow'
            displacement(1) = displacement(1) + 2;
        case 'downarrow'
            displacement(2) = displacement(2) + 2;
        case 'uparrow'
            displacement(2) = displacement(2) - 2;
        case 'f'
            theta = theta + pi/12;
        case 'd'
            theta = theta - pi/12;
        case 'x'
            done = true;
    end

    tform = rotation_tform(theta, center, displacement);
    new_im = imwarp(moving, tform, 'OutputView', R);
    figure(h);
    imshowpair(new_im, fixed);
    title(['Fit: ' num2str(fit)]);

end

done = false;
keypress_function(h, struct('Key', 'leftarrow'));
while ~done
    drawnow;
end

end