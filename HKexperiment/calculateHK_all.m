%% 全被験者の応答結果をマージしてプロット
clear all;

exp = 'experiment_HK';
sn = ["koizumi", "nohira", "totsuka", "taniguchi", "kosone", "saeki"]; 
snID = ["A", "B", "C", "D", "E", "F", 'All'];
N = size(sn,2); % 被験者数
trial = 5; % 被験者一人あたりの一種の刺激に対する試行数
graphColor = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]; [0.3010 0.7450 0.9330]; [0 0 0]];

mkdir(strcat('../../analysis_result/',exp,'/all'));

% size
t_sz = 22;
sgt_sz = 20;
label_sz = 18;
ax_sz = 16;
lgd_sz = 16;

%% 全結果をまとめたテーブル HKtable を作成
HKindividual = zeros(72,5*N); % 各個人のH-K効果（5試行分）
HKindividual_mean = zeros(72,N); % 各個人のH-K効果平均（5試行分）
load(strcat('../../analysis_result/',exp,'/',sn(1),'/data.mat'));
HKtable = data(:,1:3);
for s = 1:N % 被験者数
    load(strcat('../../analysis_result/',exp,'/',sn(s),'/data.mat'));
    HKindividual(:,5*(s-1)+1:5*s) = data.HK;
    HKtable = addvars(HKtable,data.HK,'NewVariableNames',strcat('subject_',snID(s)));
end
for s = 1:N
    load(strcat('../../analysis_result/',exp,'/',sn(s),'/data.mat'));
    HKindividual_mean(:,s) = data.HKave;
    HKtable = addvars(HKtable,data.HKave,'NewVariableNames',strcat('subject_',snID(s),'_mean'));
end
for s = 1:N
    load(strcat('../../analysis_result/',exp,'/',sn(s),'/data.mat'));
    HKtable = addvars(HKtable,data.HKzscore,'NewVariableNames',strcat('subject_',snID(s),'_zscore'));
end
% 全被験者平均
HKtable.HKmean = mean(HKindividual,2);
% z-score化
HKzscore = zeros(9*8,1);
for i =1:9
    HKzscore(8*(i-1)+1:8*i) = zscore(HKtable.HKmean(8*(i-1)+1:8*i));
end
HKtable = addvars(HKtable,HKzscore);

%% プロット
axisColorNum = [1 2 3 4 5 6 7 8];
% 最大・最小値を求めておく
v = [min(HKindividual_mean,[],'all'),max(HKindividual_mean,[],'all')];
ylim_v = [0.8, v(2); 0.8, 4; 0.8, 3];
y_max = max(ylim_v(:,2));

figure;
for i = 1:3 % lum
    for j = 1:3 % sat
        n= 24*(i-1) + 8*(j-1);
        subplot(3,3,3*(i-1)+j);
        hold on;
        
        for s = 1:N+1
            if s <= N
                ind_table = HKtable(:,9+s);
                h(s) = plot(axisColorNum,HKtable.(9+s)(n+1:n+8)','--o','Color',graphColor(s,:), 'MarkerSize',4);
            elseif s == N+1
                h(s) = plot(axisColorNum,HKtable.HKmean(n+1:n+8)','-o','Color',graphColor(s,:));
                h(N+1).LineWidth = 1.5;
            end
        end
        ax = gca;
        
        % title
        %title(strcat('lum:',num2str(i),'  sat:',num2str(j)),'FontSize',sgt_sz);
        
        % axis
        xticks(axisColorNum);
        %xticklabels({'red', 'orange', 'yellow', 'green', 'blue-green', 'cyan', 'blue', 'magenta'});
        xticklabels({'0', '45', '90', '135', '180', '225', '270', '315'});
        xlabel('色相（degree）','FontSize',label_sz);
        xlim([0 9]);
        ylabel('H-K効果の大きさ','FontSize',label_sz);
        ylim([ylim_v(i,1),y_max]);
        ax.FontSize = ax_sz;
        
        % legend
        %lgd = legend(h,snID);
        %lgd.Title.String = 'subject';
        %lgd.Title.FontWeight = 'normal';
        %lgd.Location = 'eastoutside';
        
        set(gca, "FontName", "Noto Sans CJK JP");
        
        hold off;
    end
end
%sgtitle('H-K効果の大きさ')
        
% 保存
save(strcat('../../analysis_result/',exp,'/all/HKtable.mat'),'HKtable');
                
%% 全被験者データのプロット
value_HK = HKtable.HKmean;

label_sz = 16;
ax_sz = 14;
sat_name = ["0.032", "0.039", "0.046"];
figure;
for i = 1:3 % lum
    subplot(3,1, i);
    hold on;
    for j = 1:3 % sat
        idx = 24*(i-1)+8*(j-1)+1;
        h(j) = plot(axisColorNum, value_HK(idx:idx+(8-1)), '-o','Color',graphColor(j,:));
    end
    ax = gca;
    
    xticks(axisColorNum);
    %xticklabels({'red', 'orange', 'yellow', 'green', 'blue-green', 'cyan', 'blue', 'magenta'});
    xticklabels({'0', '45', '90', '135', '180', '225', '270', '315'});
    %xlabel('Hue（degree）','FontSize',label_sz);
    xlim([0 9]);
    %ylabel('H-K Effect','FontSize',label_sz);
    ylim([0, 4]);
    ax.FontSize = ax_sz;
    
    % legend
    %lgd = legend(h, sat_name);
    %lgd.Title.String = 'Saturation';
    %lgd.Title.FontWeight = 'normal';
    %lgd.Location = 'eastoutside';
end