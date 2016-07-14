function str_out = append_timestamp(str_in)
% str_out = append_timestamp(str_in)
%
%   str_in.ext -> str_in_YYMMDD_HHMMSS.ext

T = datevec(now);
T_str = sprintf('_%02d%02d%02d_%02d%02d%02d', T(1)-2000, T(2), T(3), ...
    T(4), T(5), round(T(6)));

[D, N, E] = fileparts(str_in);

str_out = fullfile(D, [N T_str E]);