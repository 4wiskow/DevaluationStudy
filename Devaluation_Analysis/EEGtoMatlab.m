clear
Path = 'C:\Users\maria\Documents\Praktikum\DevaluationStudy\Ana_24-01-19\';
DMSSets = {'004_D1.bdf', '004_D2.bdf'};

% initialize data struct
d.sampleObject = [];
d.sampleScene = [];
d.sampleBlue = [];
d.sampleRed = [];
d.delayFixationObject = [];
d.delayFixationScene = [];
d.delayFixationBlue = [];
d.delayFixationRed = [];
d.choiceObject = [];
d.choiceScene = [];
d.choiceBlue= [];
d.choiceRed= [];
d.sHigh = [];
d.sLow = [];
d.questionAliensSLow = [];
d.questionAliensSHigh = [];



% pop epochs relevant to DMSTask
for i=1:length(DMSSets)
    filepath = [Path DMSSets{i}]
    EEG = pop_biosig(filepath);
    EEG = eeg_checkset( EEG );

    % remove irrelevant electrodes
    EEG = pop_select( EEG,'nochannel',{'HEOG' 'VEOG' 'Status' 'Temp' 'Plet' 'Resp' 'Erg2' 'Erg1' 'GSR2' 'GSR1' 'EXG8' 'EXG7' 'EXG6' 'EXG5' 'EXG4' 'EXG3' 'EXG2' 'EXG1'});
    EEG = eeg_checkset( EEG );

    % pop sample presentations
    epochs = pop_epoch(EEG, {21}, [0 2]);
    d.sampleObject = cat(3, d.sampleObject, epochs.data);
    epochs= pop_epoch(EEG, {22}, [0 2]);
    d.sampleScene = cat(3, d.sampleScene, epochs.data);
    epochs = pop_epoch(EEG, {23}, [0 2]);
    d.sampleBlue= cat(3, d.sampleBlue, epochs.data);
    epochs = pop_epoch(EEG, {24}, [0 2]);
    d.sampleRed = cat(3, d.sampleRed, epochs.data);
    
    % pop delay phase
    epochs = pop_epoch(EEG, {31}, [0 2]);
    d.delayFixationObject = cat(3, d.delayFixationObject, epochs.data);
    epochs= pop_epoch(EEG, {32}, [0 2]);
    d.delayFixationScene = cat(3, d.delayFixationScene, epochs.data);
    epochs = pop_epoch(EEG, {33}, [0 2]);
    d.delayFixationBlue = cat(3, d.delayFixationBlue, epochs.data);
    epochs = pop_epoch(EEG, {34}, [0 2]);
    d.delayFixationRed = cat(3, d.delayFixationRed, epochs.data);

    % pop response presentation
    epochs = pop_epoch(EEG, {41}, [0 2]);
    d.choiceObject = cat(3, d.choiceObject, epochs.data);
    epochs = pop_epoch(EEG, {42}, [0 2]);
    d.choiceScene = cat(3, d.choiceScene, epochs.data);
    epochs = pop_epoch(EEG, {43}, [0 2]);
    d.choiceBlue = cat(3, d.choiceBlue, epochs.data);
    epochs = pop_epoch(EEG, {44}, [0 2]);
    d.choiceRed = cat(3, d.choiceRed, epochs.data);
    
end

reinforcementSets = {'004_R1.bdf', '004_R2.bdf', '004_R3.bdf'}; % R5 no epochs found?, R3 sHigh no trials?
% pop epochs relevant to ReinforcementTask
for i=1:length(reinforcementSets)
    filepath = [Path reinforcementSets{i}]
    EEG = pop_biosig(filepath);
    EEG = eeg_checkset( EEG );

    % remove irrelevant electrodes
    EEG = pop_select( EEG,'nochannel',{'HEOG' 'VEOG' 'Status' 'Temp' 'Plet' 'Resp' 'Erg2' 'Erg1' 'GSR2' 'GSR1' 'EXG8' 'EXG7' 'EXG6' 'EXG5' 'EXG4' 'EXG3' 'EXG2' 'EXG1'});
    EEG = eeg_checkset( EEG );

    sHighEpochs = pop_epoch(EEG, {162}, [0 5]);
    questionAliensSHighEpochs = pop_epoch(sHighEpochs, {164}, [0 2]);
    d.questionAliensSHigh = cat(3, d.questionAliensSHigh, questionAliensSHighEpochs.data);
    sHighEpochs = pop_select(sHighEpochs, 'time', [0 2]);
    d.sHigh = cat(3, d.sHigh, sHighEpochs.data);
    
    sLowEpochs = pop_epoch(EEG, {163}, [0 5]);
    questionAliensSLowEpochs = pop_epoch(sLowEpochs, {164}, [0 2]);
    d.questionAliensSLow = cat(3, d.questionAliensSLow, questionAliensSLowEpochs.data);
    sLowEpochs = pop_select(sLowEpochs, 'time', [0 2]);
    d.sLow = cat(3, d.sLow, sLowEpochs.data);
end

% permute to trials x channels x time
fnames = fieldnames(d);
for i=1:length(fnames)
    d.(fnames{i}) = permute(d.(fnames{i}), [3 1 2]);
end

save('data', '-struct', 'd');
