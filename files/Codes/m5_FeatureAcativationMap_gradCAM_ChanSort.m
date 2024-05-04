clc
clear
close all
tic

%% Scheme 3
load('m4_TrainNet_ChanSort.mat')
[NumSeizure,NumChanType,NumRun] = size(TrainNet);
FileName = {'Pat_18'};
NumFile = length(FileName);

F1Sort = load('m4_F1Sort.mat');
F1Sort = struct2cell(F1Sort);
F1Sort = F1Sort{1,1};

for FileNum = 1:NumFile
    Path = strcat(FileName{1,FileNum},filesep);
    Mat = dir(fullfile(Path,'*.mat'));
    MatName  = {Mat.name}';
    NumSeizure = size(MatName,1);
    SortIndex = F1Sort{13,2};

    for RunNum = 1:NumRun
        for SeizureNum = 1:NumSeizure
            TempMatRoute = strcat(Path,MatName{SeizureNum,1});
            load(TempMatRoute)
            XTestSelect = TrainTest{1,3};
            XTestSelect = gpuArray(XTestSelect);
            YTestLabel = TrainTest{1,4};
            YTestLabel = categorical(YTestLabel);

            for ChanNum = 2%1:NumChan
                TempXTest = [];
                TempXTest = XTestSelect(SortIndex(1:ChanNum),:,:);
                XTest = [];
                for SampNum = 1:size(TempXTest,3)
                    XTest{SampNum,1} = TempXTest(:,:,SampNum);
                end

                net = [];
                net = TrainNet{SeizureNum,NumChanType,RunNum};%%%%%%%%%%%%%%%%
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
                MapLabel_ChanSort{1,SeizureNum,RunNum} =  TempMapLabel;
                TempMapLabel = [];
            end
        end
    end
end
save('m5_MapLabel_ChanSort','MapLabel_ChanSort')

%%
toc