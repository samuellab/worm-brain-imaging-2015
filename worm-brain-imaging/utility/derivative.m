function dxdt = derivative(x, t, varargin)
% dxdt = derivative(x, t)
%
%   Takes a derivative of x(t), returning a vector with the same length of
%   x. dxdt(1) = NaN always, and dxdt(i) = NaN whenever t(i)-t(i-1) is
%   exceptionally large.

default_options = struct(...
                    'dt_max', Inf, ...
                    'extra_nans', 0 ...
                    );

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

if size(x,2) == 1
    x = x';
end
D = size(x,1);
size_T = size(x,2);

dt = row(diff(t));


dt_max = options.dt_max;


dt(dt > dt_max) = NaN;
dt = repmat(dt, [D 1]);

dx = diff(x,1,2);

dxdt = [NaN(D,1), dx./dt];

dxdt_temp = dxdt;
for i = 1:size_T
    
    if any(isnan(dxdt(:,i)))
        dxdt_temp(:, i:(i+options.extra_nans)) = NaN;
    end

end
dxdt = dxdt_temp;
    
