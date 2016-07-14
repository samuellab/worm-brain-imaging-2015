function s = crawl(s, f)
% s = CRAWL(s, f)
%
%   Applies a function 'f' to a structure, then recursively applies it to
%   each field of the resulting structure that is itself a structure or a
%   cell array of structures.

s = f(s);
fields = fieldnames(s);

for i = 1:length(fields)
    
    field = fields{i};
    
    if isstruct(s.(field))
        
        s.(field) = structtools.crawl(s.(field), f);
        
    elseif iscell(s.(field))
        
        for j = 1:length(s.(field))
            
            if isstruct(s.(field){j})
                
                s.(field){j} = structtools.crawl(s.(field){j}, f);
                
            end
            
        end
        
    end
    
end