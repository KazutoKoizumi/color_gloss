%% 光沢感とH-K効果との相関係数を求める
clear all;

sn1 = 'all'; % 実験1被験者名
sn2 = 'all'; % 実験2被験者名
sn = ["koizumi", "nohira", "totsuka", "taniguchi", "kosone", "saeki"]; 

colorName = ["red","orange","yellow","green","blue-green","cyan","blue","magenta"];

load(strcat('../../analysis_result/experiment_gloss/',sn1,'/sv.mat'));
load('../../analysis_result/experiment_HK/all/HKtable.mat');

load('../../mat/patch/patchLuminance.mat');
load('../../mat/patch/patchSaturation.mat');

paramnum = 3*2*3*3*2;
idx_gloss = zeros(paramnum, 5);
count = 1;
for i = 1:3 % shape
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                for m = 1:2 % SD or D
                    idx_gloss(count,:) = [i, j, k, l, m];
                    count = count + 1;
                end
            end
        end
    end
end

idx_method_diffuse = zeros(18,6);
for i = 1:2
    for j = 1:3
        idx_method_diffuse(:,3*(i-1)+j) = find(idx_gloss(:,5)==i & idx_gloss(:,3)==j);
    end
end

sValue = zeros(9, paramnum);
for i = 1:paramnum
    sValue(:,i) = sv(:,:,idx_gloss(i,1),idx_gloss(i,2),idx_gloss(i,3),idx_gloss(i,4),idx_gloss(i,5))';
end

%% 相関係数
% z-score化したもので相関係数を求める
R = zeros(108,9); 
for i = 1:108 % 実験1パラメータ
    gloss = sValue(2:9,i)';
    for j = 1:9 % 実験2パラメータ
        HK = HKtable.HKzscore(8*(j-1)+1:8*j)';
        r = corrcoef(gloss, HK);
        R(i,j) = r(1,2);
    end
end

% 相関係数のヒートマップ
figure;
heatmap(R', 'ColorLimits',[-1 1]);
colormap('jet');
xlabel('光沢感パラメータ');
ylabel('H-K効果パラメータ');