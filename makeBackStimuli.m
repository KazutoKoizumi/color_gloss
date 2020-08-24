%% 刺激画像の背景のみの画像（RGB）をつくる
% 輝度調整、無彩色にしたあとにRGBに変換、areaとenvmapをまとめる

clear all;

%% データ読み込み
load('../mat/ccmat.mat');
load('../mat/upvplWhitePoints.mat');
monitorMinLum = min(upvplWhitePoints(:,3));
monitorMinLum = upvplWhitePoints(2,3);

load('../mat/back/backArea.mat');
load('../mat/back/backEnv.mat');

[iy, ix, iz] = size(backArea);
lum = 3.5;

%% 輝度調整
bgStimuli = zeros(iy, ix, iz, 2); % 1:area, 2:envmap
bgStimuli(:,:,:,1) = tonemaping(backArea,lum);
bgStimuli(:,:,:,2) = tonemaping(backEnv,lum);

% 色空間変換
cx2u = makecform('xyz2upvpl');
cu2x = makecform('upvpl2xyz');
upvpl(:,:,:,1) = applycform(bgStimuli(:,:,:,1),cx2u);
upvpl(:,:,:,2) = applycform(bgStimuli(:,:,:,2),cx2u);

% それぞれの平均輝度を求める
lumMap = upvpl(:,:,3,:);
pixelNum = iy*ix;
lumSum = sum(lumMap,[1 2]);
lumSum = reshape(lumSum, [1 2]);
meanLum = lumSum / pixelNum; % 平均輝度

% エリアライトにかける定数を求める
weight = 1.2;
proportion = meanLum(2)*weight / meanLum(1);

% エリアライトの輝度調整
upvpl(:,:,3,1) = upvpl(:,:,3,1) * proportion;

% 最小輝度を下回る部分の調整
minMap = upvpl(:,:,3,1) < monitorMinLum;
minMapMask = ~minMap;
minMap = minMap * monitorMinLum;
upvpl(:,:,3,1) = upvpl(:,:,3,1) .* minMapMask + minMap;

%% upvpl -> XYZ
bgStimuli(:,:,:,1) = applycform(upvpl(:,:,:,1),cu2x);
bgStimuli(:,:,:,2) = applycform(upvpl(:,:,:,2),cu2x);

%% 無彩色にする
backNoMask = ones(iy,ix);
bgStimuli(:,:,:,1) = colorizeXYZ(bgStimuli(:,:,:,1),bgStimuli(:,:,:,1),backNoMask,1);
bgStimuli(:,:,:,2) = colorizeXYZ(bgStimuli(:,:,:,2),bgStimuli(:,:,:,2),backNoMask,1);

%% XYZ -> RGB (rgb0~1のチェックあり)
for i= 1:2
    
    bgStimuli(:,:,:,i) = imageXYZ2RGB(bgStimuli(:,:,:,i),ccmat);
end

%% 後処理
bgStimuli = cast(bgStimuli, 'uint8');

save('../stimuli/back/bgStimuli.mat', 'bgStimuli');

figure;
montage(bgStimuli, 'size', [1 2]);


