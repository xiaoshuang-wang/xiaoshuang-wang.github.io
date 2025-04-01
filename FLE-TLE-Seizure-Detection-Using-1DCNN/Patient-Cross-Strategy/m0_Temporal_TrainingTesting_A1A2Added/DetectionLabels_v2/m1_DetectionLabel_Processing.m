clc
clear
close all
tic

%%
targetDir = ['..',filesep,'DetectionLabels_v2',filesep];
contents = dir(targetDir);
FolderNames = {};
for i = 1:length(contents)
    if contents(i).isdir && ~strcmp(contents(i).name,'.') && ~strcmp(contents(i).name,'..')
        FolderNames{end+1,1} = contents(i).name;
    end
end
NumFolder = length(FolderNames(1:4));

%%
IctalSegmentNum = load('m_TemporalIctalSegmentNum.mat'); %%%%%%%%%%%%%%%%
IctalSegmentNum = struct2cell(IctalSegmentNum);
IctalSegmentNum = IctalSegmentNum{1,1};

for FolderNum = 1:NumFolder
    Path = [FolderNames{FolderNum,1},filesep];
    Pat = dir(fullfile(Path,'*.mat'));
    PatName = {Pat.name}';
    NumPatient = length(PatName);
    for PatientNum = 1:NumPatient
        Route = strcat(Path,PatName{PatientNum,1});
        Labels = load(Route);
        Labels = struct2cell(Labels);
        Labels = Labels{1,1};

        TrueLabels = squeeze(Labels(:,end,1));
        Index0 = [];
        Index0 = find(TrueLabels==0);
        Index1 = [];
        Index1 = find(TrueLabels==1);
        [NumSeg,NumType,NumRun] = size(Labels);
        for RunNum = 1:NumRun
            PredLabels = zeros(NumSeg,1);
            Probability = Labels(:,1:2,RunNum);
            Indices = [];
            Indices = find(Probability(:,1) <= Probability(:,2));
            PredLabels(Indices) = 1;

            %%%%%******************** Segment-based level ********************%%%%%
            C = confusionmat(TrueLabels,PredLabels,'Order',[0,1]);
            TN = C(1,1); % 真阴性
            FP = C(1,2); % 假阳性
            FN = C(2,1); % 假阴性
            TP = C(2,2); % 真阳性

            Sen = TP/(TP+FN);
            Spec = TN/(TN+FP);
            Acc = (TP+TN)/sum(C(:));
            [fpr,tpr,~,ROC_AUC] = perfcurve(TrueLabels,PredLabels,1);
            %[X,Y,~,PR_AUC] = perfcurve(TrueLabels,PredLabels,1,'XCrit', 'recall', 'YCrit', 'precision');

            TempSSAAuc(1,RunNum) = Sen;
            TempSSAAuc(2,RunNum) = Spec;
            TempSSAAuc(3,RunNum) = Acc;
            TempSSAAuc(4,RunNum) = ROC_AUC;
            %TempSSAAuc(5,RunNum) = PR_AUC;


            %%%%%******************** Event-based level ********************%%%%%
            %%%%%%%%%% for FDR
            Threshold = 4; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input by hands
            Window = 5; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input by hands
            Interval = 30*20; %%% NumSegInOneMintue*NumOfMinutes %%%%%%% Input by hands
            SegmentTime = 2; %%%% Seconds
            PredLabel0 = [];
            PredLabel0 = PredLabels(Index0);
            FDTimes = 0;
            countPred = 0;
            PredFlag = 0;
            for SegNum = Window:length(Index0)
                Pstart = SegNum-Window+1;
                Pend = SegNum;

                if PredFlag == 0
                    ThresholdPred = sum(PredLabel0(Pstart:Pend));
                else
                    ThresholdPred = 0;
                end

                if ThresholdPred >= Threshold
                    PredFlag = 1;
                    FDTimes = FDTimes+1;
                else
                    if PredFlag == 1
                        countPred = countPred+1;
                        if countPred >= Interval
                            PredFlag = 0;
                            countPred = 0;
                        end
                    end
                end
            end

            %%%%%%%%%% for Event-based sensitivity
            Seizures = [];
            Seizures = IctalSegmentNum{PatientNum,1};
            NumSeizure = length(Seizures);
            PredLabel1 = [];
            PredLabel1 = PredLabels(Index1);

            for SeizureNum = 1:NumSeizure
                if SeizureNum == 1
                    Lstart = 1;
                    Lend = sum(Seizures(1:SeizureNum));
                else
                    Lstart = sum(Seizures(1:SeizureNum-1))+1;
                    if SeizureNum == NumSeizure
                        Lend = sum(Seizures(1:SeizureNum))-1;
                    else
                        Lend = sum(Seizures(1:SeizureNum));
                    end
                end

                PredLabel1Select = [];
                PredLabel1Select = PredLabel1(Lstart:Lend);
                countPred = 0;
                Latency = 0;
                for SegNum = Window:length(PredLabel1Select)
                    Pstart = SegNum-Window+1;
                    Pend = SegNum;
                    ThresholdPred = sum(PredLabel1Select(Pstart:Pend));
                    if ThresholdPred >= Threshold
                        countPred = countPred+1;
                        if countPred == 1
                            Latency = Pend*SegmentTime;
                        end
                    end
                end

                if countPred > 0
                    EventSen = 1;
                else
                    EventSen = 0;
                end
                TempSFdLa(1,SeizureNum,RunNum) = EventSen;
                TempSFdLa(2,SeizureNum,RunNum) = FDTimes;
                TempSFdLa(3,SeizureNum,RunNum) = Latency;
            end
        end
        SSAAuc{PatientNum,FolderNum} = TempSSAAuc;
        TempSSAAuc = [];
        SFdLa{PatientNum,FolderNum} = TempSFdLa;
        TempSFdLa = [];
    end
end
save('m1_SSAAuc','SSAAuc')
save('m1_SFdLa','SFdLa')

%%
toc