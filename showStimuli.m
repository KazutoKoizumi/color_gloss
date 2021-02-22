% 刺激画像を1種呈示する

% Object
shape = 'bunny';
light = 'area';
diffuse = 'D01';
roughness = 'rough005';

load(strcat('../stimuli/',shape,'/',light,'/',diffuse,'/',roughness,'/stimuliSD.mat'));
load(strcat('../stimuli/',shape,'/',light,'/',diffuse,'/',roughness,'/stimuliD.mat'));


figure;
image(stimuliSD(:,:,:,2));
xticks({});
yticks({});
xticklabels({});
yticklabels({});

figure;
image(stimuliD(:,:,:,2));
xticks({});
yticks({});
xticklabels({});
yticklabels({});