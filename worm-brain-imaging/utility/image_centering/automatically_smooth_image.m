function B = automatically_smooth_image(A, width)
% B = AUTOMATICALLY_SMOOTH_IMAGE(A)
%
%   Determines a high fourier component in input image A and returns a
%   bandpassed version of A centered around that component.
%
% B = AUTOMATICALLY_SMOOTH_IMAGE(A, width)
%
%   Returns a version of A with fourier components centered around 1/width.

if nargin < 2
    S = size(A);
    d = max(S);

    A_fft = abs(fft2(A, d, d));

    % Stick with components in the first zone (the rest are redundant).
    A_fft_1 = A_fft(1:d/2, 1:d/2);

    % Generate a 1D cut through the FFT
    F = zeros(1, d/2);
    for r = 1:d/2

        for x = 1:r

            y = ceil(sqrt(r^2-x^2) + eps);
            F(r) = F(r) + A_fft_1(y, x);

        end

        F(r) = F(r)/r;

    end

    % Determine the 10th percentile wavenumber
    k_max = find(F < quantile(F, 0.8), 1);

    lowpass_filter_width = floor(d/k_max);
else
    lowpass_filter_width = width;
end

highpass_filter_width = 5 * lowpass_filter_width;

h_low = fspecial('gaussian', ...
    3*lowpass_filter_width, ...
    lowpass_filter_width);
h_high = fspecial('gaussian', ...
    3*highpass_filter_width, ...
    highpass_filter_width);

background = imfilter(A, h_high);
foreground = A - background;

B = imfilter(foreground, h_low);