%% xyz形式のファイルを読み込み彩色するプログラム
% 彩色の際にマスク処理を行い、オブジェクト部分のみを彩色する
% 彩色前に色度を白色点に合わせる（envmapの色は消す）, 背景の色度も白色点に合わせる
clear all;

%% オブジェクトのパラメータ
shape = 'bunny';
light = 'area';
diffuse = 'D05';
roughness = 'alpha02';

%{
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
%}
%{ 
 % 拡散成分ごとのトーンマップ時の輝度閾値の設定
 % bunny,area,D01 : 3.5,  D03 : 3.5,  D05 : 3.5
 % bunny,envmap,D01 : 3.5, D03 : 3.5, D05 : 3.5
 % dragon,area,D01 : 3.5, D03 : 3.5, D05 : 3.5
 % dragon,envmap,D01 : 3.5, D03 : 3.5, D05 : 3.5
 % blob,area,D01 : 3.5, D03 : 3.5, D05 : 3.5
 % blob,envmap,D01 : 3.5, D03 : 3.5, D05 : 3.5
%}
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

