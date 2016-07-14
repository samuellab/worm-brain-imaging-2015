%% This handles analysis and visualization of whole-brain imaging data

classdef DataAnalyzer

    properties

        % Table of data, set on construction
        RawData

        % This specifies an order for the neurons. It is generally set
        % when the cluster method is called.
        NeuronOrder = [];

        % This specifies a linkage from clustering. It is generally set
        % when the cluster method is called.
        LinkageData = [];

        % Neuron whitelist and blacklist
        NeuronWhitelist = categorical([]);
        NeuronBlacklist = categorical([]); %categorical([75 81 84:90 92:95 97:99]);

        % Time index whitelist and blacklist
        TimeWhitelist = []; %1200:3460;
        TimeBlacklist = [];

        % Filter applied prior to subtracting red from green. Numerator
        % only. 1 -> no filtering.
        LoadLowpassFilter = 1;

        % Filter used for input normalization (DF/F)... this is actually a
        % *lowpass* filter whose output gets subtracted. If the output of 
        % this filter is F0 and the input is F, the loaded data will be
        % (F-F0)/F0.
        LoadHighpassFilter = @(x) smooth(x,10);

        % Filter applied to final signal (after subtraction). Numerator
        % only. 1 -> no filtering
        OutputFilter =  ones(20,1)/20;

        % Method for calculating pairwise distances between signals. see
        % PDIST
        DistanceMetric = 'correlation';

        % Method for calculating linkage for clustering. see LINKAGE
        LinkageMethod = 'complete';

        % Method for grouping leaves in dendrogram. see OPTIMALLEAFORDER.
        LeafGroupMethod = 'adjacent'; % 'adjacent' or 'group'

        % Show v_x in the background of single-neuron plots
        ShowVelocity = false;

        % Show the temperature in the background of single-neuron plots
        ShowTemperature = false;

        % Show omega in the background of single-neuron plots
        ShowOmega = false;

        % Calculate signal from red and green channels using a custom
        % method. If this is empty, signals will be calculated via linear
        % regression.
        SignalMethod = [];

    end

    properties %(SetAccess=protected)

        % A list of neuron IDs according to the current ordering. Set this
        % by calling the cluster method.
        NeuronNames

    end

    properties (Dependent)

        % Times (in seconds)
        Times

        % The time trace of temperature
        Temperature

        % The time trace of velocity (v_x)
        Velocity

        % The time trace of head angular velocity (omega)
        Omega

    end

    methods

        function this = DataAnalyzer(tabulated_data)
            this.RawData = tabulated_data;
            this = this.update_neuron_names();
        end

        function sig = signal(this, neuron)
            % sig = SIGNAL(obj, neuron)
            %
            %   Returns a time series corresponding to the calcium signal
            %   from the specified neuron.

            if isnumeric(neuron)
                neuron = categorical(neuron);
            end

            row_rfp = this.RawData.Neuron == neuron & ...
                this.RawData.Channel == 'rfp';
            row_gcamp = this.RawData.Neuron == neuron & ...
                this.RawData.Channel == 'gcamp';

            rfp_raw = this.RawData{row_rfp, 'TimeSeries'};
            gcamp_raw = this.RawData{row_gcamp, 'TimeSeries'};

            rfp_cropped = this.crop_timeseries(rfp_raw);
            gcamp_cropped = this.crop_timeseries(gcamp_raw);

            % Pull out the data now... it should be evenly sampled for both
            % channels.
            r = rfp_cropped.Data;
            g = gcamp_cropped.Data;

            % Get rid of the NaNs for filtering
            r = interpolate_nans(r, 'linear');
            g = interpolate_nans(g, 'linear');

            % Highpass filter and normalize the inputs
            r0 = this.LoadHighpassFilter(r);
            g0 = this.LoadHighpassFilter(g);

            r = (r-r0)./r0;
            g = (g-g0)./g0;

            % Now lowpass them
            r = filter(this.LoadLowpassFilter, 1, r);
            g = filter(this.LoadLowpassFilter, 1, g);

            % Generate a signal from red and green time series.
            sig = this.signal_from_channels(g, r);

            sig = filter(this.OutputFilter, 1, sig);

        end

        function [sigs, names] = all_signals(this)
            % [sigs, names] = obj.all_signals()
            %
            %   Returns all the signals for valid neurons in a
            %   length(neurons) x length(times) array. 'names' is an array

            names = this.NeuronNames;

            for i = 1:length(names)

                sigs(i,:) = this.signal(names(i));

            end

        end

        function D = pdist(this)
            % D = PDIST(obj)
            %
            %   Calculates the pairwise distances between signals,
            %   outputing a vector (see PDIST). The order is specified by
            %   obj.NeuronOrder.

            [sigs, ~] = this.all_signals();
            metric = this.DistanceMetric;

            D = pdist(sigs, metric);

        end

        function this = cluster(this)
            % obj = CLUSTER(obj, metric)
            %
            %   Clusters the signals from all neurons and returns the
            %   linkages. This sets the following fields:
            %
            %       NeuronNames
            %       LinkageData
            %
            % See also LINKAGE.

            % First calculate the pairwise distances
            D = this.pdist();

            links = linkage(D, this.LinkageMethod);
            neuron_order = optimalleaforder(links, D, ...
                'CRITERIA', this.LeafGroupMethod);

            % Cretae a new order for the names.
            this.NeuronNames = this.NeuronNames(neuron_order);
            this.LinkageData = struct(...
                'linkage', links, ...
                'order', neuron_order);

        end

        function this = show_clusters(this, figure_number, clims)
            % obj = SHOW_CLUSTERS(obj, figure_number)
            %
            %   Visualize the clusters.

            if nargin < 2
                figure_number = randi(1000);
            end

            if isempty(this.LinkageData)
                this = this.cluster();
            end

            links = this.LinkageData.linkage;
            order = this.LinkageData.order;
            names = this.NeuronNames;

            D = this.pdist();
            sigs = this.all_signals();

            figure(figure_number); 

            subplot('Position', [0, 0, .15, 1]);
            dendrogram(links, 0, ...
                'Orientation', 'left', ...
                'Labels', char(names));
            %set(gca, 'visible', 'off');

            subplot('Position', [0.16, 0, 0.41, 1]);
            imagesc(sigs);
            colormap jet;
            shading flat;
            set(gca, 'visible', 'off');

            if nargin < 3
                clims(1) = quantile(row(sigs), 0.);
                clims(2) = quantile(row(sigs), 0.99);
            end

            caxis(clims);

            subplot('Position', [0.58, 0, 0.41, 1]);
            D_square = squareform(D);
            pcolor(1-D_square);
            %colormap jet;
            shading flat;
            set(gca, 'visible', 'off');

        end

        function this = show_heatmap(this, figure_number, clims)
            % obj = SHOW_HEATMAP(obj, figure_number)
            %
            %   Visualize the clusters.

            if nargin < 2
                figure_number = randi(1000);
            end

            if isempty(this.LinkageData)
                this = this.cluster();
            end

            links = this.LinkageData.linkage;
            order = this.LinkageData.order;
            names = this.NeuronNames;

            D = this.pdist();
            sigs = this.all_signals();

            figure(figure_number); 

            subplot('Position', [0 0 1 1]);
            imagesc(sigs);
            colormap jet;
            shading flat;
            set(gca, 'visible', 'off');

            if nargin < 3
                clims(1) = quantile(row(sigs), 0.);
                clims(2) = quantile(row(sigs), 0.99);
            end

            caxis(clims);        

        end

        function [coeff, score, latent] = show_components(this, comps, ...
                figure_number)
            % obj = SHOW_COMPONENTS(obj, components)
            %
            %   Shows the principal components.

            [coeff, score, latent] = pca(this.all_signals(), ...
                'centered', false);

            if nargin < 3
                figure_number = 2;
            end

            figure(figure_number);

            N = length(comps);
            min_y = min_all(coeff(:,comps));
            max_y = max_all(coeff(:,comps));

            for i = 1:N
                subplot(N, 1, i);
                plot(coeff(:,comps(i)));
                ylim([min_y, max_y]);
                title(sprintf('Variance explained: %d ', latent(i)));
            end

        end

        function t = get.Times(this)

            ts1 = this.RawData{1, 'TimeSeries'};
            t = ts1.Time;

        end

        function v = get.Velocity(this)

            ts = this.RawData{'velocity_x','TimeSeries'};
            ts = this.crop_timeseries(ts);

            v = this.filter_timeseries(ts);

        end

        function omega = get.Omega(this)

            ts = this.RawData{'omega_y','TimeSeries'};
            ts = this.crop_timeseries(ts);

            omega = this.filter_timeseries(ts);

        end

        function temperature = get.Temperature(this)

            ts = this.RawData{'T','TimeSeries'};
            ts = this.crop_timeseries(ts);

            temperature = ts.Data;

        end

        function ts = crop_timeseries(this, ts)
            % ts = CROP_TIMESERIES(obj, ts)
            %
            %   Takes a timeseries and removes times according the the time
            %   index whitelists and blacklists.

            all_times = 1:ts.Length;

            time_indices = merge_black_white(all_times, ...
                this.TimeBlacklist, this.TimeWhitelist);

            bad_times = setdiff(all_times, time_indices);

            ts = delsample(ts, 'Index', bad_times);

        end

        function y = filter_timeseries(this, ts)
            % y = FILTER_TIMESERIES(obj, ts)
            %
            %   Takes a timeseries and applies the object's output filter
            %   to generate a vector that can be used for ploting.

            x = interp_nans(ts.Data, 'linear');
            y = filter(this.OutputFilter, 1, x);

        end

        function this = update_neuron_names(this)
            all_neurons = categories(this.RawData{:,'Neuron'});
            names = merge_black_white(all_neurons, ...
                this.NeuronBlacklist, ...
                this.NeuronWhitelist);

            this.NeuronNames = names;
        end


        function signal = signal_from_channels(this, green, red)
            % signal = DataAnalyzer.SIGNAL_FROM_CHANNELS(obj, green, red)
            %
            %   Returns a vector of data obtained by subtracting the red
            %   signal from the green via linear regression. If
            %   obj.DivideGreenByRed is true, this simply divides the green
            %   signal by the red signal.

            if isempty(this.SignalMethod)

                a = polyfit(red, green, 1);
                signal = green - (a(1)*red + a(2));

            else

                signal = this.SignalMethod(green, red);

            end

        end


    end

    methods (Static)

        function obj = from_data_file(animal)
            % obj = DataAnalyzer.FROM_DATA_FILE(animal)
            %
            %   Returns an analysis object by loading the most recent data
            %   for a given animal.

            data_as_struct = get_recent_data(animal);
            tabulated_data = table_from_data(data_as_struct);
            obj = DataAnalyzer(tabulated_data);

        end

    end

    methods (Static, Access=protected)


    end

end