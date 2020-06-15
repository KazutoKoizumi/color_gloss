% 刺激画像を1種呈示する

% Object
material = 'Sphere';
SDrate = 'S09_D01';
alpha = 'alpha0';
objectSD = 'sphereSD';
objectD = 'sphereD';

load(strcat('./stimuli/',material,'/',SDrate,'/',alpha,'/',objectSD,'.mat'));
load(strcat('./stimuli/',material,'/',SDrate,'/',alpha,'/',objectD,'.mat'));

figure;
image(sphereSD(:,:,:,2)/255);
xticks({});
yticks({});
xticklabels({});
yticklabels({});
figure;
image(sphereD(:,:,:,2)/255);
xticks({});
yticks({});
xticklabels({});
yticklabels({});