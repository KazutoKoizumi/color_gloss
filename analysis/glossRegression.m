%% H-K効果と色度コントラストから光沢を回帰
clear all;

load('../../analysis_result/experiment_gloss/all/sv.mat');
load('../../analysis_result/experiment_gloss/all/glossEffect/glossEffect.mat');
load('../../mat/HKeffect/HKstimuli.mat');
load('../../mat/contrast/contrast.mat');
load('../../mat/contrast/contrastLab.mat');

gloss = reshape(sv, [9 108]);
gray = repmat(gloss(1,:),[8,1]);
glossColor = gloss(2:9,:) - gray;
HK = HKstimuli(:,:,1);

% zscore化
HKzscore = zscore(HK,0,1);
contrastLabZscore = zscore(contrastLab,0,1);

%% 光沢感回帰
% y : gloss
% x : HK, contrastLab
y = reshape(glossColor, [8*108,1]);
x1 = reshape(HK, [8*108,1]);
x2 = reshape(contrastLabZscore, [8*108,1]);
X = [ones(size(x1)) x1 x2];

[b,~,~,~,stats] = regress(y,X)

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

%% SD条件についてH-Kで効果量回帰
y = zscore(glossEffect(1:2:108))';
x1 = zscore(mean(HK(:,1:2:108)))';
X = [ones(size(x1)) x1];

[b_effect_HK,~,~,~,stats_effect_HK] = regress(y,X)