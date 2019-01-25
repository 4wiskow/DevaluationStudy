data = Data.getData('d1', 'd2');

checkPerformanceOnTask(data.d1);
checkPerformanceOnTask(data.d2);

function checkPerformanceOnTask(data)
    % CHECKPERFORMANCEONTASK train svm on a block of DSM task and check ist
    % performance on the data it was trained on.

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
    perf = Classification.checkPerformance(classifier, X, Y);
    disp(perf);
end