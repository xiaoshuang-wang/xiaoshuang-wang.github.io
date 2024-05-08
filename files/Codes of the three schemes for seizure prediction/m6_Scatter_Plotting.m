clc
clear
close all
tic

%% Parameters for picture
YMin = 0;
YMax = 4;
FaceAlpha = 0.9;
h = figure;
set(gcf,'outerposition',get(0,'screensize'));
NumRow = 5;
NumColumn = 5;
FileName = {'Pat_18'};
NumFile = length(FileName);
color1 = 'k.';
color2 = 'r.';
ColorMap = [0.85 0.85 0.85];
ViewAngle1 = 135;
ViewAngle2 = 15;
ViewAngle = [ViewAngle1,ViewAngle2];
RunNumIndex = [2,1];

%% Feature maps of All Channels
load('m5_MapLabel_AllChan.mat')
[NumChanType,NumSeizure,NumRun] = size(MapLabel_AllChan);
for FileNum = 1:NumFile
    Path = strcat(FileName{1,FileNum},filesep);
    Mat = dir(fullfile(Path,'*.mat'));
    MatName  = {Mat.name}';
    for RunNum = 1:NumRun
        XTestData = [];
        XTestMap = [];
        YTest = [];
        XPredMap = [];
        YPred = [];
        for SeizureNum = 1:NumSeizure
            TempMatRoute = strcat(Path,MatName{SeizureNum,1});
            load(TempMatRoute)
            XTestSelect = TrainTest{1,3};
            XTestMean = mean(mean(XTestSelect,1),2);
            XTestMean = squeeze(XTestMean);
            XTestData = [XTestData;XTestMean];

            Temp = MapLabel_AllChan{NumChanType,SeizureNum,RunNumIndex(RunNum)};

            TempXTestMap = Temp{1,1};
            TempXTestMapMean = mean(TempXTestMap,2);
            XTestMap = [XTestMap;TempXTestMapMean];

            TempYTest = Temp{1,2};
            TempYTest = string(TempYTest);
            TempYTest = double(TempYTest);
            YTest = [YTest;TempYTest];

            TempXPredMap = Temp{1,3};
            TempXPredMapMean = mean(TempXPredMap,2);
            XPredMap = [XPredMap;TempXPredMapMean];

            TempYPred = Temp{1,4};
            TempYPred = string(TempYPred);
            TempYPred = double(TempYPred);
            YPred = [YPred;TempYPred];
        end
        TempIndex0True = find(YTest==0);
        TempIndex1True = find(YTest==1);
        Index = [TempIndex0True;TempIndex1True];

        XTestData = XTestData(Index);
        XTestDataMaxV = max(XTestData(:));
        XTestDataMinV = min(XTestData(:));

        XTestMap = XTestMap(Index);
        XTestMap = double(XTestMap);
        YTestMapMaxV = max(XTestMap(:));
        YTestMapMinV = min(XTestMap(:));

        YTest = YTest(Index);

        XPredMap = XPredMap(Index);
        XPredMap = double(XPredMap);
        YPredMapMaxV = max(XPredMap(:));
        YPredMapMinV = min(XPredMap(:));

        YPred = YPred(Index);

        Index0True = [];
        Index1True = [];
        Index0Pred = [];
        Index1Pred = [];
        Index0True = find(YTest==0);
        Index1True = find(YTest==1);
        Index0Pred = find(YPred==0);
        Index1Pred = find(YPred==1);

        subplot(NumRow,NumColumn,[1,NumColumn+1])
        scatter3(XTestData(Index0True),XTestMap(Index0True),Index0True, color1);
        hold on;
        scatter3(XTestData(Index1True),XTestMap(Index1True),Index1True, color2);
        hold on
        [X,Y,Z] = meshgrid(linspace(XTestDataMinV, XTestDataMaxV, 5), ...
            linspace(YMin, YMax, 5), ...
            linspace(0, length(Index0True), length(Index0True)));
        S = slice(X,double(Y),Z,ones(size(Z)),[],[],[length(Index0True)]);
        S.FaceAlpha = FaceAlpha;
        shading flat;
        colormap(ColorMap);
        hold on
        view(ViewAngle);
        ax = gca;
        ax.GridLineStyle = '--';
        ax.GridAlpha = 0.2;
        ax.FontWeight = 'bold';
        %zlabel('Number of inputs');
        xlim([XTestDataMinV, XTestDataMaxV])
        ylim([YMin,YMax])

        subplot(NumRow,NumColumn,[2*NumColumn+1,3*NumColumn+1])
        scatter3(XTestData(Index0Pred),XPredMap(Index0Pred),Index0Pred, color1);
        hold on
        scatter3(XTestData(Index1Pred),XPredMap(Index1Pred),Index1Pred, color2);
        hold on
        S = slice(X,double(Y),Z,ones(size(Z)),[],[],[length(Index0True)]);
        S.FaceAlpha = FaceAlpha;
        shading flat;
        colormap(ColorMap);
        hold on
        view(ViewAngle);
        ax = gca;
        ax.GridLineStyle = '--';
        ax.GridAlpha = 0.2;
        ax.FontWeight = 'bold';
        %zlabel('Number of inputs');
        xlim([XTestDataMinV, XTestDataMaxV])
        ylim([YMin,YMax])
    end
