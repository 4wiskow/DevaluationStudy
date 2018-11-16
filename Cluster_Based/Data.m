classdef Data
    properties (Constant)
        stdPath = "../../Daten/EpochierteDaten";
        frequencies = ["theta", "Alpha", "low_Beta", "high_Beta", "low_Gamma", "high_Gamma"];
        subjectNames = ["014AJ", "015SB"];
        
        clusterBasedStructsPath = 'Data/ft_structs/'
        betweenSubjectsHitsFilename = 'ft_struct_hits_within_subjects.mat';
        betweenSubjectsMissesFilename = 'ft_struct_misses_within_subjects.mat';
        betweenTrialsHitsFilename = 'ft_struct_hits_between_trials.mat';
        betweenTrialsMissesFilename = 'ft_struct_misses_between_trials.mat';
    end
    
    methods (Static)
        function [hits, misses] = getAllData(subjects)
            hits = [];
            misses = [];
            for i=1:size(subjects, 2)
                [hitsForSubject, missesForSubject] = Data.getDataForSubject(subjects(i));
                hits = cat(4, hits, hitsForSubject);
                misses = cat(4, misses, missesForSubject);
            end
            hits = permute(hits, [4 1 2 3]);
            misses = permute(misses, [4 1 2 3]);
        end    
        
        function [hits, misses] = getDataForSubject(subject)
            hits = [];
            misses = [];
            for i=1:size(Data.frequencies, 2)
                [hitsForFreq, missesForFreq] = Data.getDataForFreq(subject, Data.frequencies(i));
                hits = cat(2, hits, hitsForFreq);
                misses = cat(2, misses, missesForFreq);
            end    
        end    
        
        function [combinedHits, combinedMisses] = getDataForFreq(subject, freqStr)
            if subject.isempty()
                subject = "*";
            end
            hits = dir(strcat(Data.stdPath, filesep, subject, "*", freqStr, "*HIT.mat"));
            misses = dir(strcat(Data.stdPath, filesep, subject, "*", freqStr, "*MIS.mat"));
            
            combinedHits = [];
            combinedMisses = [];
            for i=1:size(hits)
                hitsByFreq = Data.loadFromFile(hits(i).folder, hits(i).name);
                combinedHits = cat(3, combinedHits, hitsByFreq);
                
                missesByFreq = Data.loadFromFile(misses(i).folder, misses(i).name);
                combinedMisses = cat(3, combinedMisses, missesByFreq);
            end
            
            combinedHits = permute(combinedHits, [1 3 2]); 
            combinedMisses = permute(combinedMisses, [1 3 2]);
        end
        
        function data = loadFromFile(folder, name)
            data = load([folder filesep name]);
            fields = fieldnames(data);
            data = data.(fields{1});
        end    
        
        function [hits, misses] = getMegaData(avgTrials)
            directory = dir('Data');
            hits = [];
            misses = [];
            for f=1:8
                file = directory(f);
                
                if contains(file.name, 'HIT')
                    data = Data.loadFromFile(file.folder, file.name);
                    if avgTrials
                        data = mean(data, 3);
                    end
                    hits = cat(3, hits, data);
                end
                if contains(file.name, 'MIS')
                    data = Data.loadFromFile(file.folder, file.name);
                    if avgTrials
                        data = mean(data, 3);
                    end
                    misses = cat(3, misses, data);
                end
            end
        end
        
        function [hits, misses] = getWithinSubjectsDemoStructures()
            % load structs containing demo data of 2 subjects whose trials
            % have been averaged with six frequencies
            hits = Data.loadFromFile(Data.clusterBasedStructsPath, Data.betweenSubjectsHitsFilename);
            misses = Data.loadFromFile(Data.clusterBasedStructsPath, Data.betweenSubjectsMissesFilename);
        end
        
        function [hits, misses] = getBetweenTrialsDemoStructures()
            % load structs containing demo data 57 subjects whose trials
            % have been averaged for theta
            hits = Data.loadFromFile(Data.clusterBasedStructsPath, Data.betweenTrialsHitsFilename);
            misses = Data.loadFromFile(Data.clusterBasedStructsPath, Data.betweenTrialsMissesFilename);
        end
        
    end
end