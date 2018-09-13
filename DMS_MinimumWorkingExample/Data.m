classdef Data
    % Data Utility class for loading the preliminary DMS data
    properties (Constant)
        % Path to MATLAB files containing the data for each class
        stdPath = "Trials_Preprocessed\"
        
        % names of the MATLAB files
        Object = "obj"
        Scene = "sce"
        AlienRed = "alienRed"
        AlienBlue = "alienBlue"
        
        % The MATLAB files contain reference electrodes which have to be
        % removed
        channelsToDelete = [1 2 146 145 144 143 142 141 140 139 138 137 136 135 134 133 132 131]
    end
    
    methods (Static)
        function data = getTrials(path, class)
            % GETRIALS Get the trials of a class of stimuli
            %
            % Parameters:
            % path                   - path to the .mat files. If empty,
            %                          a standard path will be used
            % class                  - the class of stimuli to load the trials
            %                          for
            %
            % Returns:
            % data                   - the trials associated with the class of
            %                          stimuli
            if isempty(path)
                path = Data.stdPath;
            end
            data = load(strcat(path, class, ".mat"));
            data = data.(strcat("data_", class));
            data(:, Data.channelsToDelete, :) = []; % remove reference channels
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
    end
end


