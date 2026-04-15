clc
clear
close all
tic

%% for preictal and ictal data
FolderPath = strcat('Ictal',filesep); %%%%
DirOutput = dir(fullfile(FolderPath,'*.mat'));
FileNames = {DirOutput.name}';
NumFile = length(FileNames);
for FileNum = 1:NumFile
    Route = strcat(FolderPath, FileNames{FileNum,1});
    Temp = load(Route);
    Temp = struct2cell(Temp);
    Temp = cell2mat(Temp);
    Temp = double(Temp);
    Preictal_Ictal{FileNum,1} = Temp;
    clear Temp
end

%%%%%%%%%%%%%%%%%%%
%%% For preictal and ictal data, respectively
fs = 512;
StartEndSample = [3168.987472, 3229.532371;
    1462.983672, 1531.217704;
    1332.963581, 1394.598279;
    2977.453773, 3045.687805]*fs;
StartEndSample = floor(StartEndSample);
NumSeizure = 4;

% preictal_1 and seizure_1
Temp_pre_1 = Preictal_Ictal{1,1};
Temp_pre_2 = Preictal_Ictal{2,1};
Temp_pre_3 = Preictal_Ictal{3,1}(:,1:StartEndSample(1,1));
Preictal_1 = [Temp_pre_1,Temp_pre_2,Temp_pre_3]; %%%%

Temp_ictal = Preictal_Ictal{3,1}(:,StartEndSample(1,1):StartEndSample(1,2));
Seizure_1 = Temp_ictal; %%%%
clear Temp_pre_1 Temp_pre_2 Temp_pre_3 Temp_ictal %%%%

% preictal_2 and seizure_2
Temp_pre_1 = Preictal_Ictal{4,1};
Temp_pre_2 = Preictal_Ictal{5,1};
Temp_pre_3 = Preictal_Ictal{6,1}(:,1:StartEndSample(2,1));
Preictal_2 = [Temp_pre_1,Temp_pre_2,Temp_pre_3]; %%%%

Temp_ictal = Preictal_Ictal{6,1}(:,StartEndSample(2,1):StartEndSample(2,2));
Seizure_2 = Temp_ictal; %%%%
clear Temp_pre_1 Temp_pre_2 Temp_pre_3 Temp_ictal %%%%

% preictal_3 and seizure_3
Temp_pre_0 = Preictal_Ictal{6,1}(:,StartEndSample(2,2):end);
Temp_pre_1 = Preictal_Ictal{7,1};
Temp_pre_2 = Preictal_Ictal{8,1};
Temp_pre_3 = Preictal_Ictal{9,1}(:,1:StartEndSample(3,1));
Preictal_3 = [Temp_pre_0,Temp_pre_1,Temp_pre_2,Temp_pre_3]; %%%%

Temp_ictal = Preictal_Ictal{9,1}(:,StartEndSample(3,1):StartEndSample(3,2));
Seizure_3 = Temp_ictal; %%%%
clear Temp_pre_0 Temp_pre_1 Temp_pre_2 Temp_pre_3 Temp_ictal %%%%

% preictal_4 and seizure_4
Temp_pre_1 = Preictal_Ictal{9,1}(:,StartEndSample(3,2):end);
Temp_pre_2 = Preictal_Ictal{10,1}(:,1:StartEndSample(4,1));
Preictal_4 = [Temp_pre_1,Temp_pre_2]; %%%%

Temp_ictal = Preictal_Ictal{10,1}(:,StartEndSample(4,1):StartEndSample(4,2));
Seizure_4 = Temp_ictal; %%%%
clear Temp_pre_1 Temp_pre_2 Temp_ictal %%%%

PreictalSeizure(1).preictal = Preictal_1;
PreictalSeizure(2).preictal = Preictal_2;
PreictalSeizure(3).preictal = Preictal_3;
PreictalSeizure(4).preictal = Preictal_4;
PreictalSeizure(1).seizure = Seizure_1;
PreictalSeizure(2).seizure = Seizure_2;
PreictalSeizure(3).seizure = Seizure_3;
PreictalSeizure(4).seizure = Seizure_4;
save('PreictalSeizure','PreictalSeizure')

%%
toc