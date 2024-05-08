clc
clear
close all
tic

%%
Path = ['Labels_Prediction\01_Freiburg_Epileptic_Prediction\Labels_Prediction\'];
File = dir(fullfile(Path,'*.mat'));
MatName = {File.name}';
NumMat = length(MatName);
for MatNum = 1:NumMat
    Route = strcat(Path,MatName{MatNum,1});
    MatLabel = load(Route);
    MatLabel = struct2cell(MatLabel);
    MatLabel = cell2mat(MatLabel);
    [NumLabel,NumSeizure,NumRun,NumChanType] = size(MatLabel);

    RawLabel = MatLabel(:,1,1,NumChanType);
    Index1 = [];
    Index0 = [];
    Index1 = find(RawLabel == 1);
    Index0 = find(RawLabel == 0);
    for ChanTypeNum = 1:(NumChanType-1)
        for RunNum = 1:NumRun
            for SeizureNum = 1:NumSeizure
                TempLabel = MatLabel(:,SeizureNum,RunNum,ChanTypeNum);
                TP = sum(TempLabel(Index1));
                FN = length(Index1)-TP;
                FP = sum(TempLabel(Index0));
                TN = length(Index0)-FP;

                %%%% F1
                Precison = TP/(TP+FP);
                Recall = TP/(TP+FN);
                F1 = 2*Precison*Recall/(Precison+Recall);
                TF = isnan(F1);
                if TF == 1
                    F1 = 0;
                end

                %%%% F2
                F2 = (1+2*2)*Precison*Recall/(2*2*Precison+Recall);
                TF = isnan(F2);
                if TF == 1
                    F2 = 0;
                end

                %%%% Acc
                Acc = (TP+TN)/(TP+FN+FP+TN);

                Temp_F1Acc(1,SeizureNum,RunNum,ChanTypeNum) = F1;
                Temp_F1Acc(2,SeizureNum,RunNum,ChanTypeNum) = F2;
                Temp_F1Acc(3,SeizureNum,RunNum,ChanTypeNum) = Acc;

            end
        end
    end
    F1Acc{MatNum,1} = Temp_F1Acc;
    clear Temp_F1Acc MatLabel
end
save('m2_F1Acc','F1Acc')

%%
toc