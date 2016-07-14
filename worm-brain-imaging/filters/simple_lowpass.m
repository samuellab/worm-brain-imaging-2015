function h = simple_lowpass(Fc, Fs, N)
% h = simple_lowpass(Fc, Fs, N)
%
%   Accepts a sample rate and window length (in samples) and returns an 
%   exponential lowpass filter.

if nargin < 3
    N = round(Fs/Fc*2);
end


h0 = exp(-[1:N]*Fc/Fs);
h = h0/sum(h0);