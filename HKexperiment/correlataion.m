%% 光沢感とH-K効果との相関係数を求める
clear all;

sn1 = 'all'; % 実験1被験者名
sn2 = 'all'; % 実験2被験者名
sn = ["koizumi", "nohira", "totsuka", "taniguchi", "kosone", "saeki"]; 

colorName = ["red","orange","yellow","green","blue-green","cyan","blue","magenta"];

load(strcat('../../analysis_result/experiment_gloss/',sn1,'/sv.mat'));
load('../../analysis_result/experiment_HK/all/HKtable.mat');

load('../../mat/patch/patchLuminance.mat');
load('../../mat/patch/patchSaturation.mat');

paramnum = 3*2*3*3*2;
idx_gloss = zeros(paramnum, 5);
count = 1;
for i = 1:3 % shape
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                for m = 1:2 % SD or D
                    idx_gloss(count,:) = [i, j, k, l, m];
                    count = count + 1;
                end
            end
        end
    end
end

idx_method_diffuse = zeros(18,6);
for i = 1:2
    for j = 1:3
        idx_method_diffuse(:,3*(i-1)+j) = find(idx_gloss(:,5)==i & idx_gloss(:,3)==j);
    end
end

sValue = zeros(9, paramnum);
for i = 1:paramnum
    sValue(:,i) = sv(:,:,idx_gloss(i,1),idx_gloss(i,2),idx_gloss(i,3),idx_gloss(i,4),idx_gloss(i,5))';
end

%% 相関係数
% 各刺激のハイライト領域のH-K効果との相関係数を見る
load('../../mat/HKeffect/HKstimuli.mat');
%R = zeros(108,9); 
R = zeros(1,108);
for i = 1:108 % 実験1パラメータ
    gloss = sValue(2:9,i)';
    %{
    for j = 1:9 % 実験2パラメータ
        HK = HKtable.HKzscore(8*(j-1)+1:8*j)';
        r = corrcoef(gloss, HK);
        R(i,j) = r(1,2);
    end
    %}
    HK = HKstimuli(:,i,1)';
    r = corrcoef(gloss, HK);
    R(i) = r(1,2);
end

% 相関係数のヒートマップ
figure;
heatmap(R, 'ColorLimits',[-1 1]);
colormap('jet');
xlabel('光沢感パラメータ');

%% 相関係数整理
% SD,D,diffuseパラメータでわける
R_method_diffuse = R(idx_method_diffuse);
% プロット
figure;
x = reshape(repmat([1,2,3,4,5,6], [18,1]),[1,6*18]);
y = reshape(R_method_diffuse, [1,108]);
scatter(x,y);
hold on;
x_mean = [1,2,3,4,5,6];
y_mean = mean(R_method_diffuse);
scatter(x_mean,y_mean,72,[1 0 0],'filled');
% グラフの設定
xlim([0 7]);
xticks(x_mean);
xticklabels({'0.1', '0.3', '0.5', '0.1', '0.3', '0.5'});
xlabel('diffuse');
ylabel('相関係数');
title('diffuseと彩色方法ごとの相関係数');
xline(3.5, '--');
ylim([-1 1.3]);
text(1.75,1.2,'SD');
text(5.25,1.2,'D');
hold off;

%% 相関係数の分散分析（diffuse,methodの主効果を見る）