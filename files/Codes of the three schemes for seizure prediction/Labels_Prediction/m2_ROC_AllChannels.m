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

        AllChanLabel = [];
        TrueLabel = [];
        AllChanLabel = Label(:,:,:,NumChanType-1);
        TrueLabel = Label(:,:,:,NumChanType);
        AllChanScores = [];
        AllChanTrueLabel = [];
        for SeizureNum = 1:NumSeizure
            for RunNum = 1:NumRun
                AllChanScores = [AllChanScores;squeeze(AllChanLabel(:,SeizureNum,RunNum))];
                AllChanTrueLabel = [AllChanTrueLabel;squeeze(TrueLabel(:,SeizureNum,RunNum))];
            end
        end

        [falsePosRate,truePosRate, T, auc] = perfcurve(AllChanTrueLabel,AllChanScores,1);
        % 计算AUC的95%置信区间
        n = sum(AllChanTrueLabel == 1);  % 正样本数量
        p = sum(AllChanTrueLabel == 0);  % 负样本数量

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
    AUROC_AllChannels{DatasetNum,1} = TempAUC;
    TempAUC = [];
end
save('m2_AUROC_AllChannels','AUROC_AllChannels')

%%
toc

% % 自助法（bootstrap）计算AUROC
% n_bootstrap = 1000;  % 自助采样次数
% auroc_bootstrap = zeros(n_bootstrap, 1);
% idx = [];
% for i = 1:n_bootstrap
%     % 通过自助采样获取新的预测分数和真实标签
%     idx = randi(length(predicted_scores), length(predicted_scores), 1);
%     bootstrap_predicted_scores = predicted_scores(idx);
%     bootstrap_true_labels = true_labels(idx);
%     % 计算ROC曲线
%     [fpr, tpr, ~] = perfcurve(bootstrap_true_labels,bootstrap_predicted_scores,1);
%     % 计算AUROC
%     auroc_bootstrap(i) = trapz(fpr, tpr);
% end
% % 计算95%置信区间
% alpha = 0.05;
% lower_bound = prctile(auroc_bootstrap,100*alpha / 2);
% upper_bound = prctile(auroc_bootstrap,100*(1-alpha/2));
%
% TempAUC(LabelMatNum,:) = [auc,lower_bound,upper_bound];