clear
data = Data.getData('sampleObject', 'sampleScene');

% training input: delay or sample representation epochs of each trial
trainingClassA = data.sampleObject;
trainingClassB = data.sampleScene;
% use only trials which were correctly matched
trainingClassA = trainingClassA(Data.getIndicesOfCorrectlyMatched(Data.object));
trainingClassB = trainingClassB(Data.getIndicesOfCorrectlyMatched(Data.scene));
% average trials
trainingClassA = Data.averageTrialsWithoutOverlap(trainingClassA, 2);
trainingClassB = Data.averageTrialsWithoutOverlap(trainingClassB, 2);

% fit classifier on training data
X = Data.generateInput(trainingClassA, trainingClassB);
Y = Data.generateLabels(trainingClassA, trainingClassB);
[X, Y] = Data.shuffleInputAndLabels(X, Y);
classifier = Classification.fit(X, Y, 'svm_obj_sce');

disp('SVM performance on training data:');
Classification.checkPerformance(classifier, X, Y);


% testing input: reinforcementTask trials; fractal presentation or
% questionAliens
testingData = Data.getStimuliEpochsForObjectAndScene(['object', 'scene']);
testingClassA = testingData.object;
testingClassA = Data.averageTrialsWithoutOverlap(testingClassA, 2);
testingClassALabel = 1;
testingClassB = testingData.scene;
testingClassB = Data.averageTrialsWithoutOverlap(testingClassB, 2);
testingClassBLabel = 2;

% test performance on reinforcementTask trials
disp('SVM performance on testing data:');
XTest = Data.generateInput(testingClassA, testingClassB);
YTest = Data.generateChosenLabels(testingClassA, testingClassALabel, testingClassB, testingClassBLabel);
[XTest, YTest] = Data.shuffleInputAndLabels(XTest, YTest);
nTrials = 5;
perf = Classification.checkPerformanceAcrossTime(classifier, XTest, YTest, nTrials);
plot(linspace(1, size(XTest, 1), size(XTest, 1)/nTrials), perf);


