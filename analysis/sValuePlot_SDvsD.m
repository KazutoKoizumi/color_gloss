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

% size
t_sz = 22;
sgt_sz = 20;
label_sz = 18;
ax_sz = 16;
lgd_sz = 16;

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

%% SDの勝率plot
load(strcat('../../data/',exp,'/',sn,'/winTable/mtx'));
axisColor = 1:8;
count = 0;
count_hue = 0
p = zeros(1,2*3*3*8);
p_hue = zeros(8,2*3*3);
for i =1:2  % light
    f = figure;
    for j = 1:3  % diffuse
        for k = 1:3  % roughness
            count_hue = count_hue + 1;
            % plot
            subplot(3,3,3*(j-1)+k);
            hold on;
            
            prob = zeros(1,8);
            for l = 1:8
                count = count + 1;
                %plot(colorNum, sv(:,:,i,j,k,l,m), '--o','Color',graphColor(l,:),'MarkerFaceColor','auto');
                prob(l) = mtx(1,2,i,j,k,l);
                p(count) = mtx(1,2,i,j,k,l);
                p_hue(l,count_hue) = mtx(1,2,i,j,k,l);
            end
            scatter(axisColor,prob);
            ax = gca;

            % title
            %title(strcat('diffuse:',diffuse(j),'  roughness:',roughness(k)));

            % axis
            xticks(axisColor);
            xticklabels({'0', '45', '90', '135', '180', '225', '270', '315'});
            xlabel('色相（degree）','FontSize',label_sz);
            xlim([0 9]);
            ylabel('SD条件の勝率','FontSize',label_sz);
            ylim([0, 1.0]);
            yline(0.5, '--');
            ax.FontSize = ax_sz;

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
    %sgtitle(strcat('shape:',shape,'   light:',light(i)));
    %}
end
p_mean = mean(p);
p_mean_hue = mean(p_hue,2);

% ブートストラップ
B = 10000;
bst_p = bootstrp(B,@mean,p');
% 95%信頼区間
ubi = round(B*97.5/100);
lbi = round(B*2.5/100);
range95 = [abs(p_mean-bst_p(lbi)),abs(p_mean-bst_p(ubi))];
figure;
errorbar(1,p_mean,range95(1),range95(2),'-o');
ylim([0.5 1]);
ylabel('SD条件の勝率の平均値');

% 色相ごとに平均を見る
bst_p_hue = zeros(8,B);
range95_hue = zeros(8,2);
for l = 1:8
    bst_p_hue(l,:) = bootstrp(B,@mean,p_hue(l,:)');
end
bst_p_hue_sort = sort(bst_p_hue,2);
for l = 1:8
    range95_hue(l,:) = [abs(p_mean_hue(l)-bst_p_hue_sort(l,lbi)),abs(p_mean_hue(l)-bst_p_hue_sort(l,ubi))];
end
figure;
errorbar(axisColor,p_mean_hue,range95_hue(:,1),range95_hue(:,2),'o')
xticks(axisColor);
xticklabels({'0', '45', '90', '135', '180', '225', '270', '315'});
xlabel('色相（degree）');
xlim([0 9]);
ylabel('SD条件の勝率の平均');
ylim([0, 1]);
yline(0.5, '--');
set(gca, "FontName", "Noto Sans CJK JP");
%title('SD条件の勝率の色相ごとの平均');