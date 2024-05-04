clc
clear
close all
tic

%% Scheme 1 and Scheme 2
load('m2_TrainNet_AllChan_ChanVoting.mat')
[NumSeizure,NumChanType,NumRun] = size(TrainNet);
FileName = {'Pat_18'};
NumFile = length(FileName);

for FileNum = 1:NumFile
    Path = strcat(FileName{1,FileNum},filesep);
    Mat = dir(fullfile(Path,'*.mat'));
    MatName  = {Mat.name}';

    for RunNum = 1:NumRun
        for SeizureNum = 1:NumSeizure
            TempMatRoute = strcat(Path,MatName{SeizureNum,1});
            load(TempMatRoute)
            XTestSelect = TrainTest{1,3};
            XTestSelect = gpuArray(XTestSelect);
            YTestLabel = TrainTest{1,4};
            YTestLabel = categorical(YTestLabel);

            %%%%%%%%%************PART-1**************%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%********Single Channel*******%%%%%%%%%%%%%%%%%%%%
            for ChanNum = 1:NumChanType-1
                TempXTest = [];
                TempXTest = XTestSelect(ChanNum,:,:);
                XTest = [];
                for SampNum = 1:size(TempXTest,3)
                    XTest{SampNum,1} = TempXTest(:,:,SampNum);
                end
                net = [];
                net = TrainNet{SeizureNum,ChanNum,RunNum}; %%%%%%%%%%%%%%%%%
                YPred = [];
                YPred = classify(net,XTest);

                %%%%%%********feature map from gradCAM********%%%%%%
                NumSamp = length(XTest);
                for SampNum = 1:NumSamp
                    %%%********feature map of Pred Label gradCAM********%%%
                    YPredselect = YPred(SampNum,1);
                    TempPredMap = [];
                    TempPredMap = gradCAM(net,XTest{SampNum,1},YPredselect);
                    PredMap(SampNum,:) = TempPredMap;

                    %%%********feature map of Real Label gradCAM********%%%
                    YTestSelect = YTestLabel(SampNum,1);
                    TempTestMap = [];
                    TempTestMap = gradCAM(net,XTest{SampNum,1},YTestSelect);
                    TestMap(SampNum,:) = TempTestMap;
                end
                TempMapLabel{1,1} = TestMap;
                TempMapLabel{1,2} = YTestLabel;
                TempMapLabel{1,3} = PredMap;
                TempMapLabel{1,4} = YPred;
                MapLabel_ChanVoting{ChanNum,SeizureNum,RunNum} = TempMapLabel;
                TempMapLabel = [];
            end

            %%%%%%%%%************PART-2**************%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%********All Channels*******%%%%%%%%%%%%%%%%%%%%
            XTest = [];
            for SampNum = 1:NumSamp
                XTest{SampNum,1} = XTestSelect(:,:,SampNum);
            end
            net = [];
            net = TrainNet{SeizureNum,NumChanType,RunNum};%%%%%%%%%%%%%%%%
            YPred = [];
            YPred = classify(net,XTest);

            %%%%%%********feature map from gradCAM********%%%%%%
            for SampNum = 1:NumSamp
                %%%********feature map of Pred Label gradCAM********%%%
                YPredselect = YPred(SampNum,1);
                TempPredMap = [];
                TempPredMap = gradCAM(net,XTest{SampNum,1},YPredselect);
                PredMap(SampNum,:) = TempPredMap;

                %%%********feature map of Real Label gradCAM********%%%
                YTestSelect = YTestLabel(SampNum,1);
                TempTestMap = [];
                TempTestMap = gradCAM(net,XTest{SampNum,1},YTestSelect);
                TestMap(SampNum,:) = TempTestMap;
            end
            TempMapLabel{1,1} = TestMap;
            TempMapLabel{1,2} = YTestLabel;
            TempMapLabel{1,3} = PredMap;
            TempMapLabel{1,4} = YPred;
            MapLabel_AllChan{1,SeizureNum,RunNum} = TempMapLabel;
            TempMapLabel = [];
        end
    end
end
save('m5_MapLabel_AllChan','MapLabel_AllChan')
save('m5_MapLabel_ChanVoting','MapLabel_ChanVoting')

%%
toc