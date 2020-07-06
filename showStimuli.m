% 刺激画像を1種呈示する

% Object
material = 'bunny';
light = 'area';
Drate = 'D01';
alpha = 'alpha02';
objectSD = 'bunnySD';
objectD = 'bunnyD';

load(strcat('../stimuli/',material,'/',light,'/',Drate,'/',alpha,'/',objectSD,'.mat'));
load(strcat('../stimuli/',material,'/',light,'/',Drate,'/',alpha,'/',objectD,'.mat'));

figure;
image(bunnySD(:,:,:,2)/255);
%xticks({});
%yticks({});
%xticklabels({});
%yticklabels({});
figure;
image(bunnyD(:,:,:,8)/255);
xticks({});
yticks({});
xticklabels({});
yticklabels({});