end

%% Feature maps of Channel voting
load('m5_MapLabel_ChanVoting.mat')
[NumChanType,NumSeizure,NumRun] = size(MapLabel_ChanVoting);
for FileNum = 1:NumFile
    Path = strcat(FileName{1,FileNum},filesep);
    Mat = dir(fullfile(Path,'*.mat'));
    MatName  = {Mat.name}';
    for RunNum = 1:NumRun
        XTestData = [];
        XTestMap = [];
        YTest = [];
        XPredMap = [];
        YPred = [];
        for SeizureNum = 1:NumSeizure
            TempMatRoute = strcat(Path,MatName{SeizureNum,1});
            load(TempMatRoute)
            XTestSelect = TrainTest{1,3};
            XTestMean = mean(mean(XTestSelect,1),2);
            XTestMean = squeeze(XTestMean);
            XTestData = [XTestData;XTestMean];
            TempXTestMap = [];
            TempYTest = [];
            TempXPredMap = [];
            TempYPred = [];
            for ChanTypeNum = 1:NumChanType
                Temp = MapLabel_ChanVoting{ChanTypeNum,SeizureNum,RunNumIndex(RunNum)};
                TempXTestMap = cat(3,TempXTestMap,Temp{1,1});
                TempYTest = [TempYTest,Temp{1,2}];
                TempXPredMap = cat(3,TempXPredMap,Temp{1,3});
                TempYPred = [TempYPred,Temp{1,4}];
            end
            TempXTestMapMean = mean(mean(TempXTestMap,3),2);
            TempXTestMapMean = squeeze(TempXTestMapMean);
            XTestMap = [XTestMap;TempXTestMapMean];

            TempYTest = string(TempYTest);
            TempYTest = double(TempYTest);
            YTest = [YTest;mean(TempYTest,2)];

            TempXPredMapMean = mean(mean(TempXPredMap,3),2);
            TempXPredMapMean = squeeze(TempXPredMapMean);
            XPredMap = [XPredMap;TempXPredMapMean];

            TempYPred = string(TempYPred);
            TempYPred = double(TempYPred);
            YPred = [YPred;mean(TempYPred,2)];
        end
        TempIndex0True = find(YTest==0);
        TempIndex1True = find(YTest==1);
        Index = [TempIndex0True;TempIndex1True];

        XTestData = XTestData(Index);
        XTestDataMaxV = max(XTestData(:));
        XTestDataMinV = min(XTestData(:));

        XTestMap = XTestMap(Index);
        XTestMap = double(XTestMap);
        YTestMapMaxV = max(XTestMap(:));
        YTestMapMinV = min(XTestMap(:));

        YTest = YTest(Index);

        XPredMap = XPredMap(Index);
        XPredMap = double(XPredMap);
        YPredMapMaxV = max(XPredMap(:));
        YPredMapMinV = min(XPredMap(:));

        YPred = YPred(Index);
        YPred = roundn(YPred,0);

        Index0True = [];
        Index1True = [];
        Index0Pred = [];
        Index1Pred = [];
        Index0True = find(YTest==0);
        Index1True = find(YTest==1);
        Index0Pred = find(YPred==0);
        Index1Pred = find(YPred==1);

        subplot(NumRow,NumColumn,[2,NumColumn+2])
        scatter3(XTestData(Index0True),XTestMap(Index0True),Index0True, color1);
        hold on;
        scatter3(XTestData(Index1True),XTestMap(Index1True),Index1True, color2);
        hold on
        S = slice(X,double(Y),Z,ones(size(Z)),[],[],[length(Index0True)]);
        S.FaceAlpha = FaceAlpha;
        shading flat;
        colormap(ColorMap);
        hold on
        view(ViewAngle);
        ax = gca;
        ax.GridLineStyle = '--';
        ax.GridAlpha = 0.2;
        ax.FontWeight = 'bold';
        %zlabel('Number of inputs');
        xlim([XTestDataMinV, XTestDataMaxV])
        ylim([YMin,YMax])

        subplot(NumRow,NumColumn,[2*NumColumn+2,3*NumColumn+2])
        scatter3(XTestData(Index0Pred),XPredMap(Index0Pred),Index0Pred, color1);
        hold on
        scatter3(XTestData(Index1Pred),XPredMap(Index1Pred),Index1Pred, color2);
        hold on
        S = slice(X,double(Y),Z,ones(size(Z)),[],[],[length(Index0True)]);
        S.FaceAlpha = FaceAlpha;
        shading flat;
        colormap(ColorMap);
        hold on
        view(ViewAngle);
        ax = gca;
        ax.GridLineStyle = '--';
        ax.GridAlpha = 0.2;
        ax.FontWeight = 'bold';
        %zlabel('Number of inputs');
        xlim([XTestDataMinV, XTestDataMaxV])
        ylim([YMin,YMax])
    end
