% Analyse all available subjects. For each type of blocks (NoDev, HighDev,
% LowDev), six tables containing classifier performance data are created.
% Each table holds the performance of a classifier (object vs. scene or alienBlue vs. alienRed)
% for one combination of training (sample or delay phase) and 
% test (fraktal, alien question) data across the blocks of a certain type.
%
% Expected Input Directory Structure:
% Parent Data Folder (baseDirectory)
% |-> 004 (subject ID)
%      |-> 1_Behavioral (contains results tables created by experiment)
%      |-> 2_EEG (contains the data: 004_D1, ..., 004_R5)
%
% The following directory is created for the results:
% analysis_results
% |-> highDev
%      |-> delayBlueRedFraktalResults.mat
%      |-> delayObjectSceneFraktalResults.mat
%      |-> delayObjectSceneQAResults.mat
%      |-> sampleBlueRedFraktalResults.mat
%      |-> sampleObjectSceneFraktalResults.mat
%      |-> sampleObjectSceneQAResults.mat
% |-> lowDev
%      |-> ...
% |-> noDev
%      |-> ...


clear
baseDirectory = 'C:\Users\maria\Documents\Praktikum\DevaluationStudy\Devaluation_12-0719\'; % adapt to your directory
% look for folders for each subject
subjectFolders = dir(baseDirectory);
subjectFolders=subjectFolders(~ismember({subjectFolders.name},{'.','..'})); % remove super-folders
subjectIds = {};
for folderIdx = 1:length(subjectFolders)
    subjectIds{folderIdx} = subjectFolders(folderIdx).name;
end
nSubjects = length(subjectIds);

% types of blocks to analyse
blockTypes = {Data.noDevBlock, Data.highDevBlock, Data.lowDevBlock};

for blockTypeIdx =1:length(blockTypes) % iterate over block types
    blockType = blockTypes{blockTypeIdx};
    nBlocks = Data.nBlocksExpected;

    % table column types
    variableTypes = {};
    [variableTypes{1:nBlocks}] = deal('single');
    variableTypes = [{'string'}, variableTypes];

    % table column names
    variableNames = {};
    variableNames = {'VPN_Code'};
    for b=1:nBlocks
        variableNames = [variableNames, {['Block_' int2str(b)]}];
    end

    % init results tables
    resultsTablesNames = {'sampleObjectSceneFraktalResults', 'sampleObjectSceneQAResults', ...
        'sampleBlueRedFraktalResults', 'delayObjectSceneFraktalResults', ...
        'delayObjectSceneQAResults', 'delayBlueRedFraktalResults'};
    
    % create results table variables
    for x=1:length(resultsTablesNames)
        createTableExpr = [resultsTablesNames{x} ' = table(''Size'', [nSubjects, nBlocks+1], ''VariableTypes'', variableTypes, ''VariableNames'', variableNames);'];
        eval(createTableExpr);
    end
    
    for i=1:length(subjectIds) % iterate over subjects
        currentSubject = subjectIds{i};
        dataDirectory = [baseDirectory currentSubject filesep '2_EEG' filesep];
        reinforcementLearningResultsPath = findResultsPath(baseDirectory, currentSubject);

        % run analysis for current subject
        results = Analysis.analyseSubject(blockType, currentSubject, dataDirectory, reinforcementLearningResultsPath);
        
        % add VPN-Code to each results table
        currentSubjectString = convertCharsToStrings(currentSubject);
        for rt=1:length(resultsTablesNames)
            putSubjectStringExpr = [resultsTablesNames{rt} '{1, 1} = currentSubjectString;'];
            eval(putSubjectStringExpr);
        end

        % fill subject row with performance values for each results table
        for rt=1:length(resultsTablesNames)
            tableName = resultsTablesNames{rt};
            saveResultsToTableRowExpr = sprintf("%s = saveResultsToTableRow(%s, i, results.%s, nBlocks);", tableName, tableName, tableName);
            eval(saveResultsToTableRowExpr);
        end
        
    end
    
    % save all results tables under their variable names and block type
    % folder
    outcomePath = [baseDirectory filesep '..' filesep 'analysis_results' ...
        filesep convertStringsToChars(blockType) filesep];
    if ~isfolder(outcomePath)
        mkdir(outcomePath)
    end
    for rt=1:length(resultsTablesNames)
            tableName = resultsTablesNames{rt};
            saveResultsTableExpr = sprintf("save('%s%s', '%s');", outcomePath, tableName, tableName);
            eval(saveResultsTableExpr);
    end
    
end

function table = saveResultsToTableRow(table, rowIdx, results, nBlocksExpected)
    % SAVERESULTSTABLETOROW write performance results to a row in a table.
    % Fills missing values with NaN.
    nResults = length(results);
    if nResults < nBlocksExpected
        warning('Number of results < Number of expected blocks. Filling corresponding table fields with NaN.')
        for i=nResults:nBlocksExpected
            table{rowIdx, i} = NaN;
        end
    end
    for j=1:nResults
        table{rowIdx, j+1} = results(j);
    end
end

function path = findResultsPath(baseDirectory, currentSubject)
    % FINDRESULTSPATH construct the path to the results tables created
    % during the experiment and find the results file containing the subject id
    path = ...
    [baseDirectory ...
    currentSubject filesep ... % folders will be named by subject ids
    '1_Behavioral' filesep ...
    'ReinforcementTask\output\result' filesep];% will this always be correct?
    oldPath = cd(path);
    results = dir(['*' currentSubject '*']);
    cd(oldPath);
    if length(results) > 1
        error(['More than one result table found for subject: ' currentSubject]);
    end
    path = [path results.name];

end