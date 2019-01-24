clear
Path = 'C:\Users\maria\Documents\Praktikum\DevaluationStudy\Test-Daten_17-01-18\Test-Daten\';
DMSSets = {'k_pia_D1 -Deci.bdf'};

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
d.questionAliens= [];
d.outcome = [];

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

reinforcementSets = {'k_pia_R1-Deci.bdf', 'k_pia_R2-Deci.bdf', 'k_pia_R4-Deci.bdf'}; % R5 no epochs found?, R3 sHigh no trials?
% pop epochs relevant to ReinforcementTask
for i=1:length(reinforcementSets)
    filepath = [Path reinforcementSets{i}]
    EEG = pop_biosig(filepath);
    EEG = eeg_checkset( EEG );

    % remove irrelevant electrodes
    EEG = pop_select( EEG,'nochannel',{'HEOG' 'VEOG' 'Status' 'Temp' 'Plet' 'Resp' 'Erg2' 'Erg1' 'GSR2' 'GSR1' 'EXG8' 'EXG7' 'EXG6' 'EXG5' 'EXG4' 'EXG3' 'EXG2' 'EXG1'});
    EEG = eeg_checkset( EEG );

    epochs = pop_epoch(EEG, {162}, [0 2]);
    d.sHigh = cat(3, d.sHigh, epochs.data);
    epochs = pop_epoch(EEG, {163}, [0 2]);
    d.sLow = cat(3, d.sLow, epochs.data);
    epochs = pop_epoch(EEG, {164}, [0 2]);
    d.questionAliens = cat(3, d.questionAliens, epochs.data);
    epochs = pop_epoch(EEG, {168}, [0 2]);
    d.outcome = cat(3, d.questionAliens, epochs.data);
    
end

% permute to trials x channels x time
fnames = fieldnames(d);
for i=1:length(fnames)
    d.(fnames{i}) = permute(d.(fnames{i}), [3 1 2]);
end

save('data', '-struct', 'd');
