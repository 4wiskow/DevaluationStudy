classdef Data
    methods (Static)
        function data = getData()
            if ~isfile('data.mat')
                EEGtoMatlab;
            end
            data = load('data');
        end
        
        function averagedTrials = averageTrialsWithoutOverlap(data, windowSize)
            averagedTrials = [];
            for i=1:windowSize:size(data, 1)
                averagedTrials = cat(1, averagedTrials, mean(data(i:i+windowSize-1, :, :), 1));
            end
        end
    end
end