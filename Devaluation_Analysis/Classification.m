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
        
        function [perf, res] = classifyAcrossTime(X, Y)
            % CLASSIFYACROSSTIME fit SVM classifier to training data for
            % each time point and return performance
                        
            % get standard parameters
            param = mv_get_classifier_param('svm');
            % has to be set again, otherwise standard lda is used!
            param.classifier = 'svm';
            param.kernel = 'rbf';
            param.balance = 'oversample';
 
            [perf, res] = mv_classify_across_time(param, X, Y);
        end
        
        function perf = checkPerformanceAcrossTime(svm, input, trueLabels, trialsPerTest)
            perf= [];
            nTrials = size(input, 1);
            for windowStart = 1 : trialsPerTest : nTrials
                windowEnd = windowStart + trialsPerTest - 1;
                if windowEnd > nTrials 
                    windowEnd = nTrials;
                end
                perf = [perf Classification.checkPerformance(svm, ...
                    input(windowStart:windowEnd, :), trueLabels(windowStart:windowEnd, :))];
            end
            disp(perf);
        end
                
        function perf = checkPerformance(svm, input, trueLabels)
            % PREDICT predict class labels of shuffled samples of classA
            % and classB with given classifier
            
            [predictedLabels, ~] = test_svm(svm, input);
            [perf, ~] = mv_calculate_performance('acc', 'clabel', predictedLabels, trueLabels);
        end
    end
end