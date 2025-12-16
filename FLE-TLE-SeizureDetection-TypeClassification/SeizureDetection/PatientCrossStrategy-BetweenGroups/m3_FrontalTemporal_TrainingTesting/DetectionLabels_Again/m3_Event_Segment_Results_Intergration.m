clc
clear
close all
tic

%%
SenFdrLa = load('m2_SenFdrLa.mat');
SenFdrLa = struct2cell(SenFdrLa);
SenFdrLa =SenFdrLa{1,1};

SeizuresCount = load('m2_SeizuresCount.mat');
SeizuresCount = struct2cell(SeizuresCount);
SeizuresCount = SeizuresCount{1,1};

SSAAF = load('m1_SSAAF.mat');
SSAAF = struct2cell(SSAAF);
SSAAF = SSAAF{1,1};

[NumChanType,NumIctalType] = size(SSAAF);

for ChanTypeNum = 1:NumChanType
    for IctalTypeNum = 1:NumIctalType
        %%%%%%%********** Event-Based  Results**********%%%%%%%%
        NumSeizures = SeizuresCount{ChanTypeNum,IctalTypeNum};
        MeanEventSen = sum(NumSeizures(:,1))/sum(NumSeizures(:,2));

        TempSenFdrLa = SenFdrLa{ChanTypeNum,IctalTypeNum};
        TempSenFdrLa(:,2) = roundn(TempSenFdrLa(:,2),-1);
        MeanFdr = mean(TempSenFdrLa(:,2));

        TempSenFdrLa(:,end) = roundn(TempSenFdrLa(:,end),-1);
        MeanLatency = mean(TempSenFdrLa(:,end),'omitnan');

        TempSenFdrLa = [TempSenFdrLa;[MeanEventSen,MeanFdr,MeanLatency]];
        TempSenFdrLa(:,1) = roundn(TempSenFdrLa(:,1)*100,-1);
        TempSenFdrLa(:,2:end) = roundn(TempSenFdrLa(:,2:end),-1);

        TempSSAAF = SSAAF{ChanTypeNum,IctalTypeNum};
        TempSSAAF(:,1:3) = roundn(TempSSAAF(:,1:3)*100,-1);
        TempSSAAF(:,4:end) = roundn(TempSSAAF(:,4:end),-3);
        SegMean = mean(TempSSAAF,1);

        TempSSAAF = [TempSSAAF;SegMean];
        TempSSAAF(:,1:3) = roundn(TempSSAAF(:,1:3),-1);
        TempSSAAF(:,4:end) = roundn(TempSSAAF(:,4:end),-3);

        SegmentEvent{ChanTypeNum,IctalTypeNum} = [TempSenFdrLa,TempSSAAF(:,1:end-1)];

    end
end
save('m3_SegmentEvent','SegmentEvent')

%%
toc