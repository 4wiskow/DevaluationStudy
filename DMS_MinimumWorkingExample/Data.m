classdef Data
    % Data Utility class for loading the preliminary DMS data
    properties (Constant)
        % Path to MATLAB files containing the data for each class
        stdPath = "Trials_Preprocessed\"
        
        % names of the MATLAB files
        Object = "obj"
        Scene = "sce"
        Face = "fac"
        AlienRed = "alienRed"
        AlienBlue = "alienBlue"
        Aliens = "aliens"
        
        % suffixes for different kinds of data
        PCA = "_transformed"
        Raw = "_raw"
        RawFiltered = "_raw_filtered"
        
        % The MATLAB files contain reference electrodes which have to be
        % removed
        channelsToDelete = [1 2 146 145 144 143 142 141 140 139 138 137 136 135 134 133 132 131]
    end
    
    methods (Static)
        function data = getTrials(path, class, processingLevel)
            % GETTRIALS Get the trials of a class of stimuli
            %
            % Parameters:
            % path                   - path to the .mat files. If empty,
            %                          a standard path will be used
            % class                  - the class of stimuli to load the trials
            %                          for
            % processingLevel        - the processingLevel to load. One of
            %                          {Data.PCA, Data.Raw, Data.RawFiltered}
            %
            % Returns:
            % data                   - the trials associated with the class of
            %                          stimuli
            if isempty(path)
                path = Data.stdPath;
            end
            filepath = strcat(path, class);
            if ~isempty(processingLevel)
                filepath = strcat(filepath, processingLevel, '.mat');
            end
            data = load(filepath);
            fields = fieldnames(data);
            data = data.(fields{1});
            if isempty(processingLevel)
                data(:, Data.channelsToDelete, :) = []; % remove reference channels
            end
        end

        function copyAllToWorkspace(path)
            % COPYALLTOWORKSPACE Copy the trials of all stimuli classes to workspace
            %
            % Paramaters:
            % path                   - path to the .mat files. If empty,
            %                          a standard path will be used
            classes = [Data.Object, Data.Scene, Data.AlienBlue, Data.AlienRed];

            if isempty(path)
                path = Data.stdPath;
            end

            for n = 1:size(classes, 2)
                data = Data.getTrials(path, classes(n));
                assignin('base', classes(n), data); % assign to workspace
            end
        end
        
        function transformed = toPrincipalComponents(data)
            % TOPRINCIPALCOMPONENTS transform data to representation of
            % lower dimensionality (i.e. the principal components
            % explaining >90% variance). PCA is calculated for each time
            % point to increase generalizability (Grootswagers et al. 2016).
            
            nComponents = 70; % determined manually, explain >90% variance
            transformed = zeros(size(data, 1), nComponents, size(data, 3));
            for t=1:size(data, 3)
                [coeff, score, latent] = pca(data(:, :, t), 'NumComponents', nComponents);
                transformed(:, :, t) = score;
            end
        end
    end
end


