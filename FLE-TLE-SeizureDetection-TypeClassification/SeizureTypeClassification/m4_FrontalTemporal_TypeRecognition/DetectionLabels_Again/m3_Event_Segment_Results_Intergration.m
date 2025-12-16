clc
clear
close all
tic

%%
SenLa = load('m2_SenLa.mat');
SenLa = struct2cell(SenLa);
SenLa =SenLa{1,1};

SeizuresCount = load('m2_SeizuresCount.mat');
SeizuresCount = struct2cell(SeizuresCount);
SeizuresCount = SeizuresCount{1,1};

SSAAF = load('m1_SSAAF.mat');
SSAAF = struct2cell(SSAAF);
SSAAF = SSAAF{1,1};

NumChanType = length(SSAAF);
for ChanTypeNum = 1:NumChanType

    %%%%%%%********** Event-Based  Results**********%%%%%%%%
    NumSeizures = SeizuresCount{ChanTypeNum,1};
    MeanEventSenF = sum(NumSeizures(:,1))/sum(NumSeizures(:,2));
    MeanEventSenT = sum(NumSeizures(:,3))/sum(NumSeizures(:,4));

    TempSenLa = SenLa{ChanTypeNum,1};
    TempSenLa(:,[2,4]) = roundn(TempSenLa(:,[2,4]),-1);
    MeanLatency = mean(TempSenLa(:,[2,4]),'omitnan');

    TempSenLa = [TempSenLa;[MeanEventSenF,MeanLatency(1),MeanEventSenT,MeanLatency(2)]];
    TempSenLa(:,[1,3]) = roundn(TempSenLa(:,[1,3])*100,-1);
    TempSenLa(:,[2,4]) = roundn(TempSenLa(:,[2,4]),-1);

    %%%%%%%********** Segment-Based  Results**********%%%%%%%%
    TempSSAAF = SSAAF{ChanTypeNum,1};
    TempSSAAF(:,1:3) = roundn(TempSSAAF(:,1:3)*100,-1);
    TempSSAAF(:,4:end) = roundn(TempSSAAF(:,4:end),-3);
    SegMean = mean(TempSSAAF,1);

    TempSSAAF = [TempSSAAF;SegMean];
    TempSSAAF(:,1:3) = roundn(TempSSAAF(:,1:3),-1);
    TempSSAAF(:,4:end) = roundn(TempSSAAF(:,4:end),-3);

    SegmentEvent{ChanTypeNum,1} = [TempSenLa,TempSSAAF(:,1:end-1)];
end
save('m3_SegmentEvent','SegmentEvent')

%%
toc
