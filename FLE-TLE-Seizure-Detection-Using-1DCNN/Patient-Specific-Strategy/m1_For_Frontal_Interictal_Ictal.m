clc
clear
close all
tic

%%
FileName = 'm0_Frontal';

FrontalSubIndex = {[1],[2],[3],[4],[5],[6],...
    [7 8],[9],[10 11],[12],[13 14],[15],...
    [16 17],[18],[19],[20 21],[22 23],...
    [24],[25],[26]}'; %%%%%%%%%%%

IctalTime = {[4278 4328; 28283 28339],...  % subject 1
    [26666 26699; 26701 26720],...  % subject 2
    [15978	15994; 16795 16819; 17179 17201; 17460 17497],...  % subject 3
    [5049 5085; 7878 7925; 14182 14213; 17988 18029; 19687 19732],...  % subject 4
    [9825 9874; 26800 26841; 27786 27821],...  % subject 5
    [11502 11534; 12308 12330; 12503 12523; 12846 12863; 13008 13020; 13225 13242],...  % subject 6
    [6033 6076], [17728 17771],...  % subject 7   2-files
    [14398 14413; 24716 24728],...  % subject 8
    [11728 11771], [4687 4739],...  % subject 9   2-files
    [14046 14058; 22226 22239],...  % subject 10
    [20691 20781], [26509 26615],... % subject 11   2-files
    [14723 14747; 27919 27939; 28452 28470],... % subject 12
    [7228 7278], [20682 20736],... % subject 13   2-files
    [16077 16098; 18705 18733],... % subject 14
    [3516 3528; 5504 5514],... % subject 15
    [1261 1323], [2810	2865]... % subject 16   2-files
    [26146 26373], [21552 21664]... % subject 17   2-files
    [4385 4415; 15589 15624],... % subject 18
    [16801 16882; 24793 24872],... % subject 19
    [4668 4718; 13784 13826]}'; % subject 20

NumSub = length(FrontalSubIndex);
Path = [FileName,filesep];
Mat = dir(fullfile(Path,'*.mat'));
MatName = {Mat.name}';

%%
NewPath = ['m1_','Frontal_Interictal_Ictal',filesep];
mkdir(NewPath)
for SubNum = 1:NumSub
    TempIndex = [];
    TempIndex = FrontalSubIndex{SubNum,1};

    NumSubMat = length(TempIndex);
    for N = 1:length(TempIndex)
        Route = strcat(Path,MatName{TempIndex(N),1});
        Temp = load(Route);
        Data = Temp.X;
        fs = Temp.fs;
        ChanSelect = Temp.ChanSelect;
        ChanIndex = Temp.ChanIndex;
        Temp = [];

        StartEnd = [];
        StartEnd = IctalTime{TempIndex(N),1};
        [NumRow,NumColumn] = size(StartEnd);
        TempIctalIndex = [];
        for RowNum = 1:NumRow
            StartTime = StartEnd(RowNum,1);
            EndTime = StartEnd(RowNum,2);
            Dv = EndTime-StartTime;
            if mod(Dv,2)==0
                Lstart = StartTime*fs+1;
                Lend = EndTime*fs;
            else
                EndTime = EndTime+1;
                Lstart = StartTime*fs+1;
                Lend = EndTime*fs;
            end

            TempIctal = [];
            TempIctal = Data(:,Lstart:Lend);
            Ictal{(N-1)*NumRow+RowNum,1} = TempIctal;
            TempIctalIndex = [TempIctalIndex,Lstart:Lend];
        end

        TempInterictal = [];
        TempInterictal = Data;
        TempInterictal(:,TempIctalIndex) = [];
        Interictal{N,1} = TempInterictal;
    end
    if SubNum < 10
        NewRoute = strcat([NewPath,int2str(0),int2str(SubNum),'_subject','.mat']);
    else
        NewRoute = strcat([NewPath,int2str(SubNum),'_subject','.mat']);
    end
    save(NewRoute,'Interictal','Ictal','fs','ChanSelect','ChanIndex')
    Ictal = [];
    Interictal = [];
end

%%
toc