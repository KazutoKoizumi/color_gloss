% 刺激パッチに使用する輝度の計算
% 全刺激から輝度ヒストグラムを出し、その平均、+-SDの値を取る

clear all;

%% 読み込み
load('../../mat/colorSatLum/bunnySatLum.mat');
load('../../mat/colorSatLum/dragonSatLum.mat');
load('../../mat/colorSatLum/blobSatLum.mat');

%% 輝度ヒストグラムを求める
bunnyLum = reshape(bunnySatLum(:,2,:,:,:,:),1,size(bunnySatLum,1)*36);
dragonLum = reshape(dragonSatLum(:,2,:,:,:,:),1,size(dragonSatLum,1)*36);
blobLum = reshape(blobSatLum(:,2,:,:,:,:),1,size(blobSatLum,1)*36);

lum = cat(2,bunnyLum,dragonLum,blobLum);

h = histogram(lum);
lumMean = mean(lum);
lumSD = std(lum);

%% パッチに使用する輝度
patchLuminance = [lumMean-lumSD, lumMean, lumMean+lumSD];

save('../../mat/patch/patchLuminance.mat', 'patchLuminance');