clc
clear
close all
tic

%%
FileName = {['01',filesep];['02',filesep];['03',filesep]};
LabelFileName = ['Labels_Prediction_After_Sort',filesep];
NumFile = length(FileName);

for FileNum = 1:NumFile
    Path = strcat(FileName{FileNum,1},LabelFileName);
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

            Index0 = [];
            Index1 = [];
            Index0 = find(ChanTrueLabel==0);
            Index1 = find(ChanTrueLabel==1);
            TP = sum(ChanSelctScores(Index1));
            FN = length(Index1)-TP;
            FP = sum(ChanSelctScores(Index0));
            TN = length(Index0)-FP;

            precision = TP/(TP+FP);
            recall = TP/ (TP+FN);
            F1_Score = 2*(precision*recall)/(precision+recall);

            % 计算AUC的95%置信区间
            n = sum(ChanTrueLabel == 1);  % 正样本数量
            p = sum(ChanTrueLabel == 0);  % 负样本数量

            z = 1.96;  % 95%置信区间的z值

            Q1 = F1_Score/(2-F1_Score);
            Q2 = 2*F1_Score^2/(1+F1_Score);

            SE_F1 = sqrt((F1_Score*(1-F1_Score)+(n-1)*(Q1-F1_Score^2)+(p-1)*(Q2-F1_Score^2))/(n*p));

            lower_bound = F1_Score-z*SE_F1;
            upper_bound = F1_Score+z*SE_F1;
            TempF1(ChanTypeNum,:) = [F1_Score,lower_bound,upper_bound];

        end
        TempF1 = roundn(TempF1,-4);
        TempF1 = 100*TempF1;
        TmpF1{MatNum,1} = TempF1;
        TempF1 = [];
    end
    F1{FileNum,1} = TmpF1;
    TmpF1 = [];
end
save('m6_F1_ChanSort','F1')

%%
toc