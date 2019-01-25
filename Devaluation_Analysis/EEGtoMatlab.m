clear
Path = 'C:\Users\maria\Documents\Praktikum\DevaluationStudy\Ana_24-01-19\';
DMSSets = {'004_D1.bdf', '004_D2.bdf'};

% initialize data struct
d.sHigh = [];
d.sLow = [];
d.questionAliensSLow = [];
d.questionAliensSHigh = [];


% pop epochs relevant to DMSTask
for i=1:length(DMSSets)
    DMSBlock = ['d' int2str(i)]; % fieldname for DMSTask block to save data to
    filepath = [Path DMSSets{i}]
    EEG = pop_biosig(filepath);
    EEG = eeg_checkset( EEG );

    % remove irrelevant electrodes
    EEG = pop_select( EEG,'nochannel',{'HEOG' 'VEOG' 'Status' 'Temp' 'Plet' 'Resp' 'Erg2' 'Erg1' 'GSR2' 'GSR1' 'EXG8' 'EXG7' 'EXG6' 'EXG5' 'EXG4' 'EXG3' 'EXG2' 'EXG1'});
    EEG = eeg_checkset( EEG );

    % pop sample presentations
    epochs = pop_epoch(EEG, {21}, [0 2]);
    d.(DMSBlock).sampleObject = epochs.data;
    epochs= pop_epoch(EEG, {22}, [0 2]);
    d.(DMSBlock).sampleScene = epochs.data;
    epochs = pop_epoch(EEG, {23}, [0 2]);
    d.(DMSBlock).sampleBlue= epochs.data;
    epochs = pop_epoch(EEG, {24}, [0 2]);
    d.(DMSBlock).sampleRed = epochs.data;
    
    % pop delay phase
    epochs = pop_epoch(EEG, {31}, [0 2]);
    d.(DMSBlock).delayFixationObject = epochs.data;
    epochs= pop_epoch(EEG, {32}, [0 2]);
    d.(DMSBlock).delayFixationScene = epochs.data;
    epochs = pop_epoch(EEG, {33}, [0 2]);
    d.(DMSBlock).delayFixationBlue = epochs.data;
    epochs = pop_epoch(EEG, {34}, [0 2]);
    d.(DMSBlock).delayFixationRed = epochs.data;

    % pop response presentation
    epochs = pop_epoch(EEG, {41}, [0 2]);
    d.(DMSBlock).choiceObject = epochs.data;
    epochs = pop_epoch(EEG, {42}, [0 2]);
    d.(DMSBlock).choiceScene = epochs.data;
    epochs = pop_epoch(EEG, {43}, [0 2]);
    d.(DMSBlock).choiceBlue = epochs.data;
    epochs = pop_epoch(EEG, {44}, [0 2]);
    d.(DMSBlock).choiceRed = epochs.data;
    
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
    
%     for b=13:2:71
%         block = pop_epoch(EEG, {b, b+1});
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
%     end
end

d = permuteAllFields(d);
save('data', '-struct', 'd');

% permute to trials x channels x time
function d = permuteAllFields(d)
    fnames = fieldnames(d);
    for i=1:length(fnames)
        field = d.(fnames{i});
        if isstruct(field)
            d.(fnames{i}) = permuteAllFields(field);
        else
            d.(fnames{i}) = permute(field, [3 1 2]);
        end
    end
end

