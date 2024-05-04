clc
clear
close all
tic

%% Parameters
% FileName = {'Pat_01','Pat_03','Pat_04','Pat_05','Pat_09','Pat_10',...
%     'Pat_11','Pat_12','Pat_14','Pat_15','Pat_16','Pat_17',...
%     'Pat_18','Pat_19','Pat_20','Pat_21'};
FileName = {'Pat_18'};
NumFile = length(FileName);
NumRun = 2;

maxEpochs = 100;
miniBatchSize = 64;
NumPatience = floor(0.1*maxEpochs);
ValidationRate = 0.15;

NewFile = ['Labels_Prediction_After_Sort',filesep];
mkdir(NewFile)

%%
F1Sort = load('m4_F1Sort.mat');
F1Sort = struct2cell(F1Sort);
F1Sort = F1Sort{1,1};

%%
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

            XTrainSelect = TrainTest{1,1};
            YTrainSelect = TrainTest{1,2};
            XTestSelect = TrainTest{1,3};
            YTestLabel = TrainTest{1,4};

            [NumChan,NumPoint,NumSamp] = size(XTrainSelect);
            count = 0;

            %%%%%%%%%%%%%%%%% PART_1 %%%%%%%%%%%%%%%%%%%
            for ChanNum = 2%1:NumChan
                %%%%%***********  Model construction *********%%%%%%%%
                InputSize = ChanNum;
                CnnLstm = layerGraph();
                tempLayers = sequenceInputLayer(InputSize,"Name","sequence");
                CnnLstm = addLayers(CnnLstm,tempLayers);
                tempLayers = [
                    convolution1dLayer(3,32,"Name","conv1d","Padding","same","Stride",2)
                    reluLayer("Name","relu")
                    convolution1dLayer(3,32,"Name","conv1d_1","Padding","same","Stride",2)
                    reluLayer("Name","relu_1")
                    batchNormalizationLayer("Name","batchnorm")
                    maxPooling1dLayer(3,"Name","maxpool1d","Padding","same","Stride",2) %%%%%%

                    convolution1dLayer(3,64,"Name","conv1d_2","Padding","same","Stride",2)
                    reluLayer("Name","relu_2")
                    batchNormalizationLayer("Name","batchnorm_1")
                    maxPooling1dLayer(3,"Name","maxpool1d_1","Padding","same","Stride",2) %%%%%%

                    convolution1dLayer(3,128,"Name","conv1d_3","Padding","same","Stride",2)
                    reluLayer("Name","relu_3")
                    batchNormalizationLayer("Name","batchnorm_2")
                    maxPooling1dLayer(3,"Name","maxpool1d_2","Padding","same","Stride",2)%%%%%%

                    lstmLayer(256,"Name","lstm")];
                CnnLstm = addLayers(CnnLstm,tempLayers);

                tempLayers = [
                    convolution1dLayer(5,32,"Name","conv1d_4","Padding","same","Stride",2)
                    reluLayer("Name","relu_4")
                    convolution1dLayer(5,32,"Name","conv1d_5","Padding","same","Stride",2)
                    reluLayer("Name","relu_5")
                    batchNormalizationLayer("Name","batchnorm_3")
                    maxPooling1dLayer(5,"Name","maxpool1d_3","Padding","same","Stride",2) %%%%%%

                    convolution1dLayer(5,64,"Name","conv1d_6","Padding","same","Stride",2)
                    reluLayer("Name","relu_6")
                    batchNormalizationLayer("Name","batchnorm_4")
                    maxPooling1dLayer(5,"Name","maxpool1d_4","Padding","same","Stride",2) %%%%%%

                    convolution1dLayer(5,128,"Name","conv1d_7","Padding","same","Stride",2)
                    reluLayer("Name","relu_7")
                    batchNormalizationLayer("Name","batchnorm_5")
                    maxPooling1dLayer(5,"Name","maxpool1d_5","Padding","same","Stride",2) %%%%%%

                    lstmLayer(256,"Name","lstm_1")];
                CnnLstm = addLayers(CnnLstm,tempLayers);

                tempLayers = [
                    concatenationLayer(1,2,"Name","concat")
                    globalAveragePooling1dLayer("Name","gapool1d")
                    fullyConnectedLayer(128,"Name","fc")
                    dropoutLayer(0.25,"Name","dropout")
                    fullyConnectedLayer(2,"Name","fc_1") %%%%%%

                    softmaxLayer("Name","softmax")
                    classificationLayer("Name","classoutput")];
                CnnLstm = addLayers(CnnLstm,tempLayers);
                % clean up helper variable
                clear tempLayers;
                %%% Connect all the branches of the network to create the network graph.
                CnnLstm = connectLayers(CnnLstm,"sequence","conv1d");
                CnnLstm = connectLayers(CnnLstm,"sequence","conv1d_4");
                CnnLstm = connectLayers(CnnLstm,"lstm","concat/in1");
                CnnLstm = connectLayers(CnnLstm,"lstm_1","concat/in2");

                %%%%%*********** training and testing for SIGLE-CHANNEL*********%%%%%%%%
                count = count+1;
                TempXTrain = XTrainSelect(SortIndex(1:ChanNum),:,:);
                XTrain = [];
                for SampNum = 1:NumSamp
                    XTrain{SampNum,1} = TempXTrain(:,:,SampNum);
                end
                clear TempXTrain
                YTrain = categorical(YTrainSelect);
                idx = randperm(NumSamp,floor(NumSamp*ValidationRate));
                XValidation = XTrain(idx);
                XTrain(idx) = [];
                YValidation = YTrain(idx);
                YTrain(idx) = [];
                clear idx

                options = trainingOptions('adam',...
                    LearnRateSchedule = 'piecewise',...
                    ExecutionEnvironment = 'auto',... %%% 'auto'
                    MaxEpochs = maxEpochs,...
                    MiniBatchSize = miniBatchSize,...
                    ValidationData = {XValidation,YValidation},...
                    Verbose = 1,...
                    OutputNetwork = 'best-validation-loss',... %%% 'last-iteration', 'best-validation-loss'
                    ValidationPatience = NumPatience); %%% Plots = 'training-progress'
                net = trainNetwork(XTrain,YTrain,CnnLstm,options);
                TrainNet{SeizureNum,count,RunNum} = net; %%%%%%******************************

                TempXTest = XTestSelect(SortIndex(1:ChanNum),:,:);
                XTest = [];
                for SampNum = 1:size(TempXTest,3)
                    XTest{SampNum,1} = TempXTest(:,:,SampNum);
                end
                clear TempXTest
                YPred = classify(net,XTest);
                YPred = string(YPred);
                YPred = double(YPred);
                PredLabel(:,SeizureNum,RunNum,count) = YPred;
                clear XTrain YTrain XTest YPred
            end

            %%%%%%%%%%%%%%%%%%
            count = count+1;
            PredLabel(:,SeizureNum,RunNum,count) = YTestLabel;
            clear XTrainSelect YTrainSelect
            clear XTestSelect YTestLabel
        end
    end

    save('m2_TrainNet_ChanSort_Again','TrainNet')

    NewRoute = strcat(NewFile,FileName{1,FileNum},'_Labels');
    save(NewRoute,'PredLabel')
    clear NewRoute PredLabel SortIndex
end

%%
toc