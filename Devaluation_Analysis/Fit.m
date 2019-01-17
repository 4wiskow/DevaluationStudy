clear

data = Data.getData();
fit_svm(data.delayFixationObject, data.delayFixationScene, 'svm_obj_sce');
fit_svm(data.delayFixationBlue, data.delayFixationRed, 'svm_blue_red');

function fit_svm(classA, classB, savename)
    % fit SVM discriminating red vs blue alien
    X = cat(1, classA, classB);
    X = mean(X, 3);
    X = zscore(X);

    Y = cat(1, ...
            ones(size(classA, 1), 1), ...
            ones(size(classB, 1), 1) + 1 ...
            );

    % get standard parameters
    param = mv_get_classifier_param('svm');
    % has to be set again, otherwise standard lda is used!
    param.classifier = 'svm';
    param.kernel = 'linear';
    param.balance = 'oversample';
    param.repeat = 1;

    svm = train_svm(param, X, Y);
    save(savename, 'svm');
end
