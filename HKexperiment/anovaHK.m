%% HK効果量のanova

sn = 'pre_koizumi';

load(strcat('../../analysis_result/experiment_HK/',sn,'/data.mat'));

%% anova
luminance = data.lum';
saturation = data.sat';
color = data.color';
HK = data.HK';

p = anovan(HK,{luminance,saturation,color}, 'model','interaction', 'varnames',{'luminance','saturation','hue'});