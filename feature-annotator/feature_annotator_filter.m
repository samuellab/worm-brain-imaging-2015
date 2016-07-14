function im = feature_annotator_filter(im)
% apply all the filters specified in feature_annotator to a 2- or 3-
% dimensional image

    global feature_annotator_data;
    
    % z filter
    if get(feature_annotator_data.gui.z_filter_checkbox,'Value') && ...
       ndims(im) == 3
   
        z_filter_string = get(feature_annotator_data.gui. ...
                              z_filter, 'String');
        h = evalin('base',z_filter_string);
        
        if z_filter_string(1)=='@' % function handle?
            warndlg('functions for z-filtering not implemented');
        else
            if all(h>=0)
                h = h./sum_all(h);
            end
            
            h2(1,1,:) = h;
            
            im = imfilter(im, h2);
        end
        
    end
    
    % xy filter
    if get(feature_annotator_data.gui.xy_filter_checkbox,'Value')
        xy_filter_string = get(feature_annotator_data.gui. ...
                               xy_filter, 'String');
        h =  evalin('base', xy_filter_string);
        
        if xy_filter_string(1)=='@' % function handle?
            im = h(im);
        else
            % normalize if there are no negative values of h
            if all(h>=0)
                h = h./sum_all(h);
            end
            im = imfilter(im,h);
        end
    end
    
    % threshold
    if get(feature_annotator_data.gui.threshold_checkbox,'Value')
        threshold = str2num(get(feature_annotator_data.gui. ...
                               threshold, 'String'));
        im(im<threshold) = 0;
    end
    
       
    % binary threshold
    if get(feature_annotator_data.gui.binary_threshold_checkbox,'Value')
        threshold = str2num(get(feature_annotator_data.gui. ...
                               binary_threshold, 'String'));
        im = cast(im > threshold, 'like', im);
    end 
end