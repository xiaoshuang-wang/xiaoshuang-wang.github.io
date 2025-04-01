clc
clear
close all
tic

%%
Path = ('..\02_DataSelectedProcessing\m1_Temporal_Interictal_Ictal\');
Mat = dir(fullfile(Path,'*.mat'));
MatName = {Mat.name}';
NumMat = length(MatName);
Index = [1:NumMat]';
%Index([2,4,9]) = [];
Index([2,4]) = [];

Overlap = 0.5; %%%%%%%%%%%%%%%%
NewPath = strcat('m0_','Temporal_TrainingTesting_A1A2Added',filesep,...
    num2str(Overlap),'Overlap',filesep);
mkdir(NewPath)

for MatNum = 1:length(Index)
    TempIndex = [];
    TempIndex = Index;
    TempIndex(MatNum) = [];
    for Num = 1:length(TempIndex)
        Route = strcat(Path,MatName{TempIndex(Num),1});
        load(Route)
        Window = 2*fs;
        NumSeizure = length(Ictal);
        Seizure = [];
        for SeizureNum = 1:NumSeizure
            Seizure = [Seizure,Ictal{SeizureNum,1}];
        end
        [NumChan,NumPoint] = size(Seizure);
        StepRate = (1-Overlap); %%%%%%%%%%%%%%%%
        NumIctalSegment = floor((NumPoint-Window)/(StepRate*Window))+1;
        TempTrainIctal = [];
        for IctalSegmentNum = 1:NumIctalSegment
            Lstart = (IctalSegmentNum-1)*(StepRate*Window)+1;
            Lend = Lstart+Window-1;
            TempTrainIctal(:,:,IctalSegmentNum) = Seizure(:,Lstart:Lend);
        end
        TrainIctal{Num,1} = TempTrainIctal;

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
        Interval = ceil(1.2*NumIctalSegment);
        InterictalIndex = [];
        InterictalIndex = randperm(NumInterictalSegment,Interval);
        TrainInterictal{Num,1} = TempTrainInterictal(:,:,InterictalIndex);
    end

    %%%%%%%%%%%%%%%%%%
    NumSub = length(TrainInterictal);
    IctalTraining = [];
    InterictalTraining = [];
    for SubNum = 1:NumSub
        InterictalTraining = cat(3,InterictalTraining,TrainInterictal{SubNum,1});
        IctalTraining = cat(3,IctalTraining,TrainIctal{SubNum,1});
    end
    NumInterictalTraining = size(InterictalTraining,3);
    InterictalTrainingLabel = zeros(1,NumInterictalTraining);
    NumIctalTraining = size(IctalTraining,3);
    IctalTrainingLabel = zeros(1,NumIctalTraining)+1;
    TempTrainingLabel = [];
    TempTrainingLabel = [InterictalTrainingLabel,IctalTrainingLabel];
    TempTraining = cat(3,InterictalTraining,IctalTraining);
    
    TrainingIndex = [];
    TrainingIndex = randperm(length(TempTrainingLabel));
    TrainingLabel = TempTrainingLabel(TrainingIndex);
    Training = TempTraining(:,:,TrainingIndex);

    Route = strcat(Path,MatName{Index(MatNum),1});
    load(Route)
    NumSeizure = length(Ictal);
    Seizure = [];
    for SeizureNum = 1:NumSeizure
        Seizure = [Seizure,Ictal{SeizureNum,1}];
    end
    [NumChan,NumPoint] = size(Seizure);
    NumIctalSegment = NumPoint/Window;
    TestIctal = [];
    for IctalSegmentNum = 1:NumIctalSegment
        Lstart = (IctalSegmentNum-1)*Window+1;
        Lend = Lstart+Window-1;
        TestIctal(:,:,IctalSegmentNum) = Seizure(:,Lstart:Lend);
    end

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
    Testing = cat(3,TestInterictal,TestIctal);

    TrainTest{1,1} = Training;
    TrainTest{1,2} = TrainingLabel';
    TrainTest{1,3} = Testing;
    TrainTest{1,4} = TestingLabel';

    if Index(MatNum) < 10
        save([NewPath,'Pat_',int2str(0),int2str(Index(MatNum))],'TrainTest')
        clear TrainTest
    else
        save([NewPath,'Pat_',int2str(Index(MatNum))],'TrainTest')
        clear TrainTest
    end
end

%%
toc