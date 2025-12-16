clc
clear
close all
tic

%%
Path = {'..\02_DataSelectedProcessing\m1_Frontal_Interictal_Ictal\';...
    '..\02_DataSelectedProcessing\m1_Temporal_Interictal_Ictal\'};
Remove = {[6,11,16];[2,4,9]};

FrontalTemporalIctal = [];
for IctalTypeNum = 1:length(Path)
    Mat = dir(fullfile(Path{IctalTypeNum,1},'*.mat'));
    MatName = {Mat.name}';
    MatName(Remove{IctalTypeNum,1}) = [];
    NumMat = length(MatName);
    
    for MatNum = 1:NumMat
        Route = strcat(Path{IctalTypeNum,1},MatName{MatNum,1});
        load(Route)
        FrontalTemporalIctal{MatNum,IctalTypeNum} = Ictal;
    end
end
save('m3_FrontalTemporalIctal','FrontalTemporalIctal')

%%
toc