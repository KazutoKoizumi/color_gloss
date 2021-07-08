%% 有彩色刺激パッチを作る
clear all;

load('../../mat/patch/patch.mat');
load('../../mat/patch/patchMask.mat');
load('../../mat/patch/patchSaturation.mat');
load('../../mat/patch/patchLuminance.mat');
patchLuminance = 20;

load('../../mat/upvplWhitePoints.mat');
load('../../mat/ccmat.mat');

[iy,ix,iz] = size(patch);

flag_light = 2;
lum = 3.5;

cu2x = makecform('upvpl2xyz');

lumNum = 1;

% 各輝度の白色点座標
uvWhite = zeros(3,2);
for i = 1:1
    uvWhite(i,:) = upvplWhitePoints(find(upvplWhitePoints(:,3)>patchLuminance(i),1,'first'),1:2);
end
    
%% 背景の輝度調整
if flag_light == 1
    load('../../mat/patch/patch_area.mat');
    backPatch = patch_area;
elseif flag_light == 2
    load('../../mat/patch/patch_env.mat');
    backPatch = patch_env;
end
bgStimuli = luminanceAdj(backPatch,flag_light,lum);


%% パッチの設定
% u'v'色度で設定
colorUpvpl = zeros(iy,ix,3,8,1,3); % 色相：8, 輝度：1, 彩度：3
colorXYZ = zeros(iy,ix,3,8,1,3); % 色相：8, 輝度：1, 彩度：3

% パッチの色相・輝度・彩度設定
uvColorize = zeros(8,3,1,3);
for i = 1:1 % 輝度
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
patch_high_luminance = zeros(iy,ix,3,8,3,3);
for i = 1:1 % 輝度
    for j = 1:3 % 彩度
        for k = 1:8 % 色相
            patch_high_luminance(:,:,:,k,i,j) = imageXYZ2RGB(colorPatch(:,:,:,k,i,j), ccmat);
        end
    end
end

%% 保存・出力
save('../../stimuli/patch/patch_high_luminance.mat', 'patch_high_luminance');

figure
montage(patch_high_luminance(:,:,:,:,1,2)/255,'size',[2 4]);


%% grayパッチの作成

% u'v'色度で設定
grayUpvpl = zeros(iy,ix,3,lumNum); 
grayXYZ = zeros(iy,ix,3,lumNum);

% パッチの輝度・白色点設定
for i = 1:lumNum % 輝度
    % パッチの輝度設定
    grayUpvpl(:,:,3,i) = patchMask * patchLuminance(i);
            
    % パッチを彩色
    grayUpvpl(:,:,1,i) = patchMask * uvWhite(i,1);
    grayUpvpl(:,:,2,i) = patchMask * uvWhite(i,2);
    
    % u'v' -> XYZ
    grayXYZ(:,:,:,i) = applycform(grayUpvpl(:,:,:,i),cu2x);
end

% 背景にパッチを合成
grayPatch =  bgStimuli .* ~patchMask + grayXYZ;

patch_high_luminance_gray = zeros(iy,ix,3);
patch_high_luminance_gray = imageXYZ2RGB(grayPatch(:,:,:,1), ccmat);

% 有彩色の輝度に対するrgb値の算出
uvl = [uvWhite(1,1), uvWhite(1,2), patchLuminance];
rgb = conv_upvpl2rgb(uvl,ccmat);
rgb_patch_high_luminance_gray = rgb;

save('../../stimuli/patch/patch_high_luminance_gray.mat', 'patch_high_luminance_gray');
save('../../stimuli/patch/rgb_patch_high_luminance_gray.mat', 'rgb_patch_high_luminance_gray');

figure;
image(patch_high_luminance_gray)