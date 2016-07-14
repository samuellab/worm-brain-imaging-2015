function y = offset_array_columns(y, offset)

for i = 1:size(y,2)
    y(:,i) = y(:,i) - mean(y(:,i)) + (i-1) * offset;
end