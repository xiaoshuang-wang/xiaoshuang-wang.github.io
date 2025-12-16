clc
clear
close all
tic

%%
FolderNames = dir(); % 获取当前目录列表
FolderNames = FolderNames([FolderNames.isdir]); % 筛选出文件夹
FolderNames = {FolderNames.name}; % 提取文件夹名
FolderNames = setdiff(FolderNames, {'.','..'})'; % 移除特殊目录
NumChanType = length(FolderNames);

for ChanTypeNum = 1:NumChanType
    SubFolderNames = dir(FolderNames{ChanTypeNum,1}); % 获取当前目录列表
    SubFolderNames = SubFolderNames([SubFolderNames.isdir]); % 筛选出文件夹
    SubFolderNames = {SubFolderNames.name}; % 提取文件夹名
    SubFolderNames = setdiff(SubFolderNames, {'.','..'})'; % 移除特殊目录

    NumIctalType = length(SubFolderNames);
    for IctalTypeNum = 1:NumIctalType
        Path = strcat(FolderNames{ChanTypeNum,1},filesep,SubFolderNames{IctalTypeNum,1},filesep);
        MatInfo = dir(fullfile(Path,'*.mat'));
        MatName = {MatInfo.name}';

        NumPatient = length(MatName);
        for PatientNum = 1:NumPatient
            MatRoute = strcat(Path,MatName{PatientNum,1});
            Labels = load(MatRoute);
            Labels = struct2cell(Labels);
            Labels = cell2mat(Labels);
            [NumSamp,NumType,NumRun] = size(Labels);
            for RunNum = 1:NumRun
                TrueLabels = Labels(:,NumType,RunNum);
                PredLabels = double(Labels(:,2,RunNum) > Labels(:,1,RunNum));
                [cm,order] = confusionmat(TrueLabels,PredLabels,'Order', [0,1]);
                TN = cm(1,1);  % True Negative (实际0类，预测0类)
                FP = cm(1,2);  % False Positive (实际0类，预测1类)
                FN = cm(2,1);  % False Negative (实际1类，预测0类)
                TP = cm(2,2);  % True Positive (实际1类，预测1类)

                Sen = TP/(TP+FN);
                Spec = TN/(TN+FP);
                Acc = (TN+TP)/(TN+FP+FN+TP);
                [X, Y, T, Auc] = perfcurve(TrueLabels,PredLabels,1);
                F1 = 2*TP/(2*TP+FP+FN);

                TmpSSAAF(RunNum,1) = Sen;
                TmpSSAAF(RunNum,2) = Spec;
                TmpSSAAF(RunNum,3) = Acc;
                TmpSSAAF(RunNum,4) = Auc;
                TmpSSAAF(RunNum,5) = F1;
            end
            [sorted_F1,sorted_Index] = sort(TmpSSAAF(:,end),'descend');
            TempSSAAF(PatientNum,:) = TmpSSAAF(sorted_Index(1),:);
            BestRun(PatientNum,ChanTypeNum,IctalTypeNum) = sorted_Index(1);

        end
        SSAAF{ChanTypeNum,IctalTypeNum} = TempSSAAF;
    end
end
save('m1_SSAAF','SSAAF')
save('m1_BestRun','BestRun')

%%
toc
