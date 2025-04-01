clc
clear
close all
tic

%%
FileName = 'm0_Temporal';

FrontalSubIndex = {[1 2],[3 4],[5 6],[7 8],[9 10],[11 12],...
    [13],[14],[15],[16],[17],[18],[19],[20],...
    [21 22],[23 24],[25 26],[27 28],[29 30],[31 32]}'; %%%%%%%%%%%

IctalTime = {[23788 23861], [21157 21245],... % subject 1   2-files
    [11536 11604], [12440 12504],... % subject 2   2-files
    [27806 27854], [24881 24917],... % subject 3   2-files
    [8490 8598], [15121 15197],... % subject 4   2-files
    [5452 5558], [15886 16004],... % subject 5   2-files
    [4953 5007], [477 533],... % subject 6   2-files
    [4956 5014; 6494 6581; 11351 11387; 11980 12021],... % subject 7
    [6437 6480; 14566 14611; 18421 18479; 20883 20933],... % subject 8
    [9283 9328; 20374 20409],... % subject 9
    [10589 10672; 21924 22005; 28328 28401],... % subject 10
    [2765 2862; 4795 4843; 7527 7591; 8440 8496; 12343 12410],... % subject 11
    [10348 10445; 13978 14184; 24177 24346],... % subject 12
    [14379 14418; 21954 22044],... % subject 13
    [6251 6314; 8057 8076; 10483 10529; 11505 11561; 13848 13893; 15401 15459; 16740 16794],... % subject 14
    [2903 2929], [9968 9992],... % subject 15   2-files
    [24512 24609], [13014 13131],... % subject 16   2-files
    [5682 5726], [9203 9239],... % subject 17   2-files
    [15893 15999], [6038 6104],... % subject 18   2-files
    [23804 23902], [1800 1887],... % subject 19   2-files
    [3508 3545], [19530 19557]}';  % subject 20   2-files

NumSub = length(FrontalSubIndex);
Path = [FileName,filesep];
Mat = dir(fullfile(Path,'*.mat'));
MatName = {Mat.name}';

%%
NewPath = ['m1_','Temporal_Interictal_Ictal',filesep];
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
