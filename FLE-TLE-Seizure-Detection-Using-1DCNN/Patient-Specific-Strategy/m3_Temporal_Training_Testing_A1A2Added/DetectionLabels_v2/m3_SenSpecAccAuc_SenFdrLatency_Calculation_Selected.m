clc
clear
close all
tic

%% Event-based level and Segment-based level
SFdLa = load('m1_SFdLa.mat');
SFdLa = struct2cell(SFdLa);
SFdLa = SFdLa{1,1};
[NumPatient,NumChanType] = size(SFdLa);

SSAA = load('m1_SSAAuc.mat');
SSAA = struct2cell(SSAA);
SSAA = SSAA{1,1};

%%%%% Seleccting two best running
for ChanTypeNum = 1:NumChanType
    for PatientNum = 1:NumPatient
        TempSSAA = SSAA{PatientNum,ChanTypeNum};
        TempSFdLa = SFdLa{PatientNum,ChanTypeNum};
        [NumMetricType,NumSeizure,NumRun] = size(TempSSAA);
        TempSSAASelect = [];
        TempSFdLaSelect = [];
        for SeizureNum = 1:NumSeizure
            TempSeg = squeeze(TempSSAA(end,SeizureNum,:));
            [~, sortedIndices] = sort(TempSeg,'descend');
            top2Indices = sortedIndices(1:2);
            TempSSAASelect = cat(2,TempSSAASelect,TempSSAA(:,SeizureNum,top2Indices));
            TempSFdLaSelect = cat(2,TempSFdLaSelect,TempSFdLa(:,SeizureNum,top2Indices));
        end
        SSAASelect{PatientNum,ChanTypeNum} = TempSSAASelect;
        SFdLaSelect{PatientNum,ChanTypeNum} = TempSFdLaSelect;
        clear TempSSAA TempSFdLa
    end
end

%%
Interictal = [16,12.9,16,11.3,10.1,16,8,6.1,8,8,...
    8,8,8,8,15.3,16,16,16,11.9,8]';

for ChanTypeNum = 1:NumChanType
    EventAvg = [];
    SegAvg = [];
    for PatientNum = 1:NumPatient
        %%%%%**************** Event-based level ****************%%%%%
        TempEvent = SFdLaSelect{PatientNum,ChanTypeNum};
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
        TempSeg = SSAASelect{PatientNum,ChanTypeNum};
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
save('m3_EventSegment','EventSegment')
%%
toc
