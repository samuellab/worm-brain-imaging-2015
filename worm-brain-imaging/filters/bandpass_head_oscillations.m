function h = bandpass_head_oscillations(F1, F2, Fs, N)
% Returns a bandpass filter passing F1 to F2 (in Hertz). Fs is the number
% of samples per second and N is the filter order.

if nargin < 4
    N = 20;
end

if nargin < 3
    Fs = 10;
end

if nargin < 2
    F2 = 1;
end

if nargin < 1
    F1 = 0.2;
end

% FIR least-squares Bandpass filter designed using the FIRLS function.

% All frequency values are in Hz.

Fstop1 = F1-0.05;  % First Stopband Frequency
Fpass1 = F1+0.05;  % First Passband Frequency
Fpass2 = F2-0.05;  % Second Passband Frequency
Fstop2 = F2+0.05;  % Second Stopband Frequency
Wstop1 = 1;     % First Stopband Weight
Wpass  = 1;     % Passband Weight
Wstop2 = 1;     % Second Stopband Weight

% Calculate the coefficients using the FIRLS function.
b  = firls(N, [0 Fstop1 Fpass1 Fpass2 Fstop2 Fs/2]/(Fs/2), [0 0 1 1 0 ...
           0], [Wstop1 Wpass Wstop2]);
Hd = dfilt.dffir(b);

h = Hd.Numerator;

% [EOF]
