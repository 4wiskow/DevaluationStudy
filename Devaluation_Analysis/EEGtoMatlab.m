classdef EEGtoMatlab
    methods (Static)
        function getDataFromEpochs(dataDirectory, subjectId, dataFilename, baselineInterval, rmvBLInterval)
            % GETDATAFROMEPOCHS extract relevant data from EEGLAB files.
            % Each subject has two DMSTask datasets (D1 and D2) and five
            % reinforcement learning datasets (R1-R5). For DSMTask
            % the trials are grouped by dataset. For ReLTask, the trials
            % are grouped by the blocks. Block order is preserved through
            % the naming convention of the corresponding fields.
            DMSSets = {[subjectId '_D1.bdf'], [subjectId '_D2.bdf']};
            

            % pop epochs relevant to DMSTask
            for i=1:length(DMSSets)
                DMSBlock = ['d' int2str(i)]; % fieldname for DMSTask block to save data to
                filepath = [dataDirectory DMSSets{i}]
                EEG = pop_biosig(filepath);
                EEG = eeg_checkset( EEG );

                % remove irrelevant electrodes
                EEG = pop_select( EEG,'nochannel',{'HEOG' 'VEOG' 'Status' 'Temp' 'Plet' 'Resp' 'Erg2' 'Erg1' 'GSR2' 'GSR1' 'EXG8' 'EXG7' 'EXG6' 'EXG5' 'EXG4' 'EXG3' 'EXG2' 'EXG1'});
                EEG = eeg_checkset( EEG );
                
                try
                    % pop sample presentations
                    epochs = pop_epoch(EEG, {21}, [-0.2 2]);
                    d.(DMSBlock).sampleObject = epochs.data;
                    epochs= pop_epoch(EEG, {22}, [-0.2 2]);
                    d.(DMSBlock).sampleScene = epochs.data;
                    epochs = pop_epoch(EEG, {23}, [-0.2 2]);
                    d.(DMSBlock).sampleBlue= epochs.data;
                    epochs = pop_epoch(EEG, {24}, [-0.2 2]);
                    d.(DMSBlock).sampleRed = epochs.data;

                    % pop delay phase
                    epochs = pop_epoch(EEG, {31}, [-0.2 2]);
                    d.(DMSBlock).delayFixationObject = epochs.data;
                    epochs= pop_epoch(EEG, {32}, [-0.2 2]);
                    d.(DMSBlock).delayFixationScene = epochs.data;
                    epochs = pop_epoch(EEG, {33}, [-0.2 2]);
                    d.(DMSBlock).delayFixationBlue = epochs.data;
                    epochs = pop_epoch(EEG, {34}, [-0.2 2]);
                    d.(DMSBlock).delayFixationRed = epochs.data;
                catch
                    warning('DMSTask is missing epochs for one or more categories. Skipping subject and saving empty data struct.')
                    d = [];
                    save(dataFilename, '-struct', 'd');
                    return
                end
            end
                    
            reinforcementSets = {}; 
            % pop epochs relevant to ReinforcementTask
            absBlockCounter = 1; % used for block order
            for j=1:length(reinforcementSets)
                datasetId = ['r' int2str(j)]; % fieldname in struct for this dataset
                filepath = [dataDirectory reinforcementSets{j}]
                EEG = pop_biosig(filepath);
                EEG = eeg_checkset( EEG );

                % remove irrelevant electrodes
                EEG = pop_select( EEG,'nochannel',{'HEOG' 'VEOG' 'Status' 'Temp' 'Plet' 'Resp' 'Erg2' 'Erg1' 'GSR2' 'GSR1' 'EXG8' 'EXG7' 'EXG6' 'EXG5' 'EXG4' 'EXG3' 'EXG2' 'EXG1'});
                EEG = eeg_checkset( EEG );

                % extract trials from noDev-Blocks
                for startNoDev = 101:2:119
                    block = EEGtoMatlab.extractBlock(EEG, startNoDev);
                    if ~isstruct(block)
                        continue
                    end
                    blockFieldname = ['block_' int2str(absBlockCounter) '_noDev_' int2str(startNoDev)];
                    [d.(datasetId).(blockFieldname).sHigh, ...
                        d.(datasetId).(blockFieldname).sLow, ...
                        d.(datasetId).(blockFieldname).questionAliensSHigh, ...
                        d.(datasetId).(blockFieldname).questionAliensSLow] = EEGtoMatlab.extractTrialsFromEpoch(block);
                    absBlockCounter = absBlockCounter + 1;
                end
                
                % extract trials from highDev-Blocks
                for startHighDev = 121:2:139
                    block = EEGtoMatlab.extractBlock(EEG, startHighDev);
                    if ~isstruct(block)
                        continue
                    end
                    blockFieldname = ['block_' int2str(absBlockCounter) '_highDev_' int2str(startHighDev)];
                    [d.(datasetId).(blockFieldname).sHigh, ...
                        d.(datasetId).(blockFieldname).sLow, ...
                        d.(datasetId).(blockFieldname).questionAliensSHigh, ...
                        d.(datasetId).(blockFieldname).questionAliensSLow] = EEGtoMatlab.extractTrialsFromEpoch(block);
                    absBlockCounter = absBlockCounter + 1;
                end
                
                % extract trials from lowDev-Blocks
                for startLowDev = 141:2:159
                    block = EEGtoMatlab.extractBlock(EEG, startLowDev);
                    if ~isstruct(block)
                        continue
                    end
                    blockFieldname = ['block_' int2str(absBlockCounter) '_lowDev_' int2str(startLowDev)];
                    [d.(datasetId).(blockFieldname).sHigh, ...
                        d.(datasetId).(blockFieldname).sLow, ...
                        d.(datasetId).(blockFieldname).questionAliensSHigh, ...
                        d.(datasetId).(blockFieldname).questionAliensSLow] = EEGtoMatlab.extractTrialsFromEpoch(block);
                    absBlockCounter = absBlockCounter + 1;
                end
                
            end

            d = EEGtoMatlab.permuteAllFields(d);
            if (~isempty(baselineInterval))
                baselineInterval = [1 ceil((baselineInterval(2)-baselineInterval(1)) * 2048)];
                d = EEGtoMatlab.correctBaseline(d, baselineInterval, rmvBLInterval);
            end
            save(dataFilename, '-struct', 'd');
            disp([dataFilename ' successfully created and saved']);

        
        end
        
        function d = correctBaseline(d, baselineInterval, removeBaselineInterval)
            % CORRECTBASELINE correct data d for baseline contained in
            % interval baselineInterval
            fnames = fieldnames(d);
            for k=1:length(fnames)
                field = d.(fnames{k});
                if isstruct(field)
                    d.(fnames{k}) = EEGtoMatlab.correctBaseline(field, ...
                    baselineInterval, removeBaselineInterval); % recursive call to process nested fields
                else
                    baselineData = field(:, :, baselineInterval(1):baselineInterval(2));
                    baselineData = mean(baselineData,3);
                    
                    if(removeBaselineInterval)
                        field = field(:, :, baselineInterval(2)+1:end);
                    end
                    baselineMatrix = repmat(baselineData,[1 1 size(field,3)]);
                    d.(fnames{k}) = field - baselineMatrix;                    
                end
            end
        end
        
        function d = permuteAllFields(d)
            % PERMUTEALLFIELDS permute data to samples x channels x time
            fnames = fieldnames(d);
            for k=1:length(fnames)
                field = d.(fnames{k});
                if isstruct(field)
                    d.(fnames{k}) = EEGtoMatlab.permuteAllFields(field);
                else
                    d.(fnames{k}) = permute(field, [3 1 2]);
                end
            end
        end
        
        function [sHigh, sLow, questionAliensSHigh, questionAliensSLow] = extractTrialsFromEpoch(epoch)
            % EXTRACTTRIALSFROMEPOCH extract fractal presentation and the 
            % corresponding alien question phase data
            sHighEpochs = pop_epoch(epoch, {162}, [0 5]); % 5s so it safely contains the questionAliens trigger, which always comes 2s after the stimulus
            questionAliensSHighEpochs = pop_epoch(sHighEpochs, {164}, [0 2]);
            questionAliensSHigh = questionAliensSHighEpochs.data;
            sHighEpochs = pop_select(sHighEpochs, 'time', [0 2]);
            sHigh = sHighEpochs.data;

            sLowEpochs = pop_epoch(epoch, {163}, [0 5]);
            questionAliensSLowEpochs = pop_epoch(sLowEpochs, {164}, [0 2]);
            questionAliensSLow = questionAliensSLowEpochs.data;
            sLowEpochs = pop_select(sLowEpochs, 'time', [0 2]);
            sLow = sLowEpochs.data;
        end
        
        function block = extractBlock(EEG, trigger)
            % EXTRACT BLOCK extract a block from continuous EEG data. If
            % block trigger could not be found in current dataset, block is
            % set to -1 (i.e. not a struct) and returned.
            startLat = eeg_getepochevent(EEG, int2str(trigger));
            if isnan(startLat)
                block = -1;
                return
            end
            
            endLat = eeg_getepochevent(EEG, int2str(trigger+1));
            blockDuration = (endLat - startLat) / 1000;
            block = pop_epoch(EEG, {trigger}, [0 blockDuration]);
        end
    end
end