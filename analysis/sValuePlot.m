%　選考尺度値をプロットする

exp = 'experiment_gloss';
sn = 'all_N3';

mkdir(strcat('../../analysis_result/',exp,'/',sn,'/graph'));
load(strcat('../../analysis_result/',exp,'/',sn,'/sv.mat'));
load(strcat('../../analysis_result/',exp,'/',sn,'/selectionScale.mat'));

colorNum = [1 2 3 4 5 6 7 8 9];
colorNum = [colorNum-0.1; colorNum; colorNum+0.1];
colorName = ["gray","red","orange","yellow","green","blue-green","cyan","blue","magenta"];
graphColor = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];

% stimuli parameter
shape = ["bunny", "dragon", "blob"];
light = ["area", "envmap"];
diffuse = ["0.1", "0.3", "0.5"];
roughness = ["0.05", "0.1", "0.2"];
method = ["SD", "D"];

% max, min value
vMax = max(reshape(max(max(selectionScale)), 1, 108));
vMin = min(reshape(min(min(selectionScale)), 1, 108));
vAbs = max(abs([vMin, vMax]));

se = 1.96;
% plot
for i =1:3  % shape
    for j = 1:2  % light
        f = figure;
        for k = 1:3  % diffuse
            for m = 1:2  % method
                % plot
                subplot(3,2,2*(k-1)+m);
                hold on;
                for l = 1:3  % roughness
                    %plot(colorNum, sv(:,:,i,j,k,l,m), '--o','Color',graphColor(l,:),'MarkerFaceColor','auto');
                    h(l) = errorbar(colorNum(l,1), selectionScale(1,3,i,j,k,l,m), -se*selectionScale(1,1,i,j,k,l,m), se*selectionScale(1,2,i,j,k,l,m), '-o','Color',graphColor(l,:));
                    errorbar(colorNum(l,2:9), selectionScale(2:9,3,i,j,k,l,m), -se*selectionScale(2:9,1,i,j,k,l,m), se*selectionScale(2:9,2,i,j,k,l,m), '-o','Color',graphColor(l,:)); % 68%CI
                    hold on;
                end
                
                % title
                title(strcat(method(m),'  diffuse:',diffuse(k)));
                
                % axis
                xticks(colorNum(2,:));
                xticklabels({'gray', 'red', 'orange', 'yellow', 'green', 'blue-green', 'cyan', 'blue', 'magenta'});
                xlabel('色相');
                xlim([0 10]);
                ylabel('選考尺度値');
                ylim([-vAbs-1, vAbs+1]);
                
                % legend
                lgd = legend(h, {'0.1', '0.3', '0.5'});
                lgd.NumColumns = 3;
                lgd.Title.String = 'roughness';
                lgd.Title.FontWeight = 'normal';
                
                hold off;
            end
        end
        sgtitle(strcat('shape:',shape(i),'   light:',light(j)));
        
        
        f.WindowState = 'maximized';
        graphName = strcat(shape(i),'_',light(j),'_95.png');
        fileName = strcat('../../analysis_result/',exp,'/','/',sn,'/graph/',graphName);
        saveas(gcf, fileName);
        %}
    end
end

