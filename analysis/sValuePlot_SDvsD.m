%　選考尺度値をプロットする, SDvsD

exp = 'experiment_SDvsD';
sn = 'all';

mkdir(strcat('../../analysis_result/',exp,'/',sn,'/graph'));
load(strcat('../../analysis_result/',exp,'/',sn,'/sv.mat'));
load(strcat('../../analysis_result/',exp,'/',sn,'/selectionScale.mat'));

methodNum = 1:16;
graphColor = [[1 0 0]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0 1 0]; 
            [0.4660 0.6740 0.1880]; [0.310 0.7450 0.9330]; [0 0.4470 0.7410]; [1 0 1]];

% stimuli parameter
shape = "bunny";
light = ["area", "envmap"];
diffuse = ["0.1", "0.3", "0.5"];
roughness = ["0.05", "0.1", "0.2"];
method = num2cell(repmat(["SD", "D"],1,8));

% max, min value
vMax = max(reshape(max(max(selectionScale)), 1, 144));
vMin = min(reshape(min(min(selectionScale)), 1, 144));
vAbs = max(abs([vMin, vMax]));

% plot
for i =1:2  % light
    f = figure;
    for j = 1:3  % diffuse
        for k = 1:3  % roughness
            % plot
            subplot(3,3,3*(j-1)+k);
            hold on;
            
            for l = 1:8
                %plot(colorNum, sv(:,:,i,j,k,l,m), '--o','Color',graphColor(l,:),'MarkerFaceColor','auto');
                h = errorbar(methodNum(2*l-1:2*l), selectionScale(:,3,i,j,k,l), -selectionScale(:,1,i,j,k,l), selectionScale(:,2,i,j,k,l), '-o','Color',graphColor(l,:)); % 95%CI
                hold on;
            end

            % title
            title(strcat('diffuse:',diffuse(j),'  roughness:',roughness(k)));

            % axis
            xticks(methodNum);
            xticklabels(method);
            xlabel('彩色方法');
            xlim([0 17]);
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

