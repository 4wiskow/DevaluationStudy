classdef Classification
    methods (Static)
        function svm = fit(X, Y, savename)
            % FIT fit SVM classifier to training data and save it
                        
            % get standard parameters
            param = mv_get_classifier_param('svm');
            % has to be set again, otherwise standard lda is used!
            param.classifier = 'svm';
            param.kernel = 'rbf';
            param.balance = 'oversample';

            svm = train_svm(param, X, Y);
            save(savename, 'svm');
        end

        function checkPerformance(svm, input, trueLabels)
            % PREDICT predict class labels of shuffled samples of classA
            % and classB with given classifier
            
            [predictedLabels, ~] = test_svm(svm, input);
            [perf, ~] = mv_calculate_performance('acc', 'clabel', predictedLabels, trueLabels);
            disp(perf);
        end
    end
end