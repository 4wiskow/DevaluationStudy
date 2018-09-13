% load training data
obj = Data.getTrials('', Data.Object);
alienBlue = Data.getTrials('', Data.AlienBlue);

% concatenate training data
X = cat(1, alienBlue, obj);
% create labels
Y = cat(1, ...
    ones(size(alienBlue, 1), 1), ...
    ones(size(obj, 1), 1) + 1 ...
    );

param = mv_get_classifier_param('svm');
% has to be set again, otherwise standard lda is used!
param.classifier = 'svm';
param.repeat = 1;

[acc, result] = mv_classify_across_time(param, X, Y);

mv_plot_result(result);