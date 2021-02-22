%% H-K効果を説明する線形回帰モデルの作成、ハイライトに対応するH-K効果の算出

load(strcat('../../analysis_result/experiment_HK/all/HKtable.mat'));
exp = 'experiment_HK';
snID = ["A", "B", "C", "D", "E", "F", 'All'];
colorName = ["red","orange","yellow","green","blue-green","cyan","blue","magenta"];
colorDeg = ["0", "45", "90", "135", "180", "225", "270", "315"];
N = 6;
diffuseVar = ["0.1", "0.3", "0.5"];
diffuseN = 3;
roughN = 3;

% size
t_sz = 22;
sgt_sz = 20;
label_sz = 14;
ax_sz = 16;
lgd_sz = 16;

% パラメータのインデックス
count = 1;
idx = zeros(108,5);
for i = 1:3 % shape
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                for m = 1:2 % SD or D
                    idx(count,:) = [i, j, k, l, m];
                    count = count + 1;
                end
            end
        end
    end
end
for i = 1:diffuseN
    %idx_shape(:,i) = find(idx(:,1)==i);
    idx_diffuse(:,i) = find(idx(:,3)==i);
    idx_rough(:,i) = find(idx(:,4)==i);
    for j = 1:2
        %idx_shape_method(:,3*(j-1)+i) = find(idx(:,1)==i & idx(:,5)==j);
        idx_diffuse_method(:,diffuseN*(j-1)+i) = find(idx(:,3)==i & idx(:,5)==j);
        idx_rough_method(:,roughN*(j-1)+i) = find(idx(:,4)==i & idx(:,5)==j);
    end
end

%% 輝度について平均化
HKlum = HKtable(1:24,2:3); % 輝度に関して平均化したH-K効果
for s = 1:N % subject
    subjectData = zeros(24,5);
    for j = 1:24
        temp = zeros(3,5);
        for k = 1:3 % luminance parameter
            temp(k,:) = HKtable.(3+s)(24*(k-1)+j,:);
        end
        subjectData(j,:) = mean(temp);
    end
    HKlum = addvars(HKlum,subjectData,'NewVariableNames',strcat('subject_',snID(s)));
end
% 被験者ごとの平均
for s = 1:N
    HKlum = addvars(HKlum,mean(HKlum.(2+s),2),'NewVariableNames',strcat('subject_',snID(s),'_mean'));
end
% 被験者ごとのz-score
for s = 1:N
    HKlumIndZscore = zeros(3*8,1);
    for i = 1:3 % sat
        HKlumIndZscore(8*(i-1)+1:8*i) = zscore(HKlum.(2+N+s)(8*(i-1)+1:8*i));
    end
    HKlum = addvars(HKlum,HKlumIndZscore,'NewVariableNames',strcat('subject_',snID(s),'_zscore'));
end
% 全被験者平均
HKlum.HKmean = mean(HKlum{:,3:2+N},2);
% z-score化
HKzscore = zeros(3*8,1);
for i =1:3
    HKzscore(8*(i-1)+1:8*i) = zscore(HKlum.HKmean(8*(i-1)+1:8*i));
end
HKlum.HKzscore = HKzscore;

