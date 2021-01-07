%% H-K効果と色度コントラストから光沢を回帰
clear all;

load('../../analysis_result/experiment_gloss/all/sv.mat');
load('../../analysis_result/experiment_gloss/all/glossEffect/glossEffect.mat');
load('../../mat/HKeffect/HKstimuli.mat');
load('../../mat/contrast/contrast.mat');
load('../../mat/contrast/contrastLab.mat');

paramnum = 108;
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

gloss = zeros(9, 108);
for i = 1:paramnum
    gloss(:,i) = sv(:,:,idx_gloss(i,1),idx_gloss(i,2),idx_gloss(i,3),idx_gloss(i,4),idx_gloss(i,5))';
end
gray = repmat(gloss(1,:),[8,1]);

%glossColor = gloss(2:9,:) - gray;

HK = HKstimuli(:,:,1);
% grayを含めたH-K効果, grayのH-K効果を1とする
HKall = ones(9,108);
HKall(2:9,:) = HK;
HKallZscore = zscore(HKall,0,1);

% grayを含めた色度コントラスト, u'v'L色度, grayの色度コントラストを0とする
contrastAll = zeros(9,108);
contrastAll(2:9,:) = repmat(contrast,[8 1]);
contrastAllZscore = zscore(contrastAll,0,1);

% zscore化
HKzscore = zscore(HK,0,1);
contrastLabZscore = zscore(contrastLab,0,1);

%% 光沢感回帰
% SD条件についてH-Kで回帰
y = reshape(gloss(:,1:2:108), [9*54,1]);
x1 = reshape(HKall(:,1:2:108), [9*54,1]);
X = [ones(size(x1)) x1];
[b_SD_HK,~,~,~,stats_SD_HK] = regress(y,X) % 回帰式 y = b(1) + b(2)*x1;

% D条件についてH-Kで回帰
y = reshape(gloss(:,2:2:108), [9*54,1]);
x1 = reshape(HKall(:,2:2:108), [9*54,1]);
X = [ones(size(x1)) x1];
[b_D_HK,~,~,~,stats_D_HK] = regress(y,X) % 回帰式 y = b(1) + b(2)*x1;

% D条件についてH-Kと色度差で回帰
x1 = reshape(HKallZscore(:,2:2:108), [9*54,1]);
x2 = reshape(contrastAllZscore(:,2:2:108), [9*54,1]);
X = [ones(size(x1)) x1 x2];
[b_D_HK_cont,~,~,~,stats_D_HK_cont] = regress(y,X)

% 全刺激について光沢をH-Kと色度差で回帰
y = reshape(gloss, [9*108,1]);
x1 = reshape(HKallZscore, [9*108,1]);
x2 = reshape(contrastAllZscore, [9*108,1]);
X = [ones(size(x1)) x1 x2];
[b_HK_cont,~,~,~,stats_HK_cont] = regress(y,X)

%% SD条件におけるH-Kを用いた光沢予測モデルをD条件に適用
% 実際の測定値との差分を見る
glossEstimated = b_SD_HK(1) + b_SD_HK(2)*HKall(:,2:2:108);
sa = gloss(:,2:2:108) - glossEstimated;



%{
%% Labコントラストで光沢効果量回帰
y = glossEffect';
x1 = zscore(mean(HK))';
x2 = zscore(mean(contrastLab))';
X = [ones(size(x1)) x1 x2];

[b_effect_Lab,~,~,~,stats_effect_Lab] = regress(y,X)

%% uvLコントラストで光沢効果量回帰
x2 = zscore(contrast)';
X = [ones(size(x1)) x1 x2];

[b_effect_uvL,~,~,~,stats_effect_uvL] = regress(y,X)

%% SD条件についてH-Kで光沢感回帰
glossColorSD = glossColor(:,1:2:108);
y = reshape(glossColorSD, [8*54,1]);
x1 = reshape(HK(:,1:2:108), [8*54,1]);
X = [ones(size(x1)) x1];

[b_SD,~,~,~,stats_SD] = regress(y,X)

%{
% 色相ごとに見る
color = ["0", "45", "90", "135", "180", "225", "270", "315"];
coef = zeros(8,2);
stat_hue = zeros(8,4);
for i = 1:8
    y = reshape(glossColorSD(i,:),[54,1]);
    x1 = reshape(HK(i,1:2:108), [54,1]);
    X = [ones(size(x1)), x1];
    [b,~,~,~,stats] = regress(y,X)
    coef(i,:) = b';
    stat_hue(i,:) = stats;
    
    figure;
    scatter(x1,y);
    title(color(i));
end
%}

%% SD条件についてH-Kで効果量回帰
y = zscore(glossEffect(1:2:108))';
x1 = zscore(mean(HK(:,1:2:108)))';
X = [ones(size(x1)) x1];

[b_effect_HK,~,~,~,stats_effect_HK] = regress(y,X)
%}