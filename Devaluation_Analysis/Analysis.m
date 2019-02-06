classdef Analysis
    methods (Static)
        function results = analyseSubject(subjectId, dataDirectory, resultsPath)
            data = Data.getData(dataDirectory, subjectId);
            results = [];
            % SAMPLE PRESENTATION MODEL
            % fit OBJECTS vs. SCENES in sample presentation phase
            classifier = Analysis.trainForClasses(data, 'sampleObject', 'sampleScene');

            % test Sample-DMS -> Fraktal
            testingData = Data.getFraktalEpochsForClasses(data, subjectId, [Data.object, Data.scene], resultsPath);
            testingClassA = testingData.object;
            testingClassB = testingData.scene;
            [testPerf, testing_plt] = Analysis.testForClasses(classifier, testingClassA, 1, testingClassB, 2);
            results.sampleObjectSceneFraktalResults = testPerf;

            % test Sample-DMS -> QuestionAliens
            testingData = Data.getQuestionAliensEpochsForClasses(data, subjectId, [Data.object, Data.scene], resultsPath);
            testingClassA = testingData.object;
            testingClassB = testingData.scene;
            [testPerf, testing_plt] = Analysis.testForClasses(classifier, testingClassA, 1, testingClassB, 2);
            results.sampleObjectSceneQAResults = testPerf;

            % fit BLUE ALIEN vs. RED ALIEN in sample presentation phase
            classifier = Analysis.trainForClasses(data, 'sampleBlue', 'sampleRed');
            % test Sample-DMS -> Fraktal
            testingData = Data.getFraktalEpochsForClasses(data, subjectId, [Data.alienBlue, Data.alienRed], resultsPath);
            testingClassA = testingData.alienBlue;
            testingClassB = testingData.alienRed;
            [testPerf, testing_plt] = Analysis.testForClasses(classifier, testingClassA, 1, testingClassB, 2);
            results.sampleBlueRedFraktalResults = testPerf;


            % DELAY PHASE MODEL
            % fit OBJECTS vs. SCENES in delay phase
            classifier = Analysis.trainForClasses(data, 'delayFixationObject', 'delayFixationScene');

            % test Delay-DMS -> Fraktal
            testingData = Data.getFraktalEpochsForClasses(data, subjectId, [Data.object, Data.scene], resultsPath);
            testingClassA = testingData.object;
            testingClassB = testingData.scene;
            [testPerf, testing_plt] = Analysis.testForClasses(classifier, testingClassA, 1, testingClassB, 2);
            results.delayObjectSceneFraktalResults = testPerf;

            % test Delay-DMS -> QuestionAliens
            testingData = Data.getQuestionAliensEpochsForClasses(data, subjectId, [Data.object, Data.scene], resultsPath);
            testingClassA = testingData.object;
            testingClassB = testingData.scene;
            [testPerf, testing_plt] = Analysis.testForClasses(classifier, testingClassA, 1, testingClassB, 2);
            results.delayObjectSceneQAResults = testPerf;

            % fit BLUE ALIEN vs. RED ALIEN in delay phase
            classifier = Analysis.trainForClasses(data, 'delayFixationBlue', 'delayFixationRed');
            % test Delay-DMS -> Fraktal
            testingData = Data.getFraktalEpochsForClasses(data, subjectId, [Data.alienBlue, Data.alienRed], resultsPath);
            testingClassA = testingData.alienBlue;
            testingClassB = testingData.alienRed;
            [testPerf, testing_plt] = Analysis.testForClasses(classifier, testingClassA, 1, testingClassB, 2); 
            results.delayBlueRedFraktalResults = testPerf;
        end

        function classifier = trainForClasses(data, classAFieldname, classBFieldname)
            % training input: delay or sample representation epochs of each trial
            trainingClassA = cat(1, data.d1.(classAFieldname), data.d2.(classAFieldname));
            trainingClassB = cat(1, data.d1.(classBFieldname), data.d2.(classBFieldname));
            % use only trials which were correctly matched
            % average trials
            trainingClassA = Data.averageTrialsWithoutOverlap(trainingClassA, 2);
            trainingClassB = Data.averageTrialsWithoutOverlap(trainingClassB, 2);

            % fit classifier on training data
            X = Data.generateInput(trainingClassA, trainingClassB);
            Y = Data.generateLabels(trainingClassA, trainingClassB);
            [X, Y] = Data.shuffleInputAndLabels(X, Y);
            classifier = Classification.fit(X, Y, 'svm_obj_sce');

            disp('SVM performance on training data:');
            perf = Classification.checkPerformance(classifier, X, Y);
            disp(perf);
        end

        function [perf, plt] = testForClasses(classifier, testingClassA, testingClassALabel, testingClassB, testingClassBLabel)
            testingClassA = Data.averageTrialsWithoutOverlap(testingClassA, 2);
            testingClassALabel = testingClassALabel;
            testingClassB = Data.averageTrialsWithoutOverlap(testingClassB, 2);
            testingClassBLabel = testingClassBLabel;

            % test performance on reinforcementTask trials
            disp('SVM performance on testing data:');
            XTest = Data.generateInput(testingClassA, testingClassB);
            YTest = Data.generateChosenLabels(testingClassA, testingClassALabel, testingClassB, testingClassBLabel);
            [XTest, YTest] = Data.shuffleInputAndLabels(XTest, YTest);
            nTrials = 5;
            perf = Classification.checkPerformanceAcrossTime(classifier, XTest, YTest, nTrials);
            plt = plot(linspace(1, size(XTest, 1), ceil(size(XTest, 1)/nTrials)), perf);
        end
    end
end