clc
clear
close all
tic

%%
Path = ['01_Freiburg_Epileptic_Prediction',filesep];
File = dir(fullfile(Path,'*.mat'));
MatName = {File.name}';
NumMat = length(MatName);

WindowIndex = [10,15,20];
SOP = 30; %%% min
SPH = 5; %%% min

for WindowIndexNum = 1:length(WindowIndex)
    Window = [];
    Window = WindowIndex(WindowIndexNum);
    for MatNum = 1:NumMat
        Route = strcat(Path,MatName{MatNum,1});
        MatLabel = load(Route);
        MatLabel = struct2cell(MatLabel);
        MatLabel = cell2mat(MatLabel);
        [NumLabel,NumSeizure,NumRun,NumChanType] = size(MatLabel);

        RawLabel = MatLabel(:,1,1,NumChanType);
        Index0 = [];
        Index1 = [];
        Index0 = find(RawLabel == 0);
        Index1 = find(RawLabel == 1);
        for ChanTypeNum = 1:(NumChanType-1)
            for RunNum = 1:NumRun
                for SeizureNum = 1:NumSeizure
                    TempLabel = [];
                    TempLabel = MatLabel(:,SeizureNum,RunNum,ChanTypeNum);

                    %%%%%%%%%% for segment-based level
                    TP = sum(TempLabel(Index1));
                    FN = length(Index1)-TP;
                    FP = sum(TempLabel(Index0));
                    TN = length(Index0)-FP;
                    Sen = TP/(TP+FN);
                    Spe = TN/(FP+TN);
                    Acc = (TP+TN)/(TP+FN+FP+TN);
                    FPr = FP/(FP+TN);

                    TempSenSpeAccFPr(1,SeizureNum,RunNum,ChanTypeNum) = Sen;
                    TempSenSpeAccFPr(2,SeizureNum,RunNum,ChanTypeNum) = Spe;
                    TempSenSpeAccFPr(3,SeizureNum,RunNum,ChanTypeNum) = Acc;
                    TempSenSpeAccFPr(4,SeizureNum,RunNum,ChanTypeNum) = FPr;
                    clear Sen Spe Acc FPr

                    %%%%%%%%%% for event-based level
                    %%%% For FPR
                    NumFpr = 0;
                    Threshold = 0;
                    count = 0;
                    subcount = 0;
                    Interval = (SOP+SPH)*60/4;
                    NumLabel0 = length(Index0);
                    LabelPred0 = [];
                    LabelPred0 = MatLabel(Index0,SeizureNum,RunNum,ChanTypeNum);
                    for Label0Num = 1:(NumLabel0-Window+1)
                        Lstart = Label0Num;
                        Lend = Lstart+Window-1;
                        if Threshold < Window
                            if count == 0
                                Threshold = sum(LabelPred0(Lstart:Lend));
                            end
                            if count == 1
                                subcount = subcount+1;
                                if subcount > Interval-1
                                    count = 0;
                                    subcount = 0;
                                end
                            end
                        end
                        if Threshold > (Window-3) %%%%%%%%%%%%%%%%%%%%%%%%
                            NumFpr = NumFpr+1;
                            Threshold = 0;
                            count = 1;
                        end
                    end
                    TempSenFpr(2,SeizureNum,RunNum,ChanTypeNum) = NumFpr;

                    %%%% For event-based sensitivity
                    NumSen = 0;
                    NumLabel1 = length(Index1);
                    LabelPred1 = [];
                    LabelPred1 = MatLabel(Index1,SeizureNum,RunNum,ChanTypeNum);
                    for Label1Num = 1:(NumLabel1-Window+1)
                        Lstart = Label1Num;
                        Lend = Lstart+Window-1;
                        Threshold = sum(LabelPred1(Lstart:Lend));
                        if Threshold > (Window-3) %%%%%%%%%%%%%%%%%%%%%%%%
                            NumSen = NumSen+1;
                        end
                    end
                    if NumSen > 0
                        TempSen = 1;
                    else
                        TempSen = 0;
                    end
                    TempSenFpr(1,SeizureNum,RunNum,ChanTypeNum) = TempSen;
                end
            end
        end
        SSA_SF{WindowIndexNum,1}{MatNum,1} = TempSenSpeAccFPr;
        SSA_SF{WindowIndexNum,1}{MatNum,2} = TempSenFpr;
        clear TempSenSpeAccFPr TempSenFpr
    end
end
save('m0_SSA_SF_ChanSort','SSA_SF')

%%
toc