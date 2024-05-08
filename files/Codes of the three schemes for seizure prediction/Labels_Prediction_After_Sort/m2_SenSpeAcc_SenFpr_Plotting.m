clc
clear
close all
tic

%%
load('m1_SSA_SF_MeanStd.mat')
F1Sort = load('m4_F1Sort.mat');
F1Sort = struct2cell(F1Sort);
F1Sort = F1Sort{1,1};
WindowIndex = [10,15,20]; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PatientID = {'01','03','04','05','09','10','11','12','14',...
%     '15','16','17','18','19','20','21'};

PatientID = {'18'};

%% Results of the sorted channels are plotted
SegColorLine = {'r-.D','m-.O','k-.S'};
SegMarkerFace = {'r','m','k'};
NumRow = 3;
NumColumn = 1;
[NumWindowType,NumPatient] = size(MeanStd);
for WindowTypeNum = 1:NumWindowType
    NewFile = strcat('m2_SenSpeAcc_SenFpr',filesep,...
        'WindowLength_',int2str(WindowIndex(WindowTypeNum)),'-second',filesep);
    mkdir(NewFile)

    for PatientNum = 1:NumPatient
        h = figure;
        set(gcf,'outerposition',get(0,'screensize'));

        TempMeanStd = [];
        TempMeanStd = MeanStd{WindowTypeNum,PatientNum};
        TempMeanStd(:,[7,8]) = [];
        [NumChanType,NumMetric] = size(TempMeanStd);
        NumMetricType = NumMetric/2;
        for MetricTypeNum = 1:NumMetricType
            if MetricTypeNum < 4
                subplot(NumRow,NumColumn,2)
                errorbar(TempMeanStd(:,2*MetricTypeNum-1),TempMeanStd(:,2*MetricTypeNum),...
                    SegColorLine{1,MetricTypeNum},'MarkerSize',8,...
                    'MarkerFaceColor',SegMarkerFace{1,MetricTypeNum});
                hold on
                grid on
                ax = gca;
                ax.GridLineStyle = '--';
                ax.GridAlpha = 0.15;
                ax.XTick = [1:NumChanType];
                ax.FontWeight = 'bold';
                xlim([0.9 NumChanType+0.1])
                ylim([20 100])
                ylabel('Magnitude (%)','Fontsize',14)
                title('Results at the segment-based level','Fontsize',14)
                legend({'Sensitivity','Specificity','Accuracy'},'Location','Best')
            elseif MetricTypeNum == NumMetricType
                subplot(NumRow,NumColumn,3)
                x = 1:NumChanType;
                yyaxis right
                errorbar(TempMeanStd(:,2*MetricTypeNum-1),TempMeanStd(:,2*MetricTypeNum),...
                    'b-.O','MarkerFaceColor','b','MarkerSize',8);
                ax.YColor = 'b';
                ylabel('FPR (/h)','Fontsize',14);
                ylim([0 1])
                xlim([0.9 NumChanType+0.1])
                ax.FontWeight = 'bold';
                grid on
                title('Results at the event-based level','Fontsize',14)
                xlabel('Number of channels','Fontsize',14)
            else
                subplot(NumRow,NumColumn,3)
                yyaxis left
                errorbar(TempMeanStd(:,2*MetricTypeNum-1),TempMeanStd(:,2*MetricTypeNum),...
                    'r-.D','MarkerFaceColor','r','MarkerSize',8);
                ax = gca;
                ax.YColor = 'r';
                ylabel('Sensitivity (%)','Fontsize',14);
                ylim([0 100])
                xlim([0.9 NumChanType+0.1])
                ax.FontWeight = 'bold';
                ax.XTick = [1:NumChanType];
                grid on
                legend({'Sensitivity','FPR'},'Location','Best')
            end
        end

        %%%%%%%%%%%%%%%%%%%%%
        TempF1Sort = [];
        TempF1Sort = F1Sort{13,1};
        F1SortMean = [];
        for ChanTypeNum = 1:NumChanType
            F1SortMean(ChanTypeNum,1) = mean(TempF1Sort(1:ChanTypeNum));
        end
        F1SortMean = roundn(F1SortMean,-3);
        subplot(NumRow,NumColumn,1)
        plot(1:NumChanType,F1SortMean,'k--^','LineWidth',1.5,...
            'MarkerFaceColor','g','MarkerEdgeColor','k','MarkerSize',12)
        grid on
        ylabel('Magnitude','Fontsize',14)
        title('Mean of the higher F1 scores from the corresponding channels','Fontsize',14)
        ax = gca;
        ax.GridLineStyle = '--';
        ax.GridAlpha = 0.15;
        ax.XTick = [1:NumChanType];
        ax.FontWeight = 'bold';
        xlim([0.9 NumChanType+0.1])

        FigRoute = strcat(NewFile,'Patient_',PatientID{1,PatientNum});
        saveas(h,[FigRoute,'.png'])
        %saveas(h,[FigRoute,'.epsc'])
        close all
    end
end

%%
toc
