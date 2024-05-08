clc
clear
close all
tic

%% For the calculation of segment- and event-based levels
% InterictalHours = {[24 24 24 24 24 24.5 24 24 24 24 24 24 24 24.5 25.5 24];
%     [24 24 24 24 24 24 24 24 24];
%     [24 24 24 24 24]};
InterictalHours = {[24]};

SenSpeAcc_SenFpr = load('m0_SSA_SF_AllChannel.mat');
SenSpeAcc_SenFpr = struct2cell(SenSpeAcc_SenFpr);
SenSpeAcc_SenFpr = SenSpeAcc_SenFpr{1,1};
[NumWindowType,NumDataset] = size(SenSpeAcc_SenFpr);

for WindowTypeNum = 1:NumWindowType
    for DatasetNum = 1:NumDataset
        TempInterictal = [];
        TempInterictal = InterictalHours{DatasetNum,1};
        Data = [];
        Data = SenSpeAcc_SenFpr{WindowTypeNum,DatasetNum};
        [NumPatient,NumMetricType] = size(Data);

        for PatientNum = 1:NumPatient
            SenSpeAcc_SenFpr_Mean = [];
            for MetricTypeNum = 1:NumMetricType
                TempData = [];
                TempData = Data{PatientNum,MetricTypeNum};
                [NumMetric,NumSeizure,NumRun] = size(TempData);

                if mod(MetricTypeNum,2) == 0
                    for RunNum = 1:NumRun
                        Temp = [];
                        Temp = TempData(:,:,RunNum);
                        TempSenMean = mean(Temp(1,:),2);
                        TempSenMean = roundn(TempSenMean,-4);
                        NumAlarm = sum(Temp(2,:));
                        TempFpr = NumAlarm/(TempInterictal(PatientNum)*100);
                        TempSenFpr(1,RunNum) = TempSenMean;
                        TempSenFpr(2,RunNum) = TempFpr;
                    end
                    SenSpeAcc_SenFpr_Mean = [SenSpeAcc_SenFpr_Mean;TempSenSpeAcc;TempSenFpr];
                else
                    for RunNum = 1:NumRun
                        Temp = [];
                        Temp = TempData(:,:,RunNum);
                        TempMean = mean(Temp,2);
                        TempMean = roundn(TempMean,-4);
                        TempSenSpeAcc(:,RunNum) = TempMean;
                    end
                end
            end
            clear TempSenSpeAcc TempSenFpr
            TempRunMean = mean(SenSpeAcc_SenFpr_Mean,2);
            TempRunMean = roundn(TempRunMean,-4);
            TempRunMean = TempRunMean*100;
            TempRunStd = std(SenSpeAcc_SenFpr_Mean,1,2);
            TempRunStd = roundn(TempRunStd,-4);
            TempRunStd = TempRunStd*100;
            TempRunMeanStd = [TempRunMean,TempRunStd];
            TempRunMeanStd(1:end-1,:) = roundn(TempRunMeanStd(1:end-1,:),-1);
            clear TempRunMean TempRunStd
            [Row,Column] = size(TempRunMeanStd);
            TempRunMeanStdNew = reshape(TempRunMeanStd',1,Column*Row);
            RunMeanStd(PatientNum,:) = TempRunMeanStdNew;
            clear TempRunMeanStdNew
        end
        MeanStd_AllChannel{WindowTypeNum,DatasetNum} = RunMeanStd;
        clear RunMeanStd
    end
end
save('m1_MeanStd_AllChan','MeanStd_AllChannel')

%% The results of all channels are plotted
[NumWindowType,NumDataset] = size(MeanStd_AllChannel);
for WindowTypeNum = 1%:NumWindowType
    for DatasetNum = 1%:NumDataset
        Data = [];
        Data = MeanStd_AllChannel{WindowTypeNum,DatasetNum};
        [NumPatient,NumMetric] = size(Data);


    end
end

%%
toc
