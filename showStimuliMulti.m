% 刺激の複数呈示

% Object
material = 'bunny';
light = 'area';
Drate = 'D01';
alpha = 'alpha';
objectSD = 'bunnySD';
objectD = 'bunnyD';

alphaNum = ["005", "01", "02", "03"];
imageNum = 4;
stimuli = zeros(720, 960, 3, imageNum);

for i = 1:imageNum
    %load(strcat('../stimuli/',material,'/',light,'/',Drate,'/',alpha,'/',objectSD,'.mat'));
    load(strcat('../stimuli/',material,'/',light,'/',Drate,'/',alpha,alphaNum(i),'/',objectD,'.mat'));
    stimuli(:,:,:,i) = bunnyD(:,:,:,2);
    %figure;
    %image(stimuli(:,:,:,i)/255);
end

figure;
montage(stimuli/255, 'size', [1,4]);