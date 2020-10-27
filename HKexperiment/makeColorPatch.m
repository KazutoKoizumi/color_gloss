%% 有彩色刺激パッチを作る
clear all;

load('../../mat/patch/patch.mat');
load('../../mat/patch/patchMask.mat');
load('../../mat/patch/patchSaturation.mat');
load('../../mat/patch/patchLuminance.mat');

load('../../mat/upvplWhitePoints.mat');
load('../../mat/proportion.mat');
load('../../mat/ccmat.mat');
monitorMinLum = upvplWhitePoints(2,3);

[iy,ix,iz] = size(patch);
lum = 3.5;

%% 背景の輝度調整
% トーンマップ
bgStimuli = tonemaping(patch,lum);

% XYZ -> u'v'l
cx2u = makecform('xyz2upvpl');
cu2x = makecform('upvpl2xyz');
upvplBack = applycform(bgStimuli(:,:,:,1),cx2u);

% エリアライトなので輝度調整
upvplBack(:,:,3) = upvplBack(:,:,3) * proportion;

% 最小輝度を下回る部分の調整
minMap = upvplBack(:,:,3) < monitorMinLum;
minMapMask = ~minMap;
minMap = minMap * monitorMinLum;
upvplBack(:,:,3) = upvplBack(:,:,3) .* minMapMask + minMap;

% u'v'l -> XYZ
bgStimuli = applycform(upvplBack,cu2x);


%% パッチの設定
% u'v'色度で設定

% パッチの輝度設定

% パッチの彩度・色相設定

% XYZに変換


%% 背景にパッチを合成

%% RGBに変換



%% パッチの輝度を設定する関数

%% パッチの彩度・色相を設定する関数