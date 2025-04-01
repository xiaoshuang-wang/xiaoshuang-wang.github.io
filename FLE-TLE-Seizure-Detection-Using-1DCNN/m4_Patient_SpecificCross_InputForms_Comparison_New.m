clc
clear
close all
tic

%% Data
%%% FLE patient 18 in patient-specific strategy (input form-1 is the best)
FleTle_InputForm{1,1} = [100, 0, 21, 44.2, 99.9, 99.8, 72.0]';
FleTle_InputForm{1,2} = [100, 0, 23, 40.0, 99.9, 99.7, 69.9]';
FleTle_InputForm{1,3} = [50, 0, 18, 32.8, 99.9, 99.8, 66.4]';
FleTle_InputForm{1,4} = [50, 0, 22, 32.8, 99.9, 99.7, 66.3]';

%%% TLE patient 3 in patient-specific strategy (input form-2 is the best)
FleTle_InputForm{2,1} = [100, 0, 17, 63.5, 99.8, 99.8, 81.7]';
FleTle_InputForm{2,2} = [100, 0, 16, 74.3, 99.8, 99.8, 87.0]';
FleTle_InputForm{2,3} = [100, 0, 18, 64.6, 99.8, 99.7, 82.2]';
FleTle_InputForm{2,4} = [100, 0, 16, 69.4, 99.9, 99.9, 84.7]';

%%% FLE patient 10 in patient-cross strategy (input form-3 is the best)
FleTle_InputForm{3,1} = [100, 1.3, 10, 65.4, 93.0, 92.9, 79.2]';
FleTle_InputForm{3,2} = [100, 1.1, 10, 69.2, 92.9, 92.8, 81.0]';
FleTle_InputForm{3,3} = [100, 0.5, 10, 88.5, 98.1, 98.1, 93.3]';
FleTle_InputForm{3,4} = [100, 1.6, 10, 65.4, 89.0, 89.0, 77.2]';

%%% TLE patient 11 in patient-cross strategy (input form-4 is the best)
FleTle_InputForm{4,1} = [100, 1.9, 19, 76.9, 89.3, 89.1, 83.1]';
FleTle_InputForm{4,2} = [100, 0.8, 25, 70.7, 94.5, 94.2, 82.6]';
FleTle_InputForm{4,3} = [80, 1.2, 22, 71.0, 94.7, 94.5, 82.9]';
FleTle_InputForm{4,4} = [100, 0.7, 20, 77.2, 95.0, 94.8, 86.1]';

%% Plotting
NumRow = 3;
NumColumn = 2;
labels = {'Sene (%)', 'FDR (1/h)', 'Latency (s)','Sens (%)', 'Spec (%)', 'Acc (%)', 'AUC (%)',};
x = 2:2:2*length(labels);
BarWidth = 0.17;
Tn = {'(A) Results of FLE Patient 18 in Patient-Specific Strategy';
    '(B) Results of TLE Patient 03 in Patient-Specific Strategy';
    '(C) Results of FLE Patient 10 in Patient-Cross Strategy';
    '(D) Results of TLE Patient 11 in Patient-Cross Strategy'};

FaceColors = {[.7 .7 .7; .5 .5 .5; .3 .3 .3; .1 .1 .1];
    [1.0 0.8 0.8; 1.0 0.5 0.4; 0.8 0.2 0.2; 0.5 0.0 0.0];
    [0.7 0.85 1; 0.4 0.7 1.0; 0.0 0.45 0.8; 0.0 0.15 0.65];
    [0.7 1.0 0.7; 0.4 0.85 0.4; 0.1 0.6 0.2; 0.0 0.35 0.10];
    [1.0 0.8 0.8; 1.0 0.5 0.4; 0.8 0.2 0.2; 0.5 0.0 0.0];
    [0.6 1.0 1.0; 0.2 0.9 0.9; 0.0 0.7 0.7; 0.0 0.4 0.6];
    [0.8 0.7 1.0; 0.6 0.4 1.0; 0.4 0.0 0.8; 0.25 0.0 0.5];
    [1.0 0.9 0.6; 1.0 0.7 0.2; 0.9 0.5 0.0; 0.6 0.3 0.0]};

