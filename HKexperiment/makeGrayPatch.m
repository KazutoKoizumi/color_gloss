%% 無彩色刺激パッチを作る
clear all;

load('../../mat/patch/patch.mat');
load('../../mat/patch/patchMask.mat');
load('../../mat/patch/patchLuminance.mat');
load('../../mat/patch/patchSaturation.mat');

load('../../mat/upvplWhitePoints.mat');
load('../../mat/ccmat.mat');

[iy,ix,iz] = size(patch);

flag_light = 2;
lum = 3.5;

cu2x = makecform('upvpl2xyz');

%% grayパッチに使用する輝度の設定
lumNum = 3; % パッチの輝度数

% 各輝度の白色点座標
uvWhite = zeros(3,2);
for i = 1:3
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


%% 背景にパッチを合成
grayPatch =  bgStimuli .* ~patchMask + grayXYZ;

%% RGBに変換
stimuliGrayPatch = zeros(iy,ix,3,lumNum);
for i = 1:lumNum % 輝度
    stimuliGrayPatch(:,:,:,i) = imageXYZ2RGB(grayPatch(:,:,:,i), ccmat);
end

%% 有彩色の3種の輝度に対応するrgb値の算出
uvl = reshape(cat(2,uvWhite,patchLuminance'), [3,1,3]);
rgb = conv_upvpl2rgb(uvl,ccmat);
rgbGrayPatch = reshape(rgb,[3,3]);

%% 保存・出力
save('../../stimuli/patch/stimuliGrayPatch.mat', 'stimuliGrayPatch');
save('../../mat/patch/rgbGrayPatch.mat', 'rgbGrayPatch');

figure
montage(stimuliGrayPatch/255,'size',[1 lumNum]);


