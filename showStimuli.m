% 刺激画像を1種呈示する

% Object
shape = 'bunny';
light = 'area';
diffuse = 'D01';
roughness = 'alpha02';
objectSD = 'bunnySD';
objectD = 'bunnyD';

load(strcat('../stimuli/',shape,'/',light,'/',diffuse,'/',roughness,'/stimuliSD.mat'));
load(strcat('../stimuli/',shape,'/',light,'/',diffuse,'/',roughness,'/stimuliD.mat'));


figure;
image(bunnySD(:,:,:,i)/255);
xticks({});
yticks({});
xticklabels({});
yticklabels({});

figure;
image(bunnyD(:,:,:,i)/255);
xticks({});
yticks({});
xticklabels({});
yticklabels({});