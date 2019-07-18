baseDirectory = 'C:\Users\maria\Documents\Praktikum\DevaluationStudy\Devaluation_12-0719\';
subjectIds = {'001', '004'};
dataDirectory = [baseDirectory currentSubject filesep '2_EEG' filesep];

% dataHandler = Data(dataDirectory, currentSubject);
% data = dataHandler.data;

data = getDMSForAllSubjects(subjectIds, baseDirectory);  

% sample presentation phase
categoryClassifier = Analysis.trainForClassesAcrossTime(data, 'sampleObject', 'sampleScene', 'svm_sample_obj_sce');
aliensClassifier = Analysis.trainForClassesAcrossTime(data, 'sampleBlue', 'sampleRed', 'svm_sample_blue_red');

function data = getDMSForAllSubjects(subjectIds, baseDirectory)
    data.d1 = [];
    data.d2 = [];
    for i=1:length(subjectIds) % iterate over subjects
            currentSubject = subjectIds{i};
            dataDirectory = [baseDirectory currentSubject filesep '2_EEG' filesep];
            dataHandler = Data(dataDirectory, currentSubject);
            
            fnames = fieldnames(dataHandler.data.d1);
            for f=1:length(fnames)
                field = fnames{f};
                if ~isfield(data.d1, field)
                    data.d1.(field) = [];
                end
                if ~isfield(data.d2, field)
                    data.d2.(field) = [];
                end
                data.d1.(field) = cat(1, data.d1.(field), dataHandler.data.d1.(field));
                data.d2.(field) = cat(1, data.d2.(field), dataHandler.data.d2.(field));
            end
    end
end