%% Locations

N2_root = 'V:\Data\N2';

posture_directory = fullfile(N2_root, 'worms');


%% Load the MRC data into WormPosture objects and save them.

load_all_worms(N2_root);

%% Determine the eigenworms for each MRC worm, and average them.

N_worms = length(ls(fullfile(posture_directory, '*.mat')));

N_off_food = 26;

combined_fits = zeros(1,98);
N_complete = 0;
for i = 1:N_off_food
    
    try
        filename = fullfile(posture_directory, sprintf('worm_%04d.mat',i));
        S = load(filename); 
        worm = S.worm;

        % These four can be removed once library is remade
        worm = worm.trim_nans(); 
        worm = worm.head_from_posture();
        worm = worm.xhat_from_posture();
        worm = worm.length_from_posture();

        if i == 1
            C = worm.principal_components();
        end

        head_worm = WormPosture.from_head_trajectory(worm);

        angles = worm.principal_angles(5, C);
        fit_angles = head_worm.principal_angles(5, C);

        fits = [];
        for j = 1:size(angles,1)

            r = corrcoef(angles(j,:), fit_angles(j,:));
            fits(j) = r(1,2)^2;

        end

        combined_fits = combined_fits + fits;
        
        N_complete = N_complete + 1;

        figure(1); clf;
        plot(fits);
        hold on;
        plot(combined_fits/N_complete);
        
    catch
        
        warning('Error in worm %d', i);
        
    end
    
    drawnow;
end

%% Make figure

figure(201); clf;

plot(combined_fits / N_complete, '.');
ylim([0, 1]);
vline(15);


