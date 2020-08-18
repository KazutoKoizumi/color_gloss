%% xyz形式のファイルを読み込み彩色するプログラム
% 彩色の際にマスク処理を行い、オブジェクト部分のみを彩色する
% 彩色前に色度を白色点に合わせる（envmapの色は消す）, 背景の色度も白色点に合わせる
clear all;

%% オブジェクトのパラメータ
shape = 'bunny';
light = 'area';
diffuse = 'D05';
roughness = 'alpha005';

indexD = ["D01", "D03", "D05"];
if strcmp(light, 'area') == 1
    lum = 2*(find(indexD == diffuse)+1);
elseif strcmp(light, 'envmap') == 1
    if strcmp(shape, 'bunny') == 1
        lumPar = [2, 2.5, 3];
    elseif strcmp(shape, 'dragon') == 1
        lumPar = [2.3, 3, 3];
    elseif strcmp(shape, 'blob') == 1
        lumPar = [2, 2, 3];
    end
    lum = lumPar(indexD==diffuse);
end
%{ 
 % 拡散成分ごとのトーンマップ時の輝度閾値の設定
 % bunny,area,D01 : 4,  D03 : 6,  D05 : 8
 % bunny,envmap,D01 : 2, D03 : 2.5, D05 : 3
 % dragon,area,D01 : 4, D03 : 6, D05 : 8
 % dragon,envmap,D01 : 2.3, D03 : 3, D05 : 3
 % blob,area,D01 : 4, D03 : 6, D05 : 8
 % blob,envmap,D01 : 2, D03 : 2, D05 : 3
%}
%lum = 8;

%% データ読み込み
load(strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/xyzSD.mat'));
load(strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/xyzD.mat'));
load(strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/xyzS.mat'));
load('../mat/ccmat.mat');
load(strcat('../mat/',shape,'Mask/mask.mat'));

scale = 0.4;

%% トーンマップ
tonemapImage = zeros(size(xyzSD, 1), size(xyzSD, 2), size(xyzSD, 3), 2);
tonemapImage(:,:,:,1) = tonemaping(xyzS,xyzSD,lum,scale,ccmat); % TonemapS
tonemapImage(:,:,:,2) = tonemaping(xyzD,xyzSD,lum,scale,ccmat); % TonemapD
%tonemapImage(:,:,:,1) = multipleXYZ(xyzS);
%tonemapImage(:,:,:,2) = multipleXYZ(xyzD);

%% マスク処理
maskImage = zeros(size(xyzSD, 1), size(xyzSD, 2), size(xyzSD, 3), 2);
for i = 1:size(xyzSD, 1)
    for j = 1:size(xyzSD, 2)
        if mask(i,j) == 1
            maskImage(i,j,:,1) = tonemapImage(i,j,:,1); % mask S
            maskImage(i,j,:,2) = tonemapImage(i,j,:,2); % mask D
        end
    end
end

%% 背景用の彩色
gray = zeros(size(xyzSD, 1), size(xyzSD, 2), size(xyzSD, 3), 2);
gray(:,:,:,1) = colorizeXYZ(tonemapImage(:,:,:,1), 1); % S
gray(:,:,:,2) = colorizeXYZ(tonemapImage(:,:,:,2), 1); % D
backImage = gray(:,:,:,1) + gray(:,:,:,2); % back : gray image

%% 彩色
colorS = colorizeXYZ(gray(:,:,:,1), 0);
colorD = colorizeXYZ(gray(:,:,:,2), 0);
coloredSD = colorS + colorD;
coloredD = colorD + gray(:,:,:,1);

%% 彩色画像に背景を合成
for i = 1:size(xyzSD, 1)
    for j = 1:size(xyzSD, 2)
        if mask(i,j) == 0
            for k = 1:9
                coloredSD(i,j,:,k) = backImage(i,j,:);
                coloredD(i,j,:,k) = backImage(i,j,:);
            end
        end
    end
end

%{
for i = 1:9
    %figure;
    wImageXYZ2rgb_wtm(coloredSD(:,:,:,i),ccmat);
    %figure;
    wImageXYZ2rgb_wtm(coloredD(:,:,:,i),ccmat);
end
%}

%% データ保存
ss = strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/coloredSD');
sd = strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/coloredD');
save(ss,'coloredSD');
save(sd,'coloredD');

