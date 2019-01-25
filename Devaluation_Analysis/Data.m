classdef Data
    properties (Constant)
        % standard directory of results tables
        DMSResultsPath = 'C:\Users\maria\Documents\Praktikum\DevaluationStudy\Test-Daten_17-01-18\Experimentablauf\DMSTask\output\result\';
        RelResultsPath = 'C:\Users\maria\Documents\Praktikum\DevaluationStudy\Test-Daten_17-01-18\Experimentablauf\ReinforcementTask\output\result\';
        
        % class string identifiers in results table
        alienBlue = 'blue';
        alienRed = 'red';
        object = 'object';
        scene = 'scene';
    end
    
    methods (Static)
        function data = getData(varargin)
            if ~isfile('data.mat')
                EEGtoMatlab;
            end
            data = load('data', varargin{1:end});
            
        end
        
        function averagedTrials = averageTrialsWithoutOverlap(data, windowSize)
            averagedTrials = [];
            for i=1:windowSize:size(data, 1)-1
                averagedTrials = cat(1, averagedTrials, mean(data(i:i+windowSize-1, :, :), 1));
            end
        end
        
        function input = generateInput(classA, classB)
            input = cat(1, classA, classB);
            input = mean(input, 3);
            input = mean(input, 2);
            input = zscore(input);
        end
        
        function labels = generateChosenLabels(classA, classALabel, classB, classBLabel)
            labels = cat(1, ...
            repmat(classALabel, size(classA, 1), 1), ...
            repmat(classBLabel, size(classB, 1), 1) ...
            );
        end
        
        function labels = generateLabels(classA, classB)
            labels = Data.generateChosenLabels(classA, 1, classB, 2);
        end
        
        function [shuffledInput, shuffledLabels] = shuffleInputAndLabels(input, labels)
            if size(input, 1) ~= size(labels, 1)
                error("Input and Labels must be of same length");
            end
            shuffleIndices = randperm(size(labels, 1));
            shuffledInput = input(shuffleIndices);
            shuffledLabels = labels(shuffleIndices);
        end
        
        function indicesCorrectlyMatched = getIndicesOfCorrectlyMatched(classStr)
            % GETINDICESOFCORRECTLYMATCHED get the indices of the epochs of
            % a specific class that were matched correctly in the DMSTask
            
            [~, ~, raw] = xlsread([Data.DMSResultsPath filesep 'pia_p1_2019-01-16_11-16-41_result']);
            
            indicesForClass = [];
            responseImageLabels = raw(2:end, 6);
            for i=1:size(raw, 1)-1
                if strcmp(responseImageLabels{i}, classStr)
                    indicesForClass = [indicesForClass; i];
                end
            end
            correctnessIndicators = cell2mat(raw(2:end, 5));
            correctnessIndicators = correctnessIndicators(indicesForClass);
            
            % select epochs which were correctly matched
            indicesCorrectlyMatched = indicesForClass(correctnessIndicators == 1);
        end
        
        function [alien, oHigh] = getAlienAndOutcomeAssignedToSHigh()
            [~, ~, raw] = xlsread([Data.RelResultsPath 'pia_2019-01-16_13-06-27_result']);
            alienNum = raw{2, 7};
            switch alienNum
                case 1
                    alien = 'blue';
                case 2 
                    alien = 'red';
                otherwise
                    error('Response could not be matched with Blue and Red');
            end
            
            switch raw{2, 9}
                case 1
                    oHigh = 'object';
                case 2
                    oHigh = 'scene';
                otherwise
                    error('Outcome could not be matched with Object and Scene');
            end
        end
        
        function result = getStimuliEpochsForClasses(classes)
            if ~intersect(classes, [Data.object, Data.scene, Data.alienBlue, Data.alienRed])
                error('classes must contain one of the class strings in the properties of Data');
            end
            [~, ~, raw] = xlsread([Data.RelResultsPath 'pia_2019-01-16_13-06-27_result']);
            outcomeAssignment = raw{2, 9};
            aliensAssignment = raw{2, 7};
            
            data = Data.getData('sHigh', 'sLow');
            stimuli = {data.sHigh, data.sLow};
            
            % sHigh is invariably connected to oHigh
            % assignments: 1: object is oHigh, 2: scene is oHigh
            if ismember(Data.object, classes) 
                result.object = stimuli{outcomeAssignment};
            end
            if ismember(Data.scene, classes) 
                result.scene = stimuli{3-outcomeAssignment};
            end
            if ismember(Data.alienBlue, classes) 
                result.alienBlue = stimuli{aliensAssignment};
            end
            if ismember(Data.alienRed, classes) 
                result.alienRed = stimuli{3-aliensAssignment};
            end
        end
              
    end
end