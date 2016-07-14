function [coeff, score, latent] = principal_components_of_volume(vol, pct)
% Wraps the MATLAB pca function to calculate principal components of a
% registered 2D or 3D image. Before using this, you should ensure that vol
% is decimated to an appropriate sampling frequency (~2-4 pixels per neuron
% per dimension).

% If vol is a file or directory, load it into an array
if isstr(vol) && (exist(vol, 'dir') || exist(vol, 'file'))
    vol = load_tiff_stack(vol);
end

% The last dimension of vol is time.  Those will be our observations.  The
% pixels are the vector that we are analyzing, so we have to place each
% pixel in its own column and let time be the first (row) dimension.

S = size(vol); % S(end) is the duration
D = length(S) - 1; % 2 for 2D and 3 for 3D
N_pixels = prod(S(1:end-1));

% This is the array of observations for pca
X = zeros(S(end), N_pixels);

for i = 1:N_pixels
    
    % Convert the pixel time series to a column
    idx = cell(1, D+1);
    [idx{1:end-1}] = ind2sub(S(1:end-1), i);
    idx{end} = ':';
    trace = vol(idx{:});
    
    X(:, i) = normalize_array(trace);
    
end

[coeff, score, latent] = pca(X);