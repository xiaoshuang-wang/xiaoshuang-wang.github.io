clc
clear
close all
tic

%%
FileName = ['m2_','Temporal_Interictal_Ictal_Segment_A1A2Added'];
Path = [FileName,filesep];
Mat = dir(fullfile(Path,'*.mat'));
MatName = {Mat.name}';
NumSub = length(MatName);

%%
NewPath = ['m3_','Temporal_Training_Testing_A1A2Added',filesep];
mkdir(NewPath)
ThresholdNum = [25, 50, 75, 100, 125, 175];
Ratio = [0.95, 0.9, 0.85, 0.8, 0.75, 0.65, 0.5];
Snr = [10,5,2,1];

for SubNum = 1:NumSub
    Route = strcat(Path,MatName{SubNum,1});
    load(Route);
    Interictal = [];
    Ictal = [];
    Interictal = Segment{1,1};
    Ictal = Segment{1,2};
    Segment = [];
    Window = 2*fs;

    NumSeizure = length(Ictal);
    Index = [];
    Index = 1:NumSeizure;

    %%%% for Interictal samples
    TempInterictal = [];
    for Num = 1:length(Interictal)
        Temp = Interictal{Num,1};
        TempInterictal = cat(3,TempInterictal,Temp);
        Temp = [];
    end
    InterictalSamp = [];
    [NumChan,NumPoint,NumSamp] = size(TempInterictal);
    Interval = floor(NumSamp/NumSeizure);
    InterictalIndex = [];
    InterictalIndex = randperm(NumSamp);
    for SeizureNum = 1:NumSeizure
        Lstart = (SeizureNum-1)*Interval+1;
        Lend = SeizureNum*Interval;
        TempIndex = [];
        TempIndex = InterictalIndex(Lstart:Lend);
        InterictalSamp{SeizureNum,1} = TempInterictal(:,:,TempIndex);
    end


    %%%% for Ictal samples
    TempIndex = [];
    for SeizureNum = 1:NumSeizure
        TempIndex = Index;
        TempIndex(SeizureNum) = [];
        IctalSelect = [];
        for Num = 1:length(TempIndex)
            TempIctal = Ictal{TempIndex(Num),1};
            IctalSelect = cat(3,IctalSelect,TempIctal);
        end
        [NumChan,NumPoint,NumTrial] = size(IctalSelect);
        if NumTrial <= ThresholdNum(1)
            TempRatio = Ratio(1);
        elseif (NumTrial > ThresholdNum(1)) & (NumTrial <= ThresholdNum(2))
            TempRatio = Ratio(2);
        elseif (NumTrial > ThresholdNum(2)) & (NumTrial <= ThresholdNum(3))
            TempRatio = Ratio(3);
        elseif (NumTrial > ThresholdNum(3)) & (NumTrial <= ThresholdNum(4))
            TempRatio = Ratio(4);
        elseif (NumTrial > ThresholdNum(4)) & (NumTrial <= ThresholdNum(5))
            TempRatio = Ratio(5);
        elseif (NumTrial > ThresholdNum(5)) & (NumTrial <= ThresholdNum(6))
            TempRatio = Ratio(6);
        else
            TempRatio = Ratio(7);
        end

        IctalConnect = [];
        for N = 1:size(IctalSelect,3)
            Temp = squeeze(IctalSelect(:,:,N));
            IctalConnect = [IctalConnect,Temp];
            Temp = [];
        end
        % IctalConnect = reshape(IctalSelect,[NumChan,NumPoint*NumTrial]);
        [NumChan,NumPoint] = size(IctalConnect);
        OverlapPoint = floor(Window*(1-TempRatio));
        NumSamp = floor((NumPoint-Window)/OverlapPoint)+1;
        for SampNum = 1:NumSamp
            Lstart = (SampNum-1)*OverlapPoint+1;
            Lend = (SampNum-1)*OverlapPoint+Window;
            TempSeizureSamp(:,:,SampNum) = IctalConnect(:,Lstart:Lend);
        end

        IctalNoise = [];
        for SnrIndex = 1:length(Snr)
            IctalNoise = awgn(IctalConnect,Snr(SnrIndex),'measured');
            SampNoise = [];
            for SampNum = 1:NumSamp
                Lstart = (SampNum-1)*OverlapPoint+1;
                Lend = (SampNum-1)*OverlapPoint+Window;
                SampNoise(:,:,SampNum) = IctalNoise(:,Lstart:Lend);
            end
            TempSeizureSamp = cat(3,TempSeizureSamp,SampNoise);
        end
        SeizureSamp{SeizureNum,1} = TempSeizureSamp;
        SeizureSamp{SeizureNum,2} = Ictal{SeizureNum,1};
        TempSeizureSamp = [];
    end

    %%%% for training and testing
    TempIndex = [];
    for SeizureNum = 1:NumSeizure
        IctalTesting = SeizureSamp{SeizureNum,2};
        IctalTraining = SeizureSamp{SeizureNum,1};
        Interval = size(IctalTraining,3)/(NumSeizure-1);
        IntervalUp = floor(1.2*Interval); %%%%%%%%%%%%%%%%%%%

        TempIndex = Index;
        TempIndex(SeizureNum) = [];
        InterictalTesting = InterictalSamp{SeizureNum,1};
        InterictalTraining = [];
        for Num = 1:length(TempIndex)
            TempInterictal = InterictalSamp{TempIndex(Num),1};
            TempInterictalIndex = randperm(size(TempInterictal,3),IntervalUp);
            TempInterictalTraining = TempInterictal(:,:,TempInterictalIndex);
            TempInterictalIndex = [];
            InterictalTraining = cat(3,InterictalTraining,TempInterictalTraining);
            TempInterictalTraining = [];
        end

        InterictalTrainingLabel = zeros(1,size(InterictalTraining,3));
        IctalTrainingLabel = zeros(1,size(IctalTraining,3))+1;
        TempTraining = [];
        TempTraining = cat(3,InterictalTraining,IctalTraining);
        TempTrainingLabel = [];
        TempTrainingLabel = [InterictalTrainingLabel,IctalTrainingLabel];
        TrainingIndex = randperm(length(TempTrainingLabel));
        Training = TempTraining(:,:,TrainingIndex);
        TrainingLabel = TempTrainingLabel(TrainingIndex);
        TrainingIndex = [];

        InterictalTestingLabel = zeros(1,size(InterictalTesting,3));
        IctalTestingLabel = zeros(1,size(IctalTesting,3))+1;
        Testing = cat(3,InterictalTesting,IctalTesting);
        TestingLabel = [InterictalTestingLabel,IctalTestingLabel];

        TrainTest{1,1} = Training;
        TrainTest{1,2} = TrainingLabel';
        TrainTest{1,3} = Testing;
        TrainTest{1,4} = TestingLabel';
        NumTrainTest(SeizureNum,1) = length(TrainingLabel);
        NumTrainTest(SeizureNum,2) = length(TestingLabel);
        clear Training TrainingLabel Testing TestingLabel

        if SubNum < 10
            NewRoute = strcat(NewPath,'Pat_',int2str(0),int2str(SubNum),filesep);
            mkdir(NewRoute)
        else
            NewRoute = strcat(NewPath,'Pat_',int2str(SubNum),filesep);
            mkdir(NewRoute)
        end
        save([NewRoute,'Seizure',int2str(SeizureNum)],'TrainTest')
        clear TrainTest
    end
    TrainTestSize{SubNum,1} = NumTrainTest;
    NumTrainTest = [];
end
save([NewPath,'TrainTestSize'],'TrainTestSize')

%%
toc