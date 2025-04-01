clc
clear
close all
tic

%%
FileName = ['m1_','Frontal_Interictal_Ictal'];
Path = [FileName,filesep];
Mat = dir(fullfile(Path,'*.mat'));
MatName = {Mat.name}';

NumSub = length(MatName);
Second = 2;

%%
NewPath = ['m2_','Frontal_Interictal_Ictal_Segment_A1A2Added',filesep];
mkdir(NewPath)

for SubNum = 1:NumSub
    Route = strcat(Path,MatName{SubNum,1});
    load(Route);

    Window = Second*fs;

    NumInterictal = length(Interictal);
    for InterictalNum = 1:NumInterictal
        TempInterictal = [];
        TempInterictal = Interictal{InterictalNum,1};
        [NumChan,NumPoint] = size(TempInterictal);
        NumSeg = floor(NumPoint/Window);
        for SegNum = 1:NumSeg
            Lstart = (SegNum-1)*Window+1;
            Lend = SegNum*Window;
            InterictalSeg(:,:,SegNum) = TempInterictal(:,Lstart:Lend);
        end
        InterictalSegment{InterictalNum,1} = InterictalSeg;
        InterictalSeg = [];
    end

    NumIctal = length(Ictal);
    for IctalNum = 1:NumIctal
        TempIctal = [];
        TempIctal = Ictal{IctalNum,1};
        [NumChan,NumPoint] = size(TempIctal);
        NumSeg = floor(NumPoint/Window);
        for SegNum = 1:NumSeg
            Lstart = (SegNum-1)*Window+1;
            Lend = SegNum*Window;
            IctalSeg(:,:,SegNum) = TempIctal(:,Lstart:Lend);
        end
        IctalSegment{IctalNum,1} = IctalSeg;
        IctalSeg = [];
    end

    Segment{1,1} = InterictalSegment;
    Segment{1,2} = IctalSegment;
    InterictalSegment = [];
    IctalSegment = [];

    if SubNum < 10
        NewRoute = strcat([NewPath,int2str(0),int2str(SubNum),'_subject','.mat']);
    else
        NewRoute = strcat([NewPath,int2str(SubNum),'_subject','.mat']);
    end
    save(NewRoute,'Segment','fs','ChanSelect','ChanIndex')
    Segment = [];
end

%%
toc