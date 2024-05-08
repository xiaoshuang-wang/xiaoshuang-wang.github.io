clc
clear
close all
tic

%%
InterictalHours = [24];

SSA_SF = load('m0_SSA_SF_ChanSort.mat');
SSA_SF = struct2cell(SSA_SF);
SSA_SF = SSA_SF{1,1};
NumWindowType = length(SSA_SF);

for WindowTypeNum = 1:NumWindowType
    Data = [];
    Data = SSA_SF{WindowTypeNum,1};
    [NumPatient,NumMetricType] = size(Data);
    for PatientNum = 1:NumPatient
        SegmentData = [];
        EventData = [];
        SegmentData = Data{PatientNum,1};
        [NumSegmentMetric,NumSeizure,NumRun,NumChanType] = size(SegmentData);
        EventData = Data{PatientNum,2};
        NumEventMetric = size(EventData,1);

        TempSenSpeAccFpr = [];
        TempSenFpr = [];
        for ChanTypeNum = 1:NumChanType
            for RunNum = 1:NumRun
                TempSeg = [];
                TempSeg = SegmentData(:,:,RunNum,ChanTypeNum);
                TempMean = mean(TempSeg,2);
                TempMean = roundn(TempMean,-4);
                TempSenSpeAccFpr(:,RunNum,ChanTypeNum) = TempMean;

                TempEvent = [];
                TempEvent = EventData(:,:,RunNum,ChanTypeNum);
                TempSenMean = mean(TempEvent(1,:),2);
                TempSenMean = roundn(TempSenMean,-4);
                NumAlarm = sum(TempEvent(2,:));
                TempFpr = NumAlarm/(InterictalHours(PatientNum)*100);
                TempSenFpr(1,RunNum,ChanTypeNum) = TempSenMean;
                TempSenFpr(2,RunNum,ChanTypeNum) = TempFpr;
            end
        end

        for ChanTypeNum = 1:NumChanType
            TempSSAF = [];
            TempSF = [];
            TempSSAF = TempSenSpeAccFpr(:,:,ChanTypeNum);
            TempSF = TempSenFpr(:,:,ChanTypeNum);

            SSAFRunMean = [];
            SSAFRunStd = [];
            SSAFRunMean = mean(TempSSAF,2);
            SSAFRunMean = roundn(SSAFRunMean,-3);
            SSAFRunMean = SSAFRunMean*100;
            SSAFRunStd = std(TempSSAF,1,2);
            SSAFRunStd = roundn(SSAFRunStd,-3);
            SSAFRunStd = SSAFRunStd*100;
            SSAFRunMeanStd = [SSAFRunMean,SSAFRunStd];

            SFRunMean = [];
            SFRunStd = [];
            SFRunMean = mean(TempSF,2);
            SFRunMean = roundn(SFRunMean,-4);
            SFRunMean = SFRunMean*100;
            SFRunStd = std(TempSF,1,2);
            SFRunStd = roundn(SFRunStd,-4);
            SFRunStd = SFRunStd*100;
            SFRunMeanStd = [SFRunMean,SFRunStd];
            SFRunMeanStd(1,:) = roundn(SFRunMeanStd(1,:),-1);

            RunMeanStd = [SSAFRunMeanStd;SFRunMeanStd];
            [Row,Column] = size(RunMeanStd);
            TempRunMeanStdNew = reshape(RunMeanStd',1,Column*Row);
            RunMeanStdNew(ChanTypeNum,:) = TempRunMeanStdNew;
            clear RunMeanStd
        end
        MeanStd{WindowTypeNum,PatientNum} = RunMeanStdNew;
        clear RunMeanStdNew
    end
end
save('m1_SSA_SF_MeanStd','MeanStd')

%%
toc