function testplot(h, data, filter)

set(h, 'CData', filter(data));
drawnow;

end