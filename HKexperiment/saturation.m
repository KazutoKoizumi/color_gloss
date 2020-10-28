% 刺激パッチに使用する彩度の計算
clear all;

%% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["alpha005", "alpha01", "alpha02"]; %l
method = ["SD", "D"];
diffuseN = size(diffuse,2);
roughN = size(roughness,2);
methodN = size(method,2);

% パラメータのインデックス
count = 1;
idx = zeros(108,5);
for i = 1:3 % shape
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                for m = 1:2 % SD or D
                    idx(count,:) = [i, j, k, l, m];
                    count = count + 1;
                end
            end
        end
    end
end
for i = 1:diffuseN
    %idx_shape(:,i) = find(idx(:,1)==i);
    %idx_diffuse(:,i) = find(idx(:,3)==i);
    %idx_rough(:,i) = find(idx(:,4)==i);
    for j = 1:2
        idx_shape_method(:,3*(j-1)+i) = find(idx(:,1)==i & idx(:,5)==j);
        idx_diffuse_method(:,diffuseN*(j-1)+i) = find(idx(:,3)==i & idx(:,5)==j);
        %idx_rough_method(:,roughN*(j-1)+i) = find(idx(:,4)==i & idx(:,5)==j);
    end
end

% 読み込み
load('../../mat/colorSatLum/bunnySatLum.mat');
load('../../mat/colorSatLum/dragonSatLum.mat');
load('../../mat/colorSatLum/blobSatLum.mat');

load('../../mat/saturationMax.mat');

%{
%% 全刺激の最大彩度を求める
shapeSatMax = zeros(1,3);
shapeSatMax(1) = max(reshape(max(bunnySatLum(:,1,:,:,:,:)),36,1));
shapeSatMax(2) = max(reshape(max(dragonSatLum(:,1,:,:,:,:)),36,1));
shapeSatMax(3) = max(reshape(max(blobSatLum(:,1,:,:,:,:)),36,1));
%}
%% 全刺激のほぼ最大彩度
srt = sort(saturationMax);
idx = find(srt < max(saturationMax), 1, 'last');
satMax = srt(idx);

%% %D彩色、diffuse=0.1の刺激の平均彩度を求める
meanSat = zeros(1,1,3,2,3,3,2);
meanSat(1,1,1,:,:,:,:) = mean(bunnySatLum(:,1,:,:,:,:));
meanSat(1,1,2,:,:,:,:) = mean(dragonSatLum(:,1,:,:,:,:));
meanSat(1,1,3,:,:,:,:) = mean(blobSatLum(:,1,:,:,:,:));
meanSat = reshape(permute(meanSat, [1 2 7 6 5 4 3]), 108,1);

[meanSat_diffuse_method,meanSat_diffuse_method_mean] = getMean(3*methodN,idx_diffuse_method,meanSat);
satDiffuse1 = meanSat_diffuse_method_mean(4);

%% 中間彩度
midSat = (satMax + satDiffuse1) / 2;

%% パッチに使用する彩度
patchSaturation = [satDiffuse1,midSat,satMax];

save('../../mat/patch/patchSaturation.mat', 'patchSaturation');


%% 平均を取る関数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input
%  paramNum : パラメータの個数
%  idx : パラメータのインデックス
%  value : 値

% Output
%  param : パラメータごとに値をわける（列がパラメータ）
%  param_mean : パラメータごとの平均
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [param, param_mean] = getMean(paramNum,idx,value)
    
    param = zeros(108/paramNum, paramNum);
    for i = 1:108/paramNum
        for j = 1:paramNum
            param(i,j) = value(idx(i,j));
        end
    end
    
    param_mean = mean(param);
    
end