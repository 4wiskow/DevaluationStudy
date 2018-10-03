clear
% load training data
processingLevel = Data.RawFiltered;
obj = Data.getTrials('', Data.Object, processingLevel);
sce = Data.getTrials('', Data.Scene, processingLevel);
fac = Data.getTrials('', Data.Face, processingLevel);
alienBlue = Data.getTrials('', Data.AlienBlue, processingLevel);
alienRed = Data.getTrials('', Data.AlienRed, processingLevel);
datasets = {obj, sce, fac, alienBlue, alienRed};
datasetNames = {'obj', 'sce', 'fac', 'alienBlue', 'alienRed'};
kernels = {'linear', 'rbf', 'polynomial'};

% [perf, result] = mv_classify_across_time(param, X, Y);
% mv_plot_result(result);

% pca = Data.toPrincipalComponents(cat(1,fac, alienBlue));
% nonPCA = cat(1, alienBlue, alienRed);
% param = getParams();
% [perf, result] = mv_classify_across_time(param, nonPCA, prepLabels(alienBlue, alienRed));
% mv_plot_result(result);

hyperopt(@hpSearchlight, datasets, kernels, datasetNames, convertStringsToChars(processingLevel))

function X = prepSamples(classA, classB, windowStart, windowEnd)
    % PREPSAMPLES preprocess samples of two classes. Not used at the
    % moment.
    X = cat(1, classA, classB);
    
    % choose time window of data
    if windowEnd < 0
        X = X(:, :, windowStart:end);
    else
        X = X(:, :, windowStart:windowEnd);
    end
    X = mean(X, 3); % mean across window
    
    % tryout for smoothing
    for trial=1:148
        for channel=1:128
            X(trial, channel, :) = smooth(X(trial, channel, :), 20);
        end
    end
    
    X = zscore(X);
    
end
    
function Y = prepLabels(classA, classB)
    % PREPLABELS create true labels for two classes
    Y = cat(1, ...
        ones(size(classA, 1), 1), ...
        ones(size(classB, 1), 1) + 1 ...
        );
    
end
    
    
function param = getParams()
    % GETPARAMS get standard parameters
    param = mv_get_classifier_param('svm');
    % has to be set again, otherwise standard lda is used!
    param.classifier = 'svm';
    param.kernel = 'linear';
    param.balance = 'oversample';
    param.repeat = 1;
    
end
    
function hyperopt(func, datasets, kernels, datasetNames, processingLevel)
    % HYPEROPT hyperparameter optimization. Tries out all combinations of
    % kernels and datasets and saves the results in a table.
    %
    % Parameters
    %   datasets        - cell array of datasets
    %   kernels         - cell array of char array definitions of kernels 
    %                     (e.g. 'linear')
    %   datasetNames    - cell array of the names of the datasets
    %   processingLevel - string containing the level of preprocessing used
    %                     on the datasets (see Data.m)
    % Output
    %   hyperopt_xxx    - table of configurations and accuracies
    %   result_xxx      - struct for each configuration separately 
    %                     containing the result
    
    combinationIndexes = combnk(linspace(1, 5, 5), 2);
    nConfigs = size(combinationIndexes, 1) * size(kernels, 2);

    % create table to save the configurations and accuracies in
    variableTypes = {'string', 'string', 'string', 'string', 'int8', 'string', 'double'};
    variableNames = {'kernel', 'classA', 'classB', 'balancing', 'repetitions', 'processing', 'accuracy'};
    resultsTable = table('Size', [nConfigs size(variableNames, 2)], ...
        'VariableTypes', variableTypes, ...
        'VariableNames', variableNames);
    
    % set parameters of classifier
    param = mv_get_classifier_param('svm');
    % has to be set again, otherwise standard 'lda' is used!
    param.classifier = 'svm';
    param.balance = 'oversample'; % balance datasets of different sizes
    param.repeat = 1;
    
    resultsCollection = [];
    % iterate across dataset combinations for each kernel
    for kernelIdx=1:size(kernels, 2)
        for i=1:size(combinationIndexes, 1)
            % get combination of datasets and the kernel to evaluate the svm for
            combination = datasets(combinationIndexes(i, :));
            classA = combination{1};
            classB = combination{2};
            param.kernel = kernels{kernelIdx};
            
            % create savename for saving the result struct
            savename = ['result_' param.classifier '_' param.kernel '_' ...
                datasetNames{combinationIndexes(i, 1)} '_' datasetNames{combinationIndexes(i, 2)} '_' ...
                param.balance '_' num2str(param.repeat) 'reps' processingLevel];
            
            % perform the evaluation function given to the hyperopt
            [perf, result, savename] = func(classA, classB, param, savename);
            
            resultsCollection = [resultsCollection result];
            % write result to table
            configID = ((kernelIdx - 1) * size(combinationIndexes, 1)) + i;
            resultsTable(configID, :) = {param.kernel, ...
                datasetNames{combinationIndexes(i, 1)}, datasetNames{combinationIndexes(i, 2)}, ...
                param.balance, param.repeat, processingLevel, mean(perf)}
            
            save(['Results\collective_' savename 'avg2TrialsNoOverlap'], 'resultsCollection'); % save result
            save(['hyperopt_' 'searchlight_' processingLevel '_avg2TrialsNoOverlap'], 'resultsTable'); % save table
        end
    end 
end

function [perf, result, savename] = hpCrossvalidate(classA, classB, param, savename)
    % HPCROSSVALIDATE Evaluation function for hyperparameter optimization.
    % Executes a standard crossvalidation.
    savename = ['crossval_' savename];
    
    classA = smoothdata(classA, 'movmean', 2);
    classB = smoothdata(classB, 'movmean', 2);
    
    % concatenate training data
    X = cat(1, classA, classB);
%   X = X(:, :, 100:end);
    X = mean(X, 3);
    X = zscore(X);

    % create labels
    Y = prepLabels(classA, classB);

    [perf, result] = mv_crossvalidate(param, X, Y);
%   [perf, result] = mv_classify_across_time(param, X, Y);

    disp(mean(perf))
end

function [perf, result, savename] = hpSearchlight(classA, classB, param, savename)
    % HPSEARCHLIGHT Evaluation function for hyperparameter optimization.
    % Evaluates the channels for their classification accuracy and plots
    % the results.
    
    savename = ['searchlight_' savename];
    
    classA = Data.averageTrialsWithoutOverlap(classA, 2);
    classB = Data.averageTrialsWithoutOverlap(classB, 2);
    % concatenate training data
    X = cat(1, classA, classB);
%   X = X(:, :, 100:end);
    X = mean(X, 3);
    X = zscore(X);

    % create labels
    Y = prepLabels(classA, classB);
    
    param.outline = Data.getTopographyOutline();
    channelLocs = Data.getChannelLocations();
    [perf, result] = mv_searchlight(param, X, Y);
    h = mv_plot_topography(param, perf, channelLocs);
    savefig(savename);
    
end