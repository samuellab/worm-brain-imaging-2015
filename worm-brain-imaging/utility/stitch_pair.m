function varargout = stitch_pair(a, b, varargin)
% c = stitch_pair(a, b)
    

default_options = struct(...
                    'a_ref', ones(size(a)), ...
                    'b_ref', ones(size(b)),...
                    'a_clipping', [0, 0, 0], ...
                    'b_clipping', [0, 0, 0]...
                    );
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

N = ndims(a);
assert(N==ndims(b));

ac = options.a_clipping;
bc = options.b_clipping;

a = a( (1+ac(1)) : (end-ac(1)) , ...
       (1+ac(2)) : (end-ac(2)) , ...
       (1+ac(3)) : (end-ac(3)) );
   
b = b( (1+bc(1)) : (end-bc(1)) , ...
       (1+bc(2)) : (end-bc(2)) , ...
       (1+bc(3)) : (end-bc(3)) );

a_ref = options.a_ref - ac;
b_ref = options.b_ref - bc;

% how much should we shift a and b in the output array?
a_offset = max(0, b_ref-a_ref);
b_offset = max(0, a_ref-b_ref);

sa = size(a);
sb = size(b);

new_size = max( sa+a_offset, sb+b_offset );

a_big = nan(new_size);
b_big = nan(new_size);
c = zeros(new_size, class(a));

% to stitch by averaging:

% % put a in the correct location for the output
% idx = cell(1,N);
% for i = 1:N
%     idx{i} = (1+a_offset(i)) : a_offset(i)+sa(i);
% end
% a_big(idx{:}) = a;
% 
% % put b in the correct location for the output
% idx = cell(1,N);
% for i = 1:N
%     idx{i} = (1+b_offset(i)) : b_offset(i)+sb(i);
% end
% b_big(idx{:}) = b;
% 
% % combine them by averaging overlapping pixels
% c = arrayfun(@(x,y) nanmean([x y]), a_big, b_big);
    
% stitching where b has precedence over a:

% put a in the correct location for the output
idx = cell(1,N);
for i = 1:N
    idx{i} = (1+a_offset(i)) : a_offset(i)+sa(i);
end
c(idx{:}) = a;
% put b in the correct location for the output
idx = cell(1,N);
for i = 1:N
    idx{i} = (1+b_offset(i)) : b_offset(i)+sb(i);
end
c(idx{:}) = b;

varargout{1} = c;

if nargout == 3
    varargout{2} = a_offset - ac ;
    varargout{3} = b_offset - bc ;
end