end

%% Feature maps of channels sort
load('m5_MapLabel_ChanSort_Again.mat')
[NumChanType,NumSeizure,NumRun] = size(MapLabel_ChanSort);
for FileNum = 1:NumFile
    Path = strcat(FileName{1,FileNum},filesep);
    Mat = dir(fullfile(Path,'*.mat'));
    MatName  = {Mat.name}';
    for RunNum = 1:NumRun
        XTestData = [];
        XTestMap = [];
        YTest = [];
        XPredMap = [];
        YPred = [];
        for SeizureNum = 1:NumSeizure
            TempMatRoute = strcat(Path,MatName{SeizureNum,1});
            load(TempMatRoute)
            XTestSelect = TrainTest{1,3};
            XTestMean = mean(mean(XTestSelect,1),2);
            XTestMean = squeeze(XTestMean);
            XTestData = [XTestData;XTestMean];

            Temp = MapLabel_ChanSort{NumChanType,SeizureNum,RunNumIndex(RunNum)};

            TempXTestMap = Temp{1,1};
            TempXTestMapMean = mean(TempXTestMap,2);
            XTestMap = [XTestMap;TempXTestMapMean];

            TempYTest = Temp{1,2};
            TempYTest = string(TempYTest);
            TempYTest = double(TempYTest);
            YTest = [YTest;TempYTest];

            TempXPredMap = Temp{1,3};
            TempXPredMapMean = mean(TempXPredMap,2);
            XPredMap = [XPredMap;TempXPredMapMean];

            TempYPred = Temp{1,4};
            TempYPred = string(TempYPred);
            TempYPred = double(TempYPred);
            YPred = [YPred;TempYPred];
        end
        TempIndex0True = find(YTest==0);
        TempIndex1True = find(YTest==1);
        Index = [TempIndex0True;TempIndex1True];

        XTestData = XTestData(Index);
        XTestDataMaxV = max(XTestData(:));
        XTestDataMinV = min(XTestData(:));

        XTestMap = XTestMap(Index);
        YTestMapMaxV = max(XTestMap(:));
        YTestMapMinV = min(XTestMap(:));

        YTest = YTest(Index);

        XPredMap = XPredMap(Index);
        YPredMapMaxV = max(XPredMap(:));
        YPredMapMinV = min(XPredMap(:));

        YPred = YPred(Index);

        Index0True = [];
        Index1True = [];
        Index0Pred = [];
        Index1Pred = [];
        Index0True = find(YTest==0);
        Index1True = find(YTest==1);
        Index0Pred = find(YPred==0);
        Index1Pred = find(YPred==1);

        subplot(NumRow,NumColumn,[3,NumColumn+3])
        scatter3(XTestData(Index0True),XPredMap(Index0True),Index0True, color1);
        hold on;
        scatter3(XTestData(Index1True),XPredMap(Index1True),Index1True, color2);
        hold on
        S = slice(X,double(Y),Z,ones(size(Z)),[],[],[length(Index0True)]);
        S.FaceAlpha = FaceAlpha;
        shading flat;
        colormap(ColorMap);
        hold on
        view(ViewAngle);
        ax = gca;
        ax.GridLineStyle = '--';
        ax.GridAlpha = 0.2;
        ax.FontWeight = 'bold';
        %zlabel('Number of inputs');
        xlim([XTestDataMinV, XTestDataMaxV])
        ylim([YMin,YMax])

        subplot(NumRow,NumColumn,[2*NumColumn+3,3*NumColumn+3])
        scatter3(XTestData(Index0Pred),XPredMap(Index0Pred),Index0Pred,color1);
        hold on
        scatter3(XTestData(Index1Pred),XPredMap(Index1Pred),Index1Pred, color2);
        hold on
        S = slice(X,double(Y),Z,ones(size(Z)),[],[],[length(Index0True)]);
        S.FaceAlpha = FaceAlpha;
        shading flat;
        colormap(ColorMap);
        hold on
        view(ViewAngle);
        ax = gca;
        ax.GridLineStyle = '--';
        ax.GridAlpha = 0.2;
        ax.FontWeight = 'bold';
        %zlabel('Number of inputs');
        xlim([XTestDataMinV, XTestDataMaxV])
        ylim([YMin,YMax])
    end
end
saveas(h,['m6_FeatureMap_Again','.epsc'])
saveas(h,['m6_FeatureMap_Again','.png'])
close all

%%
toc