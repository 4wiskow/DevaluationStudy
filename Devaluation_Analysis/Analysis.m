clear
data = Data.getData();

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
[alien, oHigh] = Data.getAlienAndOutcomeAssignedToSHigh();
% sHigh is linked to oHigh. Assignment of classes to A or B decides labels.
% To keep 'object' with same label as in training, we need to keep trials
% linked with 'object' assigned to A.
if strcmp(oHigh, 'object')
    testingClassA = data.sHigh;
    testingClassB = data.sLow;
else
    testingClassA = data.sLow;
    testingClassB = data.sHigh;
end

% test performance on reinforcementTask trials
disp('SVM performance on testing data:');
XTest = Data.generateInput(testingClassA, testingClassB);
YTest = Data.generateLabels(testingClassA, testingClassB);
[XTest, YTest] = Data.shuffleInputAndLabels(XTest, YTest);
Classification.checkPerformance(classifier, XTest, YTest);
