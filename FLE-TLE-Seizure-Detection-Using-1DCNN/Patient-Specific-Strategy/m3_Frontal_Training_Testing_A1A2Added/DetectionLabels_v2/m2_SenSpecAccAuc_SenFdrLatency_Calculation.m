clc
clear
close all
tic

%% Event-based level and Segment-based level
SFdLa = load('m1_SFdLa.mat');
SFdLa = struct2cell(SFdLa);
SFdLa = SFdLa{1,1};
Interictal = [8,16,8,8,8,4,16,8,14.3,8,...
    16,8,16,8,8,16,16,8,8,4]';

SSAA = load('m1_SSAAuc.mat');
SSAA = struct2cell(SSAA);
SSAA = SSAA{1,1};
[NumPatient,NumChanType] = size(SFdLa);

for ChanTypeNum = 1:NumChanType
    EventAvg = [];
    SegAvg = [];
    for PatientNum = 1:NumPatient
        %%%%%**************** Event-based level ****************%%%%%
        TempEvent = SFdLa{PatientNum,ChanTypeNum};
        [NumMetricType,NumSeizure,NumRun] = size(TempEvent);
        TempSenAvg = mean(TempEvent(1,:,:),[2,3]);
        TempFDTimes = sum(TempEvent(2,:,:),[2,3]);
        TempFDR = TempFDTimes/(Interictal(PatientNum)*NumRun);
        Tmp = [];
        TmpLatency = [];
        for RunNum = 1:NumRun
            Tmp = TempEvent(3,:,RunNum);
            Index = find(Tmp>0);
            TmpLatency(RunNum) = sum(Tmp(Index))/length(Index);
        end
        Index = [];
        Index = find(TmpLatency>0);
        TempLatency = sum(TmpLatency(Index))/length(Index);
        EventAvg = [EventAvg;[TempSenAvg,TempFDR,TempLatency]];

        %%%%%**************** Segment-based level ****************%%%%%
        TempSeg = SSAA{PatientNum,ChanTypeNum};
        TempSegAvg = mean(TempSeg,[2,3]);
        TempSegAvg = squeeze(TempSegAvg)';
        SegAvg = [SegAvg;TempSegAvg];
        clear TempSegAvg
    end

    Index_valid = ~isnan(EventAvg(:,end));
    Latency = EventAvg(Index_valid,end);
    EventAvg = [EventAvg;[mean(EventAvg(:,1:2),1),mean(Latency)]];
    clear Index_valid Latency
    EventAvg(:,1) = roundn(EventAvg(:,1)*100,-1);
    EventAvg(:,2) = roundn(EventAvg(:,2),-1);
    EventAvg(:,end) = roundn(EventAvg(:,end),-1);

    SegAvg = [SegAvg;mean(SegAvg,1)];
    SegAvg= roundn(SegAvg*100,-1);

    EventSegment{ChanTypeNum,1} = [EventAvg,SegAvg];
end
save('m2_EventSegment','EventSegment')

%%
toc