clc
clear
close all
tic

%%
% DatasetType = {['01_Freiburg_Epileptic_Prediction',filesep];...
%     ['02_SWEC_ETHZ_iEEG_Epilepsy_LongTerm',filesep];...
%     ['03_America_Society_Seizure_Prediction',filesep]};
DatasetType = {['01_Freiburg_Epileptic_Prediction',filesep]};
LabelFile = ['Labels_Prediction',filesep];
NumDataset = length(DatasetType);

for DatasetNum = 1:NumDataset
    Route = strcat(DatasetType{DatasetNum,1},LabelFile);
    File = dir(fullfile(Route,'*.mat'));
    LabelMatName = {File.name}';
    NumLabelMat = length(LabelMatName);

    for LabelMatNum = 1:NumLabelMat
        Path = strcat(Route,LabelMatName{LabelMatNum,1});
        Label = load(Path);
        Label = struct2cell(Label);
        Label = cell2mat(Label);
        [NumSamp,NumSeizure,NumRun,NumChanType] = size(Label);

        ChanVotingLabel = [];
        TrueLabel = [];
        ChanVotingLabel = mean(Label(:,:,:,[1:NumChanType-2]),4);
        ChanVotingLabel = roundn(ChanVotingLabel,0);
        TrueLabel = Label(:,:,:,NumChanType);

        ChanVotingScores = [];
        ChanVotingTrueLabel = [];
        for SeizureNum = 1:NumSeizure
            for RunNum = 1:NumRun
                ChanVotingScores = [ChanVotingScores;squeeze(ChanVotingLabel(:,SeizureNum,RunNum))];
                ChanVotingTrueLabel = [ChanVotingTrueLabel;squeeze(TrueLabel(:,SeizureNum,RunNum))];
            end
        end

        [falsePosRate,truePosRate,T,auc] = perfcurve(ChanVotingTrueLabel,ChanVotingScores,1);
        % 计算AUC的95%置信区间
        n = sum(ChanVotingTrueLabel == 1);  % 正样本数量
        p = sum(ChanVotingTrueLabel == 0);  % 负样本数量

        z = 1.96;  % 95%置信区间的z值

        Q1 = auc/(2-auc);
        Q2 = 2*auc^2/(1+auc);

        SE_AUC = sqrt((auc*(1 - auc)+(n - 1)*(Q1-auc^2)+(p - 1)*(Q2-auc^2))/(n * p));

        lower_bound = auc-z*SE_AUC;
        upper_bound = auc+z*SE_AUC;
        TempAUC(LabelMatNum,:) = [auc,lower_bound,upper_bound];

    end
    AUCMean = mean(TempAUC,1);
    TempAUC = [TempAUC;AUCMean];
    TempAUC = roundn(TempAUC,-4);
    TempAUC = 100*TempAUC;
    AUROC_ChanVoting{DatasetNum,1} = TempAUC;
    TempAUC = [];
end
save('m2_AUROC_ChanVoting','AUROC_ChanVoting')

%%
toc