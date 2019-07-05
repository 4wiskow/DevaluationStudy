classdef Analysis
    methods (Static)
        function results = analyseSubject(blockType, subjectId, dataDirectory, resultsPath)
            % ANALYSESUBJECT fit models to sample and delay phases of
            % DMS task and test them on fractal and questionAlien phases of
            % reinforcement learning task.
            dataHandler = Data(dataDirectory, subjectId);
            data = dataHandler.data;
            
            % test data from reinforcement learning phase
            testFraktalToCategory = Data.getFraktalEpochsForClassesByBlocks(data, blockType, [Data.object, Data.scene], resultsPath);
            testQuestionAliensToCategory = Data.getQuestionAliensEpochsForClassesByBlocks(data, blockType, [Data.object, Data.scene], resultsPath);
            testFraktalToAliens = Data.getFraktalEpochsForClassesByBlocks(data, blockType, [Data.alienBlue, Data.alienRed], resultsPath);
            
            results = [];
            % SAMPLE PRESENTATION MODEL
            % fit OBJECTS vs. SCENES in sample presentation phase
            categoryClassifier = Analysis.trainForClasses(data, 'sampleObject', 'sampleScene', 'svm_sample_obj_sce');
            % fit BLUE ALIEN vs. RED ALIEN in sample presentation phase
            aliensClassifier = Analysis.trainForClasses(data, 'sampleBlue', 'sampleRed', 'svm_sample_blue_red');
            
            % test Sample-DMS -> Fraktal
            testPerf = Analysis.testAcrossBlocks(categoryClassifier, testFraktalToCategory, [Data.object, Data.scene]);
            results.sampleObjectSceneFraktalResults = testPerf;

            % test Sample-DMS -> QuestionAliens
            testPerf = Analysis.testAcrossBlocks(categoryClassifier, testQuestionAliensToCategory, [Data.object, Data.scene]);
            results.sampleObjectSceneQAResults = testPerf;

            % test Sample-DMS -> Fraktal
            testPerf = Analysis.testAcrossBlocks(aliensClassifier, testFraktalToAliens, [Data.alienBlue, Data.alienRed]);
            results.sampleBlueRedFraktalResults = testPerf;


            % DELAY PHASE MODEL
            % fit OBJECTS vs. SCENES in delay phase
            categoryClassifier = Analysis.trainForClasses(data, 'delayFixationObject', 'delayFixationScene', 'svm_delay_obj_sce');
            % fit BLUE ALIEN vs. RED ALIEN in delay phase
            aliensClassifier = Analysis.trainForClasses(data, 'delayFixationBlue', 'delayFixationRed', 'svm_delay_blue_red');

            % test Delay-DMS -> Fraktal
            testPerf = Analysis.testAcrossBlocks(categoryClassifier, testFraktalToCategory, [Data.object, Data.scene]);
            results.delayObjectSceneFraktalResults = testPerf;

            % test Delay-DMS -> QuestionAliens
            testPerf = Analysis.testAcrossBlocks(categoryClassifier, testQuestionAliensToCategory, [Data.object, Data.scene]);
            results.delayObjectSceneQAResults = testPerf;
            
            % test Delay-DMS -> Fraktal
            testPerf = Analysis.testAcrossBlocks(aliensClassifier, testFraktalToAliens, [Data.alienBlue, Data.alienRed]);
            results.delayBlueRedFraktalResults = testPerf;
        end

        function classifier = trainForClasses(data, classAFieldname, classBFieldname, savename)
            % TRAINFORCLASSES train a SVM classifier for two classes of
            % trials and save it. Two adjacent trials are averaged to increase
            % signal-to-noise ratio.
            trainingClassA = cat(1, data.d1.(classAFieldname), data.d2.(classAFieldname));
            trainingClassB = cat(1, data.d1.(classBFieldname), data.d2.(classBFieldname));
      
            trainingClassA = Data.averageTrialsWithoutOverlap(trainingClassA, 2);
            trainingClassB = Data.averageTrialsWithoutOverlap(trainingClassB, 2);

            % fit model to training data
            X = Data.generateInput(trainingClassA, trainingClassB, 1);
            Y = Data.generateLabels(trainingClassA, trainingClassB);
            [X, Y] = Data.shuffleInputAndLabels(X, Y);
            classifier = Classification.classifyAcrossTime(X, Y);

%             perf = Classification.checkPerformance(classifier, X, Y);
            fprintf("SVM performance on training data for %s:", savename);
            disp(perf);
        end

        function performances = testAcrossBlocks(classifier, data, classes)
            % TESTACROSSBLOCKS test classifier for each block contained in
            % data. classes are the trial classes contained in each block.
            performances = [];
            for b=1:length(data)
                block = data{b};
                classA = block.(classes(1));
                classB = block.(classes(2));
                classA = Data.averageTrialsWithoutOverlap(classA, 2);
                classB = Data.averageTrialsWithoutOverlap(classB, 2);
                
                XTest = Data.generateInput(classA, classB, 0);
                YTest = Data.generateChosenLabels(classA, 1, classB, 2);
                perf = Classification.checkPerformance(classifier, XTest, YTest);
                performances = [performances perf];
            end
        end
    end
end