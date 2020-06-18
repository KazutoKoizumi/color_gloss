% 刺激画像を1種呈示する

% Object
material = 'bunny';
light = 'area';
Drate = 'D01';
alpha = 'alpha005';
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
image(bunnyD(:,:,:,2)/255);
%xticks({});
%yticks({});
%xticklabels({});
%yticklabels({});