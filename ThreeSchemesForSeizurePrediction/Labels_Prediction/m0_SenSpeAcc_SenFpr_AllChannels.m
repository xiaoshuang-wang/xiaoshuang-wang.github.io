clc
clear 
close all
tic

%%
% DatasetType = {['01_Freiburg_Epileptic_Prediction',filesep];...
%     ['02_SWEC_ETHZ_iEEG_Epilepsy_LongTerm',filesep];...
%     ['03_America_Society_Seizure_Prediction',filesep]};
DatasetType = {['01_Freiburg_Epileptic_Prediction',filesep]};

LabelFile = ['Labels_Prediction',filesep];
NumDataset = length(DatasetType);

for DatasetNum = 1:NumDataset
    Route = strcat(DatasetType{DatasetNum,1},LabelFile);
    File = dir(fullfile(Route,'*.mat'));
    LabelMatName = {File.name}';
    NumLabelMat = length(LabelMatName);

    for LabelMatNum = 1:NumLabelMat
        Path = strcat(Route,LabelMatName{LabelMatNum,1});
        Label = load(Path);
        Label = struct2cell(Label);
        Label = cell2mat(Label);
        [NumSamp,NumSeizure,NumRun,NumChanType] = size(Label);

        AllChanLabel = Label(:,:,:,NumChanType-1);
        TrueLabel = Label(:,:,:,NumChanType);
        TempLabel(:,:,:,1) = AllChanLabel;  %%% All channels
        TempLabel(:,:,:,2) = TrueLabel;  %%%

        LabelNew{DatasetNum,1}{LabelMatNum,1} = TempLabel;
        clear AllChanLabel TrueLabel TempLabel
    end
end

%%
WindowIndex = [10,15,20];
SOP = 30; %%% min
SPH = 5; %%% min

for WindowIndexNum = 1:length(WindowIndex)
    Window = [];
    Window = WindowIndex(WindowIndexNum);
    for DatasetNum = 1:NumDataset
        DatasetLabel = LabelNew{DatasetNum,1};
        NumPatient = length(DatasetLabel);
        for PatientNum = 1:NumPatient
            PatientLabel = [];
            AllChanLabel = [];
            TrueLabel = [];
            PatientLabel = DatasetLabel{PatientNum,1};
            [NumSamp,NumSeizure,NumRun,NumLabelType] = size(PatientLabel);
            AllChanLabel = PatientLabel(:,:,:,NumLabelType-1);
            TrueLabel = PatientLabel(:,:,:,NumLabelType);

            Index0 = [];
            Index1 = [];
            Index0 = find(TrueLabel(:,1,1) == 0);
            Index1 = find(TrueLabel(:,1,1) == 1);

            %%%%%%***** Labels of All Channels VS True Labels*****%%%%%%
            for RunNum = 1:NumRun
                for SeizureNum = 1:NumSeizure
                    %%**********Segment-based level**********%%
                    TP = sum(AllChanLabel(Index1,SeizureNum,RunNum));
                    FN = length(Index1)-TP;
                    FP = sum(AllChanLabel(Index0,SeizureNum,RunNum));
                    TN = length(Index0)-FP;


                    Sen = TP/(TP+FN);
                    Spe = TN/(FP+TN);
                    Acc = (TP+TN)/(TP+FN+FP+TN);
                    FPr = FP/(FP+TN);

                    TempSenSpeAccFPr(1,SeizureNum,RunNum) = Sen;
                    TempSenSpeAccFPr(2,SeizureNum,RunNum) = Spe;
                    TempSenSpeAccFPr(3,SeizureNum,RunNum) = Acc;
                    TempSenSpeAccFPr(4,SeizureNum,RunNum) = FPr;
                    clear Sen Spe Acc FPr

                    %%**********Event-based level**********%%
                    %%%% For FPR
                    NumFpr = 0;
                    Threshold = 0;
                    count = 0;
                    subcount = 0;
                    Interval = (SOP+SPH)*60/4;
                    NumLabel0 = length(Index0);
                    LabelPred0 = [];
                    LabelPred0 = AllChanLabel(Index0,SeizureNum,RunNum);
                    for Label0Num = 1:(NumLabel0-Window+1)
                        Lstart = Label0Num;
                        Lend = Lstart+Window-1;
                        if Threshold < Window-2
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
                    TempSenFpr(2,SeizureNum,RunNum) = NumFpr;

                    %%%% For event-based sensitivity
                    NumSen = 0;
                    NumLabel1 = length(Index1);
                    LabelPred1 = [];
                    LabelPred1 = AllChanLabel(Index1,SeizureNum,RunNum);
                    for Label1Num = 1:(NumLabel1-Window+1)
                        Lstart = Label1Num;
                        Lend = Lstart+Window-1;
                        Threshold = sum(LabelPred1(Lstart:Lend));
                        if Threshold > (Window-3) %%%%%%%%%%%%%%%%%%%%%%%%%
                            NumSen = NumSen+1;
                        end
                    end
                    if NumSen > 0
                        TempSen = 1;
                    else
                        TempSen = 0;
                    end
                    TempSenFpr(1,SeizureNum,RunNum) = TempSen;
                end
            end
            SSA_SF{WindowIndexNum,DatasetNum}{PatientNum,1} = TempSenSpeAccFPr;
            SSA_SF{WindowIndexNum,DatasetNum}{PatientNum,2} = TempSenFpr;
            clear TempSenSpeAccFPr TempSenFpr
        end
    end
end
save('m0_SSA_SF_AllChannel','SSA_SF')

%%
toc