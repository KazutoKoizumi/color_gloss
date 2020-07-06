% 刺激の複数呈示

% Object
material = 'bunny';
light = 'area';
Drate = 'D01';
alpha = 'alpha02';
objectSD = 'bunnySD';
objectD = 'bunnyD';

%alphaNum = ["005", "01", "02", "03"];
imageNum = 27;
stimuli = zeros(720, 960, 3, imageNum);

%{
for i = 1:imageNum
    %load(strcat('../stimuli/',material,'/',light,'/',Drate,'/',alpha,'/',objectSD,'.mat'));
    load(strcat('../stimuli/',material,'/',light,'/',Drate,'/',alpha,alphaNum(i),'/',objectD,'.mat'));
    stimuli(:,:,:,i) = bunnyD(:,:,:,2);
    %figure;
    %image(stimuli(:,:,:,i)/255);
end
%}

for i = 1:9
    load(strcat('../stimuli/',material,'/',light,'/',Drate,'/',alpha,'/',objectSD,'.mat'));
    stimuli(:,:,:,3*i-2) = bunnySD(:,:,:,i);
    load(strcat('../stimuli/',material,'/',light,'/',Drate,'/',alpha,'/',objectD,'.mat'));
    stimuli(:,:,:,3*i-1) = bunnyD(:,:,:,i);
    load(strcat('../stimuli/',material,'/',light,'/',Drate,'/',alpha,'/',objectSD,'lum6.mat'));
    stimuli(:,:,:,3*i) = bunnySD(:,:,:,i);
end

for i = 1:9
    figure;
    montage(stimuli(:,:,:,3*i-2:3*i)/255, 'size', [1,3]);
    %montage(stimuli(:,:,:,6*(i-1)+1:6*i)/255, 'size', [3,2]);
end