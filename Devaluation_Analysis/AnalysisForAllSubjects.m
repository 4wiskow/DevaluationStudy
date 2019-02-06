clear
baseDirectory = 'C:\Users\maria\Documents\Praktikum\DevaluationStudy\2_Daten_29-01-19\';
subjectIds = {'004'};
nSubjects = length(subjectIds);
nNoDevBlocks = 11;
nDevSHighBlocks = 10;
nDevSLowBlocks = 10;

% TODO loop over block types
nCols = 71; % nTrials / 5, replace with n*Blocks

% table column types
[variableTypes{1:nCols}] = deal('single');
variableTypes = [{'string'}, variableTypes];

% table column names
variableNames = {'VPN_Code'};
for b=1:nCols
    variableNames = [variableNames, {['Block_' int2str(b)]}];
end
        
% init results tables
sampleObjectSceneFraktalResults = table('Size', [nSubjects, nCols+1], 'VariableTypes', variableTypes, 'VariableNames', variableNames);
sampleObjectSceneQAResults = table('Size', [nSubjects, nCols+1], 'VariableTypes', variableTypes, 'VariableNames', variableNames);
sampleBlueRedFraktalResults = table('Size', [nSubjects, nCols+1], 'VariableTypes', variableTypes, 'VariableNames', variableNames);
delayObjectSceneFraktalResults = table('Size', [nSubjects, nCols+1], 'VariableTypes', variableTypes, 'VariableNames', variableNames);
delayObjectSceneQAResults = table('Size', [nSubjects, nCols+1], 'VariableTypes', variableTypes, 'VariableNames', variableNames);
delayBlueRedFraktalResults = table('Size', [nSubjects, nCols+1], 'VariableTypes', variableTypes, 'VariableNames', variableNames);

for i=1:length(subjectIds)
    currentSubject = subjectIds{i};
    dataDirectory = [baseDirectory '2_EEG\' currentSubject filesep];
    reinforcementLearningResultsPath = ...
        [baseDirectory ...
        '1_Behavioral\' ...
        currentSubject filesep ... % folders will be named by subject ids
        'ReinforcementTask\output\result\' ... % will this always be correct?
        'pia_2019-01-16_13-06-27_result']; % filename pattern?
    
    % run analysis for current subject
    results = Analysis.analyseSubject(currentSubject, dataDirectory, reinforcementLearningResultsPath);
    
    % fill in VPN-Code
    sampleObjectSceneFraktalResults{i, 1} = convertCharsToStrings(currentSubject);
    sampleObjectSceneQAResults{i, 1} = convertCharsToStrings(currentSubject);
    sampleBlueRedFraktalResults{i, 1} = convertCharsToStrings(currentSubject);
    delayObjectSceneFraktalResults{i, 1} = convertCharsToStrings(currentSubject);
    delayObjectSceneQAResults{i, 1} = convertCharsToStrings(currentSubject);
    delayBlueRedFraktalResults{i, 1} = convertCharsToStrings(currentSubject);
    
    % fill row with performance values
    for j=1:nCols
        sampleObjectSceneFraktalResults{i, j+1} = results.sampleObjectSceneFraktalResults(j);
        sampleObjectSceneQAResults{i, j+1} = results.sampleObjectSceneQAResults(j);
        sampleBlueRedFraktalResults{i, j+1} = results.sampleBlueRedFraktalResults(j);
        delayObjectSceneFraktalResults{i, j+1} = results.delayObjectSceneFraktalResults(j);
        delayObjectSceneQAResults{i, j+1} = results.delayObjectSceneQAResults(j);
        delayBlueRedFraktalResults{i, j+1} = results.delayBlueRedFraktalResults(j);
    end
    
end

