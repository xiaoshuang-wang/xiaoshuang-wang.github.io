clc
clear
close all
tic

%%
ChanName =  {'Fp1-REF','Fp2-REF','F3-REF','F4-REF','C3-REF',... %%% 5
    'C4-REF','P3-REF','P4-REF','O1-REF','O2-REF',... %%% 5
    'F7-REF','F8-REF','T3-REF','T4-REF','T5-REF',... %%% 5
    'T6-REF','A1-REF','A2-REF','Fz-REF','Cz-REF',... %%% 5
    'Pz-REF','Oz-REF'}'; %%% 2
A1A2Index = [17,18];

% ChanName2 =  {'Fp1-Ref','Fp2-Ref','F3-Ref','F4-Ref','C3-Ref',... %%% 5
%     'C4-Ref','P3-Ref','P4-Ref','O1-Ref','O2-Ref',... %%% 5
%     'F7-Ref','F8-Ref','T3-Ref','T4-Ref','T5-Ref',... %%% 5
%     'T6-Ref','A1-Ref','A2-Ref','Fz-Ref','Cz-Ref',... %%% 5
%     'Pz-Ref','Oz-Ref'}'; %%% 2

%%
FileName = {'01_Frontal_Raw','01_Temporal_Raw'};
NewFileName = {'Frontal','Temporal'};

for NumFile = 1:length(FileName)
    Path = [FileName{1,NumFile},filesep];
    Set = dir(fullfile(Path,'*.set'));
    SetName = {Set.name}';
    NumSet = length(SetName);

    NewPath = ['m0_',NewFileName{1,NumFile},filesep];
    mkdir(NewPath)
    for SetNum = 1:NumSet
        Route = strcat(Path,SetName{SetNum,1});
        EEG = pop_loadset(Route);
        EEG = eeg_checkset(EEG);

        Chanlocs = EEG.chanlocs;
        ChanLabels = [];
        ChanLabels = {Chanlocs.labels}';
        NumChan = length(ChanLabels);
        NumStandardChan = length(ChanName);
        ChanIndex = [];
        for StandardChanNum = 1:NumStandardChan
            for ChanNum = 1:NumChan
                tf = strcmpi(ChanName{StandardChanNum,1},ChanLabels{ChanNum,1});
                if tf == 1
                    ChanIndex(StandardChanNum,1) = ChanNum;
                end
            end
        end

        %%%%********** Based on A1 and A2 for Re-references **********%%%%
        A1A2MeanData = mean(EEG.data(ChanIndex(A1A2Index),:),1);
        EEG.data = EEG.data-A1A2MeanData;
        clear A1A2MeanData
        EEG = eeg_checkset(EEG);

        fs = EEG.srate;
        if fs < 500
            EEG = pop_eegfiltnew(EEG,'locutoff',48,'hicutoff',52,'revfilt',1,'plotfreqz',1);
            close all
            EEG = pop_eegfiltnew(EEG,'locutoff',98,'hicutoff',102,'revfilt',1,'plotfreqz',1);
            close all
            EEG = pop_eegfiltnew(EEG,'locutoff',0.5,'plotfreqz',1);
            close all
            EEG = pop_eegfiltnew(EEG,'hicutoff',70,'plotfreqz',1);
            close all
        else
            EEG = pop_eegfiltnew(EEG,'locutoff',48,'hicutoff',52,'revfilt',1,'plotfreqz',1);
            close all
            EEG = pop_eegfiltnew(EEG,'locutoff',98,'hicutoff',102,'revfilt',1,'plotfreqz',1);
            close all
            EEG = pop_eegfiltnew(EEG,'locutoff',148,'hicutoff',152,'revfilt',1,'plotfreqz',1);
            close all
            EEG = pop_eegfiltnew(EEG,'locutoff',0.5,'plotfreqz',1);
            close all
            EEG = pop_eegfiltnew(EEG,'hicutoff',70,'plotfreqz',1);
            close all
        end

        Data = double(EEG.data);
        ChanSelect = [];
        ChanSelect = ChanLabels(ChanIndex);
        X = Data(ChanIndex,:);
        MatName = SetName{SetNum,1}(1:end-4);
        NewRoute = strcat([NewPath,MatName,'.mat']);
        save(NewRoute,'X','fs','ChanSelect','ChanIndex')
    end
end

%%
toc