FaceColorsIndex = 3; %%%%%%%%%%%%%%%%%%%%%%%%%%%
YCenterMore = 3.5;

h = figure;
set(gcf,'outerposition',get(0,'screensize'))
NumSubFig = 4;

for SubFigNum = 1:NumSubFig
    subplot(NumRow,NumColumn,SubFigNum)
    b1 = bar(x-0.6, FleTle_InputForm{SubFigNum,1},BarWidth,'FaceColor',FaceColors{FaceColorsIndex,1}(1,:),'EdgeColor','none'); % 绘制 group1 数据
    XC1 = b1.XData; % 柱子的中心位置
    YC1 = b1.YData; % 柱子的高度
    for i = 1:length(labels)
        text(XC1(i),YC1(i)+YCenterMore,num2str(FleTle_InputForm{SubFigNum,1}(i,1)),'HorizontalAlignment','center',...
            'FontSize',6,'FontWeight','bold','Color',FaceColors{FaceColorsIndex,1}(1,:));
    end
    hold on;

    b2 = bar(x-0.2, FleTle_InputForm{SubFigNum,2},BarWidth,'FaceColor',FaceColors{FaceColorsIndex,1}(2,:),'EdgeColor','none'); % 绘制 group2 数据
    XC2 = b2.XData; % 柱子的中心位置
    YC2 = b2.YData; % 柱子的高度
    for i = 1:length(labels)
        text(XC2(i),YC2(i)+YCenterMore,num2str(FleTle_InputForm{SubFigNum,2}(i,1)),'HorizontalAlignment','center',...
            'FontSize',6,'FontWeight','bold','Color',FaceColors{FaceColorsIndex,1}(2,:));
    end
    hold on;

    b3 = bar(x+0.2, FleTle_InputForm{SubFigNum,3},BarWidth,'FaceColor',FaceColors{FaceColorsIndex,1}(3,:),'EdgeColor','none'); % 绘制 group2 数据
    XC3 = b3.XData; % 柱子的中心位置
    YC3 = b3.YData; % 柱子的高度
    for i = 1:length(labels)
        text(XC3(i),YC3(i)+YCenterMore,num2str(FleTle_InputForm{SubFigNum,3}(i,1)),'HorizontalAlignment','center',...
            'FontSize',6,'FontWeight','bold','Color',FaceColors{FaceColorsIndex,1}(3,:));
    end
    hold on;

    b4 = bar(x+0.6, FleTle_InputForm{SubFigNum,4},BarWidth,'FaceColor',FaceColors{FaceColorsIndex,1}(4,:),'EdgeColor','none'); % 绘制 group2 数据
    XC4 = b4.XData; % 柱子的中心位置
    YC4 = b4.YData; % 柱子的高度
    for i = 1:length(labels)
        text(XC4(i),YC4(i)+YCenterMore,num2str(FleTle_InputForm{SubFigNum,4}(i,1)),'HorizontalAlignment','center',...
            'FontSize',6,'FontWeight','bold','Color',FaceColors{FaceColorsIndex,1}(4,:));
    end
    hold on;

    set(gca,'FontSize',12,'FontWeight','bold')
    set(gca, 'XTick', x, 'XTickLabel', labels,'FontSize',10);
    lgd = legend({'Input Form 1', 'Input Form 2','Input Form 3', 'Input Form 4'},'FontSize',7,'Orientation','vertical','Location','north','box','off');
    lgd.ItemTokenSize = [8,0];
    ylabel('Magnitude');
    title(Tn{SubFigNum,1},'FontSize',16)
    ylim([0 108])
    xlim([1 15])
    ax = gca;
    ax.Box = 'off';
    ax.XAxisLocation = 'bottom';
    ax.YAxisLocation = 'left';
    grid on
    ax.GridLineStyle = '--';
    ax.GridAlpha = 0.15;
end
%saveas(h,'m4_For_Figure-7','epsc')
%saveas(h,'m4_For_Figure-7','fig')

saveas(h,'m4_For_Figure-7_v3','epsc')
saveas(h,'m4_For_Figure-7_v3','fig')
%%
toc
