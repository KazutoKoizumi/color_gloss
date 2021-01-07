%% H-K効果と色度コントラストから光沢を回帰
clear all;

load('../../analysis_result/experiment_gloss/all/sv.mat');
load('../../analysis_result/experiment_gloss/all/glossEffect/glossEffect.mat');
load('../../mat/HKeffect/HKstimuli.mat');
load('../../mat/contrast/contrast.mat');
load('../../mat/contrast/contrastLab.mat');

HK = mean(HKstimuli(:,:,1));

HKzscore = zscore(HK);
contrastZscore = zscore(contrast);
contrastLabZscore = zscore(mean(contrastLab));

X = [ones(size(HKzscore))' HKzscore' contrastZscore'];

[b,~,~,~,stats] = regress(glossEffect',X)
