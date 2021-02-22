%% xyz形式のファイルを読み込み彩色するプログラム
% 彩色の際にマスク処理を行い、オブジェクト部分のみを彩色する
% 彩色前に色度を白色点に合わせる（envmapの色は消す）, 背景の色度も白色点に合わせる
clear all;

%% オブジェクトのパラメータ
shape = 'bunny';
light = 'area';
diffuse = 'D01';
roughness = 'rough005';

lum = 3;

%{
% ---------- 輝度調整していない場合 -------------------------------------------
%% データ読み込み
load(strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/xyzSD.mat'));
load(strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/xyzS.mat'));
load(strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/xyzD.mat'));
load('../mat/ccmat.mat');
load(strcat('../mat/',shape,'Mask/mask.mat'));


%% トーンマップ
tonemapImage = zeros(size(xyzSD, 1), size(xyzSD, 2), size(xyzSD, 3), 2);
tonemapImage(:,:,:,1) = tonemaping(xyzS,lum); % specular
tonemapImage(:,:,:,2) = tonemaping(xyzD,lum); % diffuse

%% 全体を無色にする
backNoMask = ones(size(xyzSD, 1), size(xyzSD, 2));
noColorSpecular = colorizeXYZ(tonemapImage(:,:,:,1),tonemapImage(:,:,:,1),backNoMask,1);
noColorDiffuse = colorizeXYZ(tonemapImage(:,:,:,2),tonemapImage(:,:,:,2),backNoMask,1);
% ---------------------------------------------------------------------------
%}


% ----------- 輝度調整している場合 --------------------------------------------
%% データ読み込み
load(strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/xyzSD.mat'));
load(strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/xyzStonemap.mat'));
load(strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/xyzDtonemap.mat'));
load('../mat/ccmat.mat');
load(strcat('../mat/',shape,'Mask/mask.mat'));

%% 全体を無色にする
backNoMask = ones(size(xyzSD, 1), size(xyzSD, 2));
noColorSpecular = colorizeXYZ(xyzStonemap,xyzStonemap,backNoMask,1);
noColorDiffuse = colorizeXYZ(xyzDtonemap,xyzDtonemap,backNoMask,1);
% ----------------------------------------------------------------------
%}

%% SD彩色
% specularとdiffuseのXYZを加算
noColorSD = noColorSpecular + noColorDiffuse;

% 彩色
coloredSD = colorizeXYZ(noColorSD,noColorSD,mask,0);

%% D彩色
% diffuseに彩色
colorDiffuse = colorizeXYZ(noColorDiffuse,noColorSD,mask,0);

% 無彩色specularと彩色diffuseを加算
coloredD = noColorSpecular + colorDiffuse;

%% データ保存
ss = strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/coloredSD');
sd = strcat('../mat/',shape,'/',light,'/',diffuse,'/',roughness,'/coloredD');
save(ss,'coloredSD');
save(sd,'coloredD');


%% 彩色specularの取り出し
colorSpecular = colorizeXYZ(noColorSpecular,noColorSD,mask,0);