%% オブジェクト部分の平均輝度を求めるプログラム
clear all;

% Object
material = 'bunny';
light = 'area';
Drate = 'D01';
alpha = 'alpha02';

load(strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/xyzSD.mat'));
load(strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/xyzD.mat'));
load(strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/xyzS.mat'));
load('../mat/ccmat.mat');
load('../mat/monitorColorMax.mat');
load('../mat/logScale.mat');
load(strcat('../mat/',material,'Mask/mask.mat'));

scale = 0.4;

tonemapImage = zeros(size(xyzSD, 1), size(xyzSD, 2), size(xyzSD, 3), 2);
%tonemapImage(:,:,:,1) = wTonemapDiff(xyzS,xyzSD,1,scale,ccmat); % TonemapS
%tonemapImage(:,:,:,2) = wTonemapDiff(xyzD,xyzSD,1,scale,ccmat); % TonemapD

tonemapImage(:,:,:,1) = tonemaping(xyzS,xyzSD,1,scale,ccmat); % TonemapS
tonemapImage(:,:,:,2) = tonemaping(xyzD,xyzSD,1,scale,ccmat); % TonemapD

maskImage = zeros(size(xyzSD, 1), size(xyzSD, 2), size(xyzSD, 3), 2);
luminanceSum = zeros(1,2);
luminanceMean = zeros(1,2);
objPixel = 0;
count = zeros(1,2);
threshold = 25;
for i = 1:size(xyzSD, 1)
    for j = 1:size(xyzSD, 2)
        if mask(i,j) == 1
            maskImage(i,j,:,1) = tonemapImage(i,j,:,1); % mask S
            maskImage(i,j,:,2) = tonemapImage(i,j,:,2); % mask D
            
            luminanceSum(1) = luminanceSum(1) + maskImage(i,j,3,1);
            if maskImage(i,j,3,1) > threshold
                count(1) = count(1) + 1;
                maskImage(i,j,3,1)
            end
            luminanceSum(2) = luminanceSum(2) + maskImage(i,j,3,2);
            if maskImage(i,j,3,2) > threshold
                count(2) = count(2) + 1;
                maskImage(i,j,3,2)
            end
            objPixel = objPixel + 1;
        end
    end
end

luminanceMean = luminanceSum / objPixel

