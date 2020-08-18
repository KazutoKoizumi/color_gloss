%% XYZからRGBに変換するプログラム（rgbの0~1のチェックなし）

%% オブジェクトのパラメータ
shape = 'bunny'; % shape : bunny, dragon, blob
light = 'area'; % light : area or envmap
diffuse = 'D01'; % diffuse rate
roughnrss = 'alpha02'; % roughness parameter

%% データ読み込み
load(strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughnrss,'/coloredSD.mat'));
load(strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughnrss,'/coloredD.mat'));
load('../mat/ccmat.mat');
[iy,ix,iz] = size(coloredSD(:,:,:,1));
stimuliSD = zeros(iy,ix,iz,9);
stimuliD = zeros(iy,ix,iz,9);

%% 変換
for i = 1:9
    i
    stimuliSD(:,:,:,i) = imageXYZ2RGB(coloredSD(:,:,:,i),ccmat);
    stimuliD(:,:,:,i) = imageXYZ2RGB(coloredD(:,:,:,i),ccmat);
end

%% 保存
save(strcat('../stimuli/',shape,'/',light,'/',diffuse,'/',roughnrss,'/stimuliSD.mat'),'stimuliSD');
save(strcat('../stimuli/',shape,'/',light,'/',diffuse,'/',roughnrss,'/stimuliD.mat'),'stimuliD');

%% 画像表示
figure;
montage(stimuliSD/255,'size',[3 3]);
figure;
montage(stimuliD/255,'size',[3 3]);
