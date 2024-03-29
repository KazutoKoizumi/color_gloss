%% XYZからRGBに変換するプログラム（rgbの0~1のチェックあり）

%% オブジェクトのパラメータ
shape = 'bunny'; % shape : bunny, dragon, blob
light = 'envmap'; % light : area or envmap
diffuse = 'D03'; % diffuse rate
roughness = 'rough01'; % roughness parameter

%% データ読み込み
load(strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/coloredSD.mat'));
load(strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/coloredD.mat'));
load('../mat/ccmat.mat');
[iy,ix,iz] = size(coloredSD(:,:,:,1));
stimuliSD = zeros(iy,ix,iz,9);
stimuliD = zeros(iy,ix,iz,9);

%% 変換
for i = 1:9
    i
    %stimuliSD(:,:,:,i) = imageXYZ2RGB(coloredSD(:,:,:,i),ccmat);
    stimuliSD(:,:,:,i) = conv_XYZ2RGB(coloredSD(:,:,:,i));
    i
    %stimuliD(:,:,:,i) = imageXYZ2RGB(coloredSD(:,:,:,i),ccmat);
    stimuliD(:,:,:,i) = conv_XYZ2RGB(coloredD(:,:,:,i));
end

%% 保存
%save(strcat('../stimuli/',shape,'/',light,'/',diffuse,'/',roughness,'/stimuliSD.mat'),'stimuliSD');
%save(strcat('../stimuli/',shape,'/',light,'/',diffuse,'/',roughness,'/stimuliD.mat'),'stimuliD');

%% 画像表示
figure;
montage(stimuliSD/255,'size',[3 3]);
figure;
montage(stimuliD/255,'size',[3 3]);
