%% オブジェクトの平均輝度・彩度を求めるプログラム
clear all;

%% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["rough005", "rough01", "rough02"]; %l
method = ["SD", "D"];
diffuseN = size(diffuse,2);
roughN = size(roughness,2);
methodN = size(method,2);


Dname = ["0.1", "0.3", "0.5"];
roughName = ["0.05", "0.1", "0.2"];

allObj = 3*2*3*3*2;
progress = 0;

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
    idx_shape(:,i) = find(idx(:,1)==i);
    idx_diffuse(:,i) = find(idx(:,3)==i);
    idx_rough(:,i) = find(idx(:,4)==i);
    for j = 1:2
        idx_shape_method(:,3*(j-1)+i) = find(idx(:,1)==i & idx(:,5)==j);
        idx_diffuse_method(:,diffuseN*(j-1)+i) = find(idx(:,3)==i & idx(:,5)==j);
        idx_rough_method(:,roughN*(j-1)+i) = find(idx(:,4)==i & idx(:,5)==j);
    end
end
for i = 1:2
    idx_light(:,i) = find(idx(:,2)==i);
    idx_method(:,i) = find(idx(:,5)==i);
    for j = 1:2
        idx_light_method(:,2*(j-1)+i) = find(idx(:,2)==i & idx(:,5)==j);
    end
end

% 読み込み
load('../../mat/colorSatLum/bunnySatLum.mat');
load('../../mat/colorSatLum/dragonSatLum.mat');
load('../../mat/colorSatLum/blobSatLum.mat');

%% 各条件ごとに平均輝度・彩度を求める
meanLum = zeros(1,1,3,2,3,3,2);
meanLum(1,1,1,:,:,:,:) = mean(bunnySatLum(:,2,:,:,:,:));
meanLum(1,1,2,:,:,:,:) = mean(dragonSatLum(:,2,:,:,:,:));
meanLum(1,1,3,:,:,:,:) = mean(blobSatLum(:,2,:,:,:,:));
meanLum = reshape(permute(meanLum, [1 2 7 6 5 4 3]), 108,1);

meanSat = zeros(1,1,3,2,3,3,2);
meanSat(1,1,1,:,:,:,:) = mean(bunnySatLum(:,1,:,:,:,:));
meanSat(1,1,2,:,:,:,:) = mean(dragonSatLum(:,1,:,:,:,:));
meanSat(1,1,3,:,:,:,:) = mean(blobSatLum(:,1,:,:,:,:));
meanSat = reshape(permute(meanSat, [1 2 7 6 5 4 3]), 108,1);

%% 各パラメータ変化時の平均輝度変化
[meanLum_shape,meanLum_shape_mean] = getMean(3,idx_shape,meanLum);
[meanLum_light,meanLum_light_mean] = getMean(2,idx_light,meanLum);
[meanLum_diffuse,meanLum_diffuse_mean] = getMean(3,idx_diffuse,meanLum);
[meanLum_rough,meanLum_rough_mean] = getMean(3,idx_rough,meanLum);


%% 彩色方法ごとの平均彩度
[meanSat_method, meanSat_method_mean] = getMean(methodN, idx_method,meanSat);

% 各パラメータを彩色方法でわける
[meanSat_shape_method,meanSat_shape_method_mean] = getMean(3*methodN,idx_shape_method,meanSat);
[meanSat_light_method,meanSat_light_method_mean] = getMean(2*methodN,idx_light_method,meanSat);
[meanSat_diffuse_method,meanSat_diffuse_method_mean] = getMean(3*methodN,idx_diffuse_method,meanSat);
[meanSat_rough_method,meanSat_rough_method_mean] = getMean(3*methodN,idx_rough_method,meanSat);

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