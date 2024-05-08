clc
clear
close all
tic

%%
FileName = {['01_Freiburg_Epileptic_Prediction',filesep]};
NumFile = length(FileName);

for FileNum = 1:NumFile
    Path = strcat(FileName{FileNum,1});
    Mat = dir(fullfile(Path, '*.mat'));
    MatName = {Mat.name}';
    NumMat = length(MatName);
    for MatNum = 1:NumMat
        Route = strcat(Path,MatName{MatNum,1});
        Label = load(Route);
        Label = struct2cell(Label);
        Label = cell2mat(Label);
        [NumSamp,NumSeizure,NumRun,NumChanType] = size(Label);

        TrueLabel = Label(:,:,:,NumChanType);
        LabelSelect = [];
        for ChanTypeNum = 1:NumChanType-1
            LabelSelect = Label(:,:,:,ChanTypeNum);
            ChanSelctScores = [];
            ChanTrueLabel = [];
            for SeizureNum = 1:NumSeizure
                for RunNum = 1:NumRun
                    ChanSelctScores = [ChanSelctScores;squeeze(LabelSelect(:,SeizureNum,RunNum))];
                    ChanTrueLabel = [ChanTrueLabel;squeeze(TrueLabel(:,SeizureNum,RunNum))];
                end
            end

            [falsePosRate,truePosRate, T, auc] = perfcurve(ChanTrueLabel,ChanSelctScores,1);
            % 计算AUC的95%置信区间
            n = sum(ChanTrueLabel == 1);  % 正样本数量
            p = sum(ChanTrueLabel == 0);  % 负样本数量
            z = 1.96;  % 95%置信区间的z值
            Q1 = auc/(2-auc);
            Q2 = 2*auc^2/(1+auc);
            SE_AUC = sqrt((auc*(1 - auc)+(n - 1)*(Q1-auc^2)+(p-1)*(Q2-auc^2))/(n*p));
            lower_bound = auc-z*SE_AUC;
            upper_bound = auc+z*SE_AUC;
            TempAUC(ChanTypeNum,:) = [auc,lower_bound,upper_bound];
        end
        TempAUC = roundn(TempAUC,-4);
        TempAUC = 100*TempAUC;
        TmpAUC{MatNum,1} = TempAUC;
        TempAUC = [];
    end
    AUROC_ChanSort{FileNum,1} = TmpAUC;
    TmpAUC = [];
end
save('m5_AUC_ChanSort','AUROC_ChanSort')

%%
toc