%% 彩度を説明変数としてH-K効果の回帰式を作成
Rsq = zeros(1,8);
cf = zeros(2,8);
figure;
for i = 1:8
    
    %{
    % 全応答結果を用いて回帰
    saturation = repmat(HKlum.sat(HKlum.color==colorName(i)), [5*N 1]);
    HK = zeros(3*5*N,1);
    for j = 1:N % subject
        HK_individual = HKlum.(2+j)(repmat(HKlum.color==colorName(i),[1 5]));
        HK(3*5*(j-1)+1:3*5*j) = HK_individual;
    end
    
    X = [ones(length(saturation),1) saturation];
    b = X\HK
    yHK = X*b;
    Rsq(1,i) = 1 - sum((HK - yHK).^2)/sum((HK - mean(HK)).^2); % 決定係数
    %}
    
    %{
    % 被験者ごとに試行回数の平均をとって回帰
    saturation = repmat(HKlum.sat(HKlum.color==colorName(i)), [N 1]);
    HK = zeros(3*N,1);
    for j = 1:N % subject
        HK_individual = HKlum.(2+N+j)(HKlum.color==colorName(i));
        HK(3*(j-1)+1:3*j) = HK_individual;
    end
    %}
    
    % 被験者・試行回数に関しての平均で回帰
    saturation = HKlum.sat(HKlum.color==colorName(i));
    HK = HKlum.HKmean(HKlum.color==colorName(i));
    
    X = [ones(length(saturation),1) saturation];
    cf(:,i) = X\HK;
    yHK = X*cf(:,i);
    Rsq(1,i) = 1 - sum((HK - yHK).^2)/sum((HK - mean(HK)).^2); % 決定係数
    
    %{
    % プロット
    scatter(saturation,HK);
    hold on;
    plot(saturation,yHK,'--');
    xlabel('saturation')
    ylabel('H-K effect')
    title(strcat('H-K effect',{' '},colorName(i)));
    %}
    
    % まとめて1枚にプロット
    subplot(4,2,i);
    scatter(saturation,HK);
    hold on;
    lg = strcat(num2str(round(cf(1,i),3,'significant')),'+',num2str(round(cf(2,i),3,'significant')),'x, R^2=',num2str(round(Rsq(i),2,'significant')));
    h = plot(saturation,yHK,'--');
    ax = gca;
    legend(h,lg,'Location','northwest','FontSize',lgd_sz);
    xlabel('彩度','FontSize',label_sz)
    ylabel('H-K効果','FontSize',label_sz)
    xlim([0.03 0.047]);
    ylim([1.5 3]);
    title(strcat(colorDeg(i),' degree'),'FontSize',sgt_sz);
    ax.FontSize = ax_sz;
    set(gca, "FontName", "Noto Sans CJK JP");
    hold off;

end
cf
save('../../mat/HKeffect/cf.mat','cf');
save('../../mat/HKeffect/Rsq.mat','Rsq');

% プロット

%% ハイライト・非ハイライト領域の彩度からそれぞれのH-K効果を算出
load('../../mat/highlight/highlightSat.mat');
HKstimuli = zeros(8,108,2);
for i = 1:108 % stimuli
    for j = 1:8 % color
        HKstimuli(j,i,1) = cf(1,j) + cf(2,j)*highlightSat(1,i); % ハイライト
        HKstimuli(j,i,2) = cf(1,j) + cf(2,j)*highlightSat(2,i); % 非ハイライト
    end
end
save('../../mat/HKeffect/HKstimuli.mat','HKstimuli');

