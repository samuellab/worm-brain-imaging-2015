function valid = merge_black_white(all, black, white)
% valid = merge_black_white(all, black, white)
%
%   Takes a list of values along with a whitelist and a blacklist. If the
%   whitelist isn't empty:
%
%       valid = white - black
%
%   If the whitelist is smpty:
%
%       valid = all - black

if isempty(white)
    valid = setdiff(all, black);
else
    valid = setdiff(white, black);
end