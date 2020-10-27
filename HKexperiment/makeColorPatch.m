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

% 各輝度の白色点座標
uvWhite = zeros(3,2);
for i = 1:3
    uvWhite(i,:) = upvplWhitePoints(find(upvplWhitePoints(:,3)>patchLuminance(i),1,'first'),1:2);
end
    


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
colorUpvpl = zeros(iy,ix,3,8,3,3); % 色相：8, 輝度：3, 彩度：3
colorXYZ = zeros(iy,ix,3,8,3,3); % 色相：8, 輝度：3, 彩度：3

% パッチの色相・輝度・彩度設定
uvColorize = zeros(8,3,3,3);
for i = 1:3 % 輝度
    uvColorize(:,3,i,:) = patchLuminance(i);
    for j = 1:3 % 彩度
        for k = 1:8 % 色相
            % パッチの輝度設定
            colorUpvpl(:,:,3,k,i,j) = patchMask * patchLuminance(i);
            
            % 各色相・各輝度に対するu'v'色度座標のリスト
            uvColorize(k,1,i,j) = uvWhite(i,1) + patchSaturation(j)*cos((k-1)*pi/4);
            uvColorize(k,2,i,j) = uvWhite(i,2) + patchSaturation(j)*sin((k-1)*pi/4);
            
            % パッチを彩色
            colorUpvpl(:,:,1,k,i,j) = patchMask * uvColorize(k,1,i,j);
            colorUpvpl(:,:,2,k,i,j) = patchMask * uvColorize(k,2,i,j);
            
            % u'v' -> XYZ
            colorXYZ(:,:,:,k,i,j) = applycform(colorUpvpl(:,:,:,k,i,j),cu2x);
        end
    end
end

%% 背景にパッチを合成
colorPatch =  bgStimuli .* ~patchMask + colorXYZ;

%% RGBに変換
stimuliPatch = zeros(iy,ix,3,8,3,3);
for i = 1:3 % 輝度
    for j = 1:3 % 彩度
        for k = 1:8 % 色相
            stimuliPatch(:,:,:,k,i,j) = imageXYZ2RGB(colorPatch(:,:,:,k,i,j), ccmat);
        end
    end
end

%% パッチの輝度を設定する関数

%% パッチの彩度・色相を設定する関数