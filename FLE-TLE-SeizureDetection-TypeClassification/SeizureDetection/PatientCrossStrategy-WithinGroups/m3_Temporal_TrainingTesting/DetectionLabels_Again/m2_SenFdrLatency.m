clc
clear
close all
tic

%%
IctalSegmentNum = load('..\..\..\m_TemporalIctalSegmentNum.mat');
IctalSegmentNum = struct2cell(IctalSegmentNum);
IctalSegmentNum = IctalSegmentNum{1,1};

BestRun = load('m1_BestRun.mat');
BestRun = struct2cell(BestRun);
BestRun = BestRun{1,1};

FolderNames = dir(); % 获取当前目录列表
FolderNames = FolderNames([FolderNames.isdir]); % 筛选出文件夹
FolderNames = {FolderNames.name}; % 提取文件夹名
FolderNames = setdiff(FolderNames, {'.','..'})'; % 移除特殊目录

Interictal = [16,12.9,16,11.3,10.1,16,8,6.1,8,8,...
    8,8,8,8,15.3,16,16,16,11.9,16]';
Interictal([2,4,9]) = [];

Window = 4; %%%%%%%%%%%%%%%%%%%%%%%
Threshold = 3; %%%%%%%%%%%%%%%%%%%%%%%
IntervalSamp = 60*20/2; %%%%%%%%%%%%%%%%%%% 20-min
SegTime = 2; %%%%%% seconds

NumFolder = length(FolderNames);
for FolderNum = 1:NumFolder
    Path = strcat(FolderNames{FolderNum,1},filesep);
    MatInfo = dir(fullfile(Path,'*.mat'));
    MatName = {MatInfo.name}';
    NumPatient = length(MatName);

    for PatientNum = 1:NumPatient
        BestRunIndex = BestRun(PatientNum,FolderNum);
        MatRoute = strcat(Path,MatName{PatientNum,1});
        Labels = load(MatRoute);
        Labels = struct2cell(Labels);
        Labels = cell2mat(Labels);
        [NumSamp,NumType,NumRun] = size(Labels);

        TrueLabels = Labels(:,NumType,BestRunIndex);
        PredLabels = double(Labels(:,2,BestRunIndex) > Labels(:,1,BestRunIndex));

        %%%%%%%********** For event-based Sensitivity and Latency **********%%%%%%%%
        Index1 = [];
        Index1 = find(TrueLabels==1);
        PredLabel1 = [];
        PredLabel1 = PredLabels(Index1);

        Seizures = [];
        Seizures = IctalSegmentNum{PatientNum,1};
        NumSeizure = length(Seizures);
        EventSen = [];
        LatencyTime = [];
        for SeizureNum = 1:NumSeizure
            if SeizureNum == 1
                Lstart = 1;
                Lend = sum(Seizures(1:SeizureNum));
            else
                Lstart = sum(Seizures(1:SeizureNum-1))+1;
                Lend = sum(Seizures(1:SeizureNum));
            end

            PredLabel1Select = [];
            PredLabel1Select = PredLabel1(Lstart:Lend);
            count = 0;
            for n = Window:length(PredLabel1Select)
                Lstart = n-Window+1;
                Lend = n;
                Value = sum(PredLabel1Select(Lstart:Lend));
                if Value>=Threshold
                    count = count+1;
                end
                if count == 1
                    La = Lend*SegTime;
                end
            end

            if count>0
                EventSen(SeizureNum,1) = 1;
                LatencyTime(SeizureNum,1) = La;
            else
                EventSen(SeizureNum,1) = 0;
                LatencyTime(SeizureNum,1) = NaN;
            end
        end
        Sen = mean(EventSen);
        Latency = mean(LatencyTime,'omitnan');
        TempSenFdrLa(PatientNum,1) = Sen;
        TempSenFdrLa(PatientNum,3) = Latency;

        TempSeizuresCount(PatientNum,1) = sum(EventSen);
        TempSeizuresCount(PatientNum,2) = NumSeizure;


        %%%%%%%********** For event-based FDR **********%%%%%%%%
        Index0 = [];
        Index0 = find(TrueLabels==0);
        PredLabel0 = [];
        PredLabel0 = PredLabels(Index0,1);
        FpNum = 0;
        PredFlag=0;
        countPred = 0;
        for SampNum = Window:length(PredLabel0)
            Lstart = SampNum-Window+1;
            Lend = SampNum;
            ThresholdPred = sum(PredLabel0(Lstart:Lend,1));
            if PredFlag ==0
                if ThresholdPred >= Threshold
                    FpNum = FpNum+1;
                    PredFlag = 1;
                end
            else
                countPred = countPred+1;
                if countPred >= IntervalSamp
                    PredFlag = 0;
                    countPred = 0;
                end
            end
        end

        Fdr = FpNum/Interictal(PatientNum);
        TempSenFdrLa(PatientNum,2) = Fdr;
    end
    
    SenFdrLa{FolderNum,1} = TempSenFdrLa;
    SeizuresCount{FolderNum,1} = TempSeizuresCount;
end
save('m2_SenFdrLa','SenFdrLa')
save('m2_SeizuresCount','SeizuresCount')

%%
toc
