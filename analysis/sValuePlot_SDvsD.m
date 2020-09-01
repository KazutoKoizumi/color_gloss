%　選考尺度値をプロットする, SDvsD

exp = 'experiment_SDvsD';
sn = 'koizumi';

load(strcat('../../analysis_result/',exp,'/',sn,'/sv.mat'));
load(strcat('../../analysis_result/',exp,'/',sn,'/selectionScale.mat'));

methodNum = [1 2];
graphColor = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];

% stimuli parameter
shape = "bunny";
light = ["area", "envmap"];
diffuse = ["0.1", "0.3", "0.5"];
roughness = ["0.05", "0.1", "0.2"];
method = ["SD", "D"];

% max, min value
vMax = max(reshape(max(max(selectionScale)), 1, 18));
vMin = min(reshape(min(min(selectionScale)), 1, 18));
vAbs = max(abs([vMin, vMax]));

se = 1.96;
% plot
for i =1:2  % light
    f = figure
    for j = 1:3  % diffuse
        for k = 1:3  % roughness
            % plot
            subplot(3,3,3*(j-1)+k);
            hold on;
            %plot(colorNum, sv(:,:,i,j,k,l,m), '--o','Color',graphColor(l,:),'MarkerFaceColor','auto');
            h = errorbar(methodNum, selectionScale(:,3,i,j,k), -se*selectionScale(:,1,i,j,k), se*selectionScale(:,2,i,j,k), '-o','Color',graphColor(1,:)); % 95%CI
            hold on;

            % title
            title(strcat('diffuse:',diffuse(j),'  roughness:',roughness(k)));

            % axis
            xticks(methodNum);
            xticklabels({'SD', 'D'});
            xlabel('彩色方法');
            xlim([0 3]);
            ylabel('選考尺度値');
            ylim([-vAbs-1, vAbs+1]);

            %{
            % legend
            lgd = legend(h, {'0.1', '0.3', '0.5'});
            lgd.NumColumns = 3;
            lgd.Title.String = 'roughness';
            lgd.Title.FontWeight = 'normal';
            %}

            hold off;
        end
    end
    sgtitle(strcat('shape:',shape,'   light:',light(i)));


    f.WindowState = 'maximized';
    graphName = strcat(shape,'_',light(i),'_95_new.png');
    fileName = strcat('../../analysis_result/',exp,'/','/',sn,'/graph/',graphName);
    saveas(gcf, fileName);
    %}
end

