%% HK効果量のanova

sn = 'pre_koizumi';

load(strcat('../../analysis_result/experiment_HK/',sn,'/data.mat'));

%% anova
luminance = repmat(data.lum', [1 5]);
saturation = repmat(data.sat', [1 5]);
color = repmat(data.color', [1 5]);
HK = reshape(data.HK, [1 72*5]);

p = anovan(HK,{luminance,saturation,color}, 'model','full', 'varnames',{'luminance','saturation','hue'});
