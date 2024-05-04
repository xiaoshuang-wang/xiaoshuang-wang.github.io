clc
clear
close all
tic

%%
F1Acc = load('m3_F1Acc.mat');
F1Acc = struct2cell(F1Acc);
F1Acc = F1Acc{1,1};
NumPatient = length(F1Acc);

for PatientNum = 1:NumPatient
    Temp = F1Acc{PatientNum,1};
    [NumMetricType,NumSeizure,NumRun,NumChanType] = size(Temp);
    F1AccRunMean = squeeze(mean(Temp,3));
    F1AccSeizureMeanRunMean = squeeze(mean(F1AccRunMean,2));
    F1AccSeizureMeanRunMean(:,NumChanType) = [];

    F1Mean = F1AccSeizureMeanRunMean(1,:)';
    [F1_Idx,Idx] = sort(F1Mean,'descend');

    F1_Sort{PatientNum,1} = F1_Idx;
    F1_Sort{PatientNum,2} = Idx;
end
save('m4_F1Sort','F1_Sort')

%%
toc