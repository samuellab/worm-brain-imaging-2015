function plot3D(image3D,varargin)
    
    prompt = '';
    
    max_z = size(image3D,3);
    z = round(max_z/2);
    
    if nargin>1
        fig = varargin{1};
    else
        fig = 3000;
    end
    if nargin>2
        z = varargin{2};
    end
    
    
    sorted_values = sort(reshape(image3D,1,numel(image3D)));
    N = length(sorted_values);
    color_range = [sorted_values(ceil(0.005*N))...
                   sorted_values(floor(0.999*N))];
               
    h = figure(fig); clf;
    imagesc(image3D(:,:,z));
        caxis(color_range);

    set(h,'WindowScrollWheelFcn',@wheel_function);
    set(h,'KeyPressFcn',@select_function);

    
    image_proj_z = squeeze(max(image3D,[],3));
    image_proj_x = squeeze(max(image3D,[],2));
    image_proj_y = squeeze(max(image3D,[],1));
    
    figure(fig+1); 
    subplot(221); imagesc(image_proj_z);
    subplot(222); imagesc(image_proj_x);
    subplot(223); imagesc(image_proj_y');
    
    threshold = [];
    
    function wheel_function(obj,input)
        z = z + input.VerticalScrollCount;
        if z<1
            z=1;
        elseif z>max_z
            z = max_z;
        end
        figure(h);
        imagesc(image3D(:,:,z));
        title(['Z slice = ' num2str(z)]);
    end
    function select_function(obj,evt)
        switch evt.Character
            case 'c'
                color_range = caxis;
            case 't'
                threshold = input('Enter a binary thresholding value:  ');
            case 'q'
                z = z-1;
                if z<1
                    z=1;
                end
                figure(obj);
                imagesc(image3D(:,:,z));
                if ~isempty(color_range)
                    caxis(color_range);
                end
                if ~isempty(threshold) && threshold~=0
                    grey = image3D(:,:,z);
                    bw = grey>threshold;
                    imagesc(im2bw(image3D(:,:,z), threshold));
                end
                title([prompt '; Z slice = ' num2str(z)]);
            case 'w'
                z = z+1;
                if z>max_z
                    z = max_z;
                end
                figure(obj);
                imagesc(image3D(:,:,z));
                if ~isempty(color_range)
                    caxis(color_range);
                end
                if ~isempty(threshold) && threshold~=0
                    grey = image3D(:,:,z);
                    bw = grey>threshold;
                    imagesc(im2bw(image3D(:,:,z), threshold));
                end
                title([prompt '; Z slice = ' num2str(z)]);
                
        end
    end

   
   
end