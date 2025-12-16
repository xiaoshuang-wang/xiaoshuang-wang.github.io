clc
clear
close all
tic

%%
Path = {'..\02_DataSelectedProcessing\m1_Frontal_Interictal_Ictal\';...
    '..\02_DataSelectedProcessing\m1_Temporal_Interictal_Ictal\'};
Remove = {[6,11,16];[2,4,9]};

FrontalTemporalIctal = [];
FrontalTemporalInterictal = [];
for FileNum = 1:length(Path)
    Mat = dir(fullfile(Path{FileNum,1},'*.mat'));
    MatName = {Mat.name}';
    NumPatient = length(MatName);
    for PatientNum = 1:NumPatient
        Route = strcat(Path{FileNum,1},MatName{PatientNum,1});
        load(Route)
        FrontalTemporalIctal{PatientNum,FileNum} = Ictal;
        FrontalTemporalInterictal{PatientNum,FileNum} = Interictal;
        clear Ictal Interictal
    end
    TempIndex = [];
    TempIndex = [1:NumPatient]';
    TempIndex(Remove{FileNum,1}) = [];
    Index{FileNum,1} = TempIndex;
end

%%
Overlap = 0.5; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NewPath = strcat('m1_','FrontalTemporal_TrainingTesting',filesep,...
    num2str(Overlap),'Overlap',filesep);
mkdir(NewPath)

NumPatient = length(Index{1,1});
for PatientNum = 1:NumPatient
    TrainIctal = [];
    TrainInterictal = [];
    for FileNum = 1:length(Path)
        Mat = dir(fullfile(Path{FileNum,1},'*.mat'));
        MatName = {Mat.name}';
        TempIndex = [];
        TempIndex = Index{FileNum,1};
        TempIndex(PatientNum) = [];
        for Num = 1:length(TempIndex)
            Ictal = [];
            Ictal = FrontalTemporalIctal{TempIndex(Num),FileNum};
            Window = 2*fs;
            NumSeizure = length(Ictal);
            Seizure = [];
            for SeizureNum = 1:NumSeizure
                Seizure = [Seizure,Ictal{SeizureNum,1}];
            end

            [NumChan,NumPoint] = size(Seizure);
            if FileNum == 1
                Overlap = 0.5; %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Step = 1-Overlap;
                NumIctalSegment = floor((NumPoint-Window)/(Step*Window))+1;
                TempTrainIctal = [];
                for IctalSegmentNum = 1:NumIctalSegment
                    Lstart = (IctalSegmentNum-1)*(Step*Window)+1;
                    Lend = Lstart+Window-1;
                    TempTrainIctal(:,:,IctalSegmentNum) = Seizure(:,Lstart:Lend);
                end
            else
                Overlap = 0.4; %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Step = 1-Overlap;
                NumIctalSegment = floor((NumPoint-Window)/(Step*Window))+1;
                TempTrainIctal = [];
                for IctalSegmentNum = 1:NumIctalSegment
                    Lstart = (IctalSegmentNum-1)*(Step*Window)+1;
                    Lend = Lstart+Window-1;
                    TempTrainIctal(:,:,IctalSegmentNum) = Seizure(:,Lstart:Lend);
                end
            end
            TrainIctal{Num,FileNum} = TempTrainIctal;
            clear TempTrainIctal

            Interictal = [];
            Interictal = FrontalTemporalInterictal{TempIndex(Num),FileNum};
            NumInterictal  = length(Interictal);
            InterictalEEG = [];
            for InterictalNum = 1:NumInterictal
                InterictalEEG = [InterictalEEG,Interictal{InterictalNum,1}];
            end
            [NumChan,NumPoint] = size(InterictalEEG);
            NumInterictalSegment = floor(NumPoint/Window);
            TempTrainInterictal = [];
            for InterictalSegmentNum = 1:NumInterictalSegment
                Lstart = (InterictalSegmentNum-1)*Window+1;
                Lend = InterictalSegmentNum*Window;
                TempTrainInterictal(:,:,InterictalSegmentNum) = InterictalEEG(:,Lstart:Lend);
            end
            if FileNum == 1
                Interval = ceil(1.2*NumIctalSegment);
            else
                Interval = ceil(1.1*NumIctalSegment);
            end
            InterictalIndex = [];
            InterictalIndex = randperm(NumInterictalSegment,Interval);
            TrainInterictal{Num,FileNum} = TempTrainInterictal(:,:,InterictalIndex);
            clear TempTrainInterictal
        end
    end

    %%%%%%%%%%%
    NumSub = length(TrainInterictal);
    IctalTraining = [];
    InterictalTraining = [];
    for FileNum = 1:length(Path)
        for SubNum = 1:NumSub
            InterictalTraining = cat(3,InterictalTraining,TrainInterictal{SubNum,FileNum});
            IctalTraining = cat(3,IctalTraining,TrainIctal{SubNum,FileNum});
        end
    end
    clear TrainInterictal TrainIctal
    NumInterictalTraining = size(InterictalTraining,3);
    InterictalTrainingLabel = zeros(1,NumInterictalTraining);
    NumIctalTraining = size(IctalTraining,3);
    IctalTrainingLabel = zeros(1,NumIctalTraining)+1;
    TempTrainingLabel = [];
    TempTrainingLabel = [InterictalTrainingLabel,IctalTrainingLabel];
    TempTraining = [];
    TempTraining = cat(3,InterictalTraining,IctalTraining);
    clear InterictalTraining IctalTraining

    TrainingIndex = [];
    TrainingIndex = randperm(length(TempTrainingLabel));
    TrainingLabel = [];
    TrainingLabel = TempTrainingLabel(TrainingIndex);
    Training = [];
    Training = TempTraining(:,:,TrainingIndex);
    clear TempTraining

    TrainTest{1,1} = Training;
    TrainTest{1,2} = TrainingLabel';
    clear Training

    %%%%%%%%%%%%
    for FileNum = 1:length(Path)
        TempIndex = [];
        TempIndex = Index{FileNum,1};
        Ictal = [];
        Ictal = FrontalTemporalIctal{TempIndex(PatientNum),FileNum};
        NumSeizure = length(Ictal);
        Seizure = [];
        for SeizureNum = 1:NumSeizure
            Seizure = [Seizure,Ictal{SeizureNum,1}];
        end
        [NumChan,NumPoint] = size(Seizure);
        NumIctalSegment = floor(NumPoint/Window);
        TestIctal = [];
        for IctalSegmentNum = 1:NumIctalSegment
            Lstart = (IctalSegmentNum-1)*Window+1;
            Lend = Lstart+Window-1;
            TestIctal(:,:,IctalSegmentNum) = Seizure(:,Lstart:Lend);
        end

        Interictal = [];
        Interictal = FrontalTemporalInterictal{TempIndex(PatientNum),FileNum};
        NumInterictal  = length(Interictal);
        InterictalEEG = [];
        for InterictalNum = 1:NumInterictal
            InterictalEEG = [InterictalEEG,Interictal{InterictalNum,1}];
        end
        [NumChan,NumPoint] = size(InterictalEEG);
        NumInterictalSegment = floor(NumPoint/Window);
        TestInterictal = [];
        for InterictalSegmentNum = 1:NumInterictalSegment
            Lstart = (InterictalSegmentNum-1)*Window+1;
            Lend = InterictalSegmentNum*Window;
            TestInterictal(:,:,InterictalSegmentNum) = InterictalEEG(:,Lstart:Lend);
        end
        NumInterictalTesting = size(TestInterictal,3);
        InterictalTestingLabel = [];
        InterictalTestingLabel = zeros(1,NumInterictalTesting);
        NumIctalTesting = size(TestIctal,3);
        IctalTestingLabel = [];
        IctalTestingLabel = zeros(1,NumIctalTesting)+1;
        TestingLabel = [];
        TestingLabel = [InterictalTestingLabel,IctalTestingLabel];
        Testing = [];
        Testing = cat(3,TestInterictal,TestIctal);

        TrainTest{1,2*FileNum+1} = Testing;
        TrainTest{1,2*FileNum+2} = TestingLabel';
    end

    if PatientNum < 10
        save([NewPath,'Pat_',int2str(0),int2str(PatientNum)],'TrainTest')
        clear TrainTest
    else
        save([NewPath,'Pat_',int2str(PatientNum)],'TrainTest')
        clear TrainTest
    end
end

%%
toc