clc
clear
close all
tic

%%
FrontalTemporalIctal = load('m1_FrontalTemporalIctal.mat');
FrontalTemporalIctal = struct2cell(FrontalTemporalIctal);
FrontalTemporalIctal = FrontalTemporalIctal{1,1};
[NumPatient,NumIctalType] = size(FrontalTemporalIctal);

Overlap = 0.5; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NewPath = strcat('m4_','FrontalTemporal_TypeRecognition',filesep,...
    num2str(Overlap),'Overlap',filesep);
mkdir(NewPath)
fs = 500;
Window = 2*fs;

%%
Index = 1:NumPatient;
for PatientNum = 1:NumPatient
    TempIndex = Index;
    TempIndex(PatientNum) = [];
    for IctalTypeNum = 1:NumIctalType
        for Num = 1:length(TempIndex)
            Ictal = [];
            Ictal = FrontalTemporalIctal{TempIndex(Num),IctalTypeNum};
            NumSeizure = length(Ictal);
            Seizures = [];
            for SeizureNum = 1:NumSeizure
                Seizures = [Seizures,Ictal{SeizureNum,1}];
            end

            [NumChan,NumPoint] = size(Seizures);
            if IctalTypeNum == 1
                Overlap = 0.6; %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Step = 1-Overlap;
                NumIctalSegment = floor((NumPoint-Window)/(Step*Window))+1;
                TempTrainIctal = [];
                for IctalSegmentNum = 1:NumIctalSegment
                    Lstart = (IctalSegmentNum-1)*(Step*Window)+1;
                    Lend = Lstart+Window-1;
                    TempTrainIctal(:,:,IctalSegmentNum) = Seizures(:,Lstart:Lend);
                end
            else
                Overlap = 0.45; %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Step = 1-Overlap;
                NumIctalSegment = floor((NumPoint-Window)/(Step*Window))+1;
                TempTrainIctal = [];
                for IctalSegmentNum = 1:NumIctalSegment
                    Lstart = (IctalSegmentNum-1)*(Step*Window)+1;
                    Lend = Lstart+Window-1;
                    TempTrainIctal(:,:,IctalSegmentNum) = Seizures(:,Lstart:Lend);
                end
            end
            TrainIctal{Num,IctalTypeNum} = TempTrainIctal;
        end
    end

    %%%%%%%%%%%%%********* Training *********%%%%%%%%%%%%%%
    NumSub = length(TrainIctal);
    IctalTraining = [];
    TempTrainingLabel = [];
    for IctalTypeNum = 1:NumIctalType
        for SubNum = 1:NumSub
            IctalTraining = cat(3,IctalTraining,TrainIctal{SubNum,IctalTypeNum});
            NumSegment = size(TrainIctal{SubNum,IctalTypeNum},3);
            IctalTrainingLabel = [];
            IctalTrainingLabel = zeros(1,NumSegment)+(IctalTypeNum-1);
            TempTrainingLabel = [TempTrainingLabel,IctalTrainingLabel];
        end
    end

    Index0 = [];
    Index0 = find(TempTrainingLabel==0);
    Index1 = [];
    Index1 = find(TempTrainingLabel==1);
    NumTrainTest(PatientNum,1) = length(Index0);
    NumTrainTest(PatientNum,2) = length(Index1);

    TrainingIndex = [];
    TrainingIndex = randperm(length(TempTrainingLabel));
    Training = [];
    Training = IctalTraining(:,:,TrainingIndex);
    TrainingLabel = [];
    TrainingLabel = TempTrainingLabel(TrainingIndex);
    TrainTest{1,1} = Training;
    TrainTest{1,2} = TrainingLabel';

    %%%%%%%%%%%%%********* Testing *********%%%%%%%%%%%%%%
    Testing = [];
    TestingLabel = [];
    for IctalTypeNum = 1:NumIctalType
        Ictal = [];
        Ictal = FrontalTemporalIctal{Index(PatientNum),IctalTypeNum};

        NumSeizure = length(Ictal);
        Seizures = [];
        for SeizureNum = 1:NumSeizure
            Seizures = [Seizures,Ictal{SeizureNum,1}];
        end
        [NumChan,NumPoint] = size(Seizures);
        NumIctalSegment = floor(NumPoint/Window);
        TestIctal = [];
        for IctalSegmentNum = 1:NumIctalSegment
            Lstart = (IctalSegmentNum-1)*Window+1;
            Lend = Lstart+Window-1;
            TestIctal(:,:,IctalSegmentNum) = Seizures(:,Lstart:Lend);
        end

        Testing = cat(3,Testing,TestIctal);
        NumSegment = size(TestIctal,3);
        IctalTestingLabel = [];
        IctalTestingLabel = zeros(1,NumSegment)+(IctalTypeNum-1);
        TestingLabel = [TestingLabel,IctalTestingLabel];
    end

    Index0 = [];
    Index0 = find(TestingLabel==0);
    Index1 = [];
    Index1 = find(TestingLabel==1);
    NumTrainTest(PatientNum,3) = length(Index0);
    NumTrainTest(PatientNum,4) = length(Index1);

    TrainTest{1,3} = Testing;
    TrainTest{1,4} = TestingLabel';

    if PatientNum < 10
        save([NewPath,'Pat_',int2str(0),int2str(PatientNum)],'TrainTest')
        clear TrainTest
    else
        save([NewPath,'Pat_',int2str(PatientNum)],'TrainTest')
        clear TrainTest
    end

end
save('m2_NumTrainTest','NumTrainTest')

%%
toc