% ハイライト領域のH-Kを色相ごとにプロット
x = 1:8;
figure;
for i = 1:108
    plot(x,HKstimuli(:,i,1)','--o','Color',[0 0.4470 0.7410],'MarkerSize',4);
    hold on;
end
plot(x,mean(HKstimuli(:,:,1),2)', '-o','Color',[1 0 0],'MarkerFaceColor',[1 0 0],'LineWidth',2,'MarkerSize',8);
xlim([0 9]);
xticks(x);
xticklabels({'0', '45', '90', '135', '180', '225', '270', '315'});
xlabel('色相 (degree)');
ylabel('H-K効果の大きさ');
set(gca, "FontName", "Noto Sans CJK JP");

% ハイライト領域のH-Kを色相ごとにプロット, SD,D条件でわける
figure;
HK_SD_D = zeros(8,54,2);
label_sz = 20;
ax_sz = 18;
for m = 1:2
    subplot(1,2,m);
    HK_SD_D(:,:,m) = HKstimuli(:,m:2:108,1);
    for i = 1:54
        plot(x,HK_SD_D(:,i,m)','--o','Color',[0 0.4470 0.7410],'MarkerSize',4);
        hold on;
    end
    plot(x,mean(HK_SD_D(:,:,m),2)', '-o','Color',[1 0 0],'MarkerFaceColor',[1 0 0],'LineWidth',2,'MarkerSize',8);
    ax = gca;
    xlim([0 9]);
    ylim([1.2 3]);
    xticks(x);
    xticklabels({'0', '45', '90', '135', '180', '225', '270', '315'});
    xlabel('色相 (degree)','FontSize',label_sz);
    ylabel('H-K効果の大きさ','FontSize',label_sz);
    ax.FontSize = ax_sz;
    set(gca, "FontName", "Noto Sans CJK JP");
end

% 彩色方法・拡散反射率ごとにハイライト領域のH-K効果の大きさをプロット
HK_HL = mean(HKstimuli(:,:,1));
[HK_diffuse_method,HK_diffuse_method_mean] = getMean(3*2,idx_diffuse_method,HK_HL);
x_label = '拡散反射率';
y_label = 'H-K効果';
t = 'diffuseと彩色方法ごとのH-K効果';
xtick_param = repmat(diffuseVar,1,2);
f = scatterPlot(108,3*2,HK_diffuse_method,HK_diffuse_method_mean,xtick_param,x_label,y_label,t);
hold on;
l = xline(3.5, '--');
ylim([1 2.45]);
%text(1.75,2.4,'SD');
%text(5.25,2.4,'D');
hold off;

%% 輝度平均取らない場合
%{
for i = 1:8 % color
    luminance = repmat(HKtable.lum(HKtable.color==colorName(i)), [30 1]);
    saturation = repmat(HKtable.sat(HKtable.color==colorName(i)), [30 1]);
    HK = zeros(9*30,1);
    for j = 1:6 % subject
        HK_individual = HKtable.(3+j)(repmat(HKtable.color==colorName(i),[1 5]));
        HK(9*5*(j-1)+1:9*5*j) = HK_individual;
    end
    
    X = [ones(size(luminance)), luminance, saturation, luminance.*saturation];
    [b,~,~,~,stats] = regress(HK,X)
    
    % プロット
    figure;
    scatter3(luminance,saturation,HK,'filled');
    hold on;
    lumFit = min(luminance):(max(luminance)-min(luminance))/10:max(luminance);
    satFit = min(saturation):(max(saturation)-min(saturation))/10:max(saturation);
    [LUMFIT,SATFIT] = meshgrid(lumFit,satFit);
    HKFIT = b(1) + b(2)*LUMFIT + b(3)*SATFIT + b(4)*LUMFIT.*SATFIT;
    mesh(LUMFIT,SATFIT,HKFIT)
    xlabel('luminance');
    ylabel('saturation');
    zlabel('H-K effect');
    title(strcat('H-K効果  ',colorName(i)));
    %view(50,10);
    hold off
end
%}


%% 平均を取る関数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input
%  paramNum : パラメータの個数
%  idx : パラメータのインデックス
%  value : 値

% Output
%  param : パラメータごとに値をわける（列がパラメータ）
%  param_mean : パラメータごとの平均
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [param, param_mean] = getMean(paramNum,idx,value)
    
    param = zeros(108/paramNum, paramNum);
    for i = 1:108/paramNum
        for j = 1:paramNum
            param(i,j) = value(idx(i,j));
        end
    end
    
    param_mean = mean(param);
    
end

%% 散布図プロット用の関数
% roughness,diffuse,method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input
%  paramAll : 全パラメータの組み合わせの数（条件数）
%  paramNum : パラメータの個数
%  value : 値全て
%  value_mean : 平均値
%  x_tick : x軸の軸ラベル
%  x_label : x軸のラベル
%  y_label : y軸のラベル
%  t : タイトル
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f = scatterPlot(paramAll,paramNum,value,value_mean,x_tick,x_label,y_label,t)
    
    figure;
    x_mean = 1:paramNum;

    %{
    x = reshape(repmat(x_mean,paramAll/paramNum,1),1,paramAll);
    y = reshape(value, 1, paramAll);
    scatter(x,y);
    hold on;
    scatter(x_mean,value_mean,72,[1 0 0],'filled');
    %}

    % diffuse,method以外のパラメータが同じ刺激を結ぶ
    for i = 1:18
        for m = 1:2
            plot(x_mean(3*(m-1)+1:3*m),value(i,3*(m-1)+1:3*m),'--o','Color',[0 0.4470 0.7410]);
            hold on;
        end
    end
    plot(x_mean(1:3),value_mean(1,1:3),'-o','Color',[1,0,0],'LineWidth',1.5);
    plot(x_mean(4:6),value_mean(1,4:6),'-o','Color',[1,0,0],'LineWidth',1.5);
    scatter(x_mean,value_mean,72,[1 0 0],'filled');
    
    % グラフの設定
    xlim([0 paramNum+1]);
    xticks(x_mean);
    xticklabels(x_tick);
    xlabel(x_label);
    ylabel(y_label);
    set(gca, "FontName", "Noto Sans CJK JP");
    %title(t, 'FontSize',13);
    hold off;
    
    f = 1;
end
                