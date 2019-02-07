classdef Data
    properties
        data % internal data struct
    end
    properties (Constant)
        % class string identifiers in results table
        alienBlue = "alienBlue";
        alienRed = "alienRed";
        object = "object";
        scene = "scene";
        
        noDevBlock = "noDev";
        highDevBlock = "highDev";
        lowDevBlock = "lowDev";
        allBlocks = "Dev"; % all block fields contain 'Dev'
        
        nBlocksExpected = 10;
    end
    
    methods (Static)
        function obj = Data(directory, subjectId, varargin)
            % DATA constructor
            dataFilename = ['data_' subjectId '.mat'];
            if ~isfile(dataFilename)
                EEGtoMatlab.getDataFromEpochs(directory, subjectId, dataFilename);
            end
            obj.data = load(dataFilename, varargin{1:end});
            
        end
        
        function averagedTrials = averageTrialsWithoutOverlap(data, windowSize)
            % Average adjacent trials without overlap
            averagedTrials = [];
            for i=1:windowSize:size(data, 1)-1
                averagedTrials = cat(1, averagedTrials, mean(data(i:i+windowSize-1, :, :), 1));
            end
        end
        
        function input = generateInput(classA, classB)
            % GENERATEINPUT generate input to fit a classifier to.
            input = cat(1, classA, classB);
            input = mean(input, 3); % average across time
            input = zscore(input); % faster convergence during training
        end
        
        function labels = generateChosenLabels(classA, classALabel, classB, classBLabel)
            % GENERATECHOSENLABELS generate the labels for two classes as
            % chosen
            labels = cat(1, ...
            repmat(classALabel, size(classA, 1), 1), ...
            repmat(classBLabel, size(classB, 1), 1) ...
            );
        end
        
        function labels = generateLabels(classA, classB)
            % GENERATE LABELS generate labels for two classes in standard
            % way (i.e. class A = 1, class B = 2)
            labels = Data.generateChosenLabels(classA, 1, classB, 2);
        end
        
        function [shuffledInput, shuffledLabels] = shuffleInputAndLabels(input, labels)
            % SHUFFLEINPUTANDLABELS shuffle input samples and labels
            % equally, such that the label at index i still corresponds to
            % the sample at index i
            if size(input, 1) ~= size(labels, 1)
                error("Input and Labels must be of same length");
            end
            shuffleIndices = randperm(size(labels, 1));
            shuffledInput = input(shuffleIndices, :);
            shuffledLabels = labels(shuffleIndices);
        end
        
        function result = getFraktalEpochsForClassesByBlocks(data, blockType, classes, relResultsPath)
            % GETFRAKTALEPOCHSFORCLASSESBYBLOCKS get the data of fractal
            % presentation either by the aliens that like them or the category 
            % the alien that likes the fraktal will reward you with.
            % Fraktal (sHigh or sLow) -> preferring Alien (blue or red) ->
            % reward category (object vs. scene)
            result = Data.getEpochsForClassesByBlocks(data, blockType, @Data.getFraktalEpochsForClasses, classes, relResultsPath);
        end
        
        function result = getQuestionAliensEpochsForClassesByBlocks(data, blockType, classes, relResultsPath)
            % GETFRAKTALEPOCHSFORCLASSESBYBLOCKS get the data of alien
            % question presentation corresponding to the chosen classes, i.e.
            % the category given as reward by the alien.
            % Alien Question (blue or red) -> reward category (object vs. scene)
            result = Data.getEpochsForClassesByBlocks(data, blockType, @Data.getQuestionAliensEpochsForClasses, classes, relResultsPath);
        end
                     
        function relevantBlocks = getEpochsForClassesByBlocks(data, blockType, extractorFunction, classes, relResultsPath)
            % GETEPOCHSFORCLASSESBYBLOCKS use extractorFunction to extract
            % the reinforcement learning data (i.e. fractal vs.
            % questionAliens phases) for the corresponding classes (i.e.
            % aliens or category) from each block of type blockType.
            relevantBlocks = {};
            blockCounter = 1;
            for i=1:5 % iterate reinforcement learning datasets of subject
                reLDatasetField = ['r' int2str(i)];
                reLDataset = data.(reLDatasetField);
                fields = fieldnames(reLDataset);
                for j=1:length(fields) % iterate blocks contained in dataset
                    if contains(fields{j}, blockType)
                        relevantBlocks{blockCounter} = extractorFunction(reLDataset.(fields{j}), classes, relResultsPath);
                        blockCounter = blockCounter + 1;
                    end
                end
            end
        end
        
        function result = getFraktalEpochsForClasses(data, classes, relResultsPath)
            % GETFRAKTALEPOCHSFORCLASSES get the fractal presentation data
            % (i.e. sHigh vs. sLow) for the corresponding classes
            if isempty(intersect(classes, [Data.object, Data.scene, Data.alienBlue, Data.alienRed]))
                error('classes must contain one of the class strings in the properties of Data');
            end
            % assignments stable across subject, first line read sufficient
            [~, ~, raw] = xlsread(relResultsPath);
            outcomeAssignment = raw{2, 9}; % ninth column holds assignment of category to oHigh
            aliensAssignment = raw{2, 7}; % seventh column holds assignment of alien to sHigh
            
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
        
        function result = getQuestionAliensEpochsForClasses(data, classes, relResultsPath)
            % GETQUESTIONALIENSEPOCHSFORCLASSES get the alien question  
            % presentation data (i.e. questionAliensSHigh vs. questionAliensSLow)
            % for the corresponding classes
            if isempty(intersect(classes, [Data.object, Data.scene]))
                error('classes must contain one of the class strings in the properties of Data');
            end
            [~, ~, raw] = xlsread(relResultsPath);
            outcomeAssignment = raw{2, 9};
            
%             data = Data.getData(directory, subjectId, 'questionAliensSHigh', 'questionAliensSLow');
            stimuli = {data.questionAliensSHigh, data.questionAliensSLow};
            
            % sHigh is invariably connected to oHigh
            % assignments: 1: object is oHigh, 2: scene is oHigh
            if ismember(Data.object, classes) 
                result.object = stimuli{outcomeAssignment};
            end
            if ismember(Data.scene, classes) 
                result.scene = stimuli{3-outcomeAssignment};
            end
        end
              
    end
end