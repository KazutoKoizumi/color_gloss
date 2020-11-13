%% 光沢感の選好尺度値とH-K効果との相関係数を求める
clear all;

sn = 'pre_koizumi';
sn2 = 'nohira';

colorName = ["red","orange","yellow","green","blue-green","cyan","blue","magenta"];

load(strcat('../../analysis_result/experiment_gloss/',sn2,'/sv.mat'));
load(strcat('../../analysis_result/experiment_HK/',sn,'/data.mat'));

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
R = zeros(108,9);
R_zscore = zeros(108,9);
for i = 1:108
    gloss = sValue(2:9,i)';
    for j = 1:9
        HK = data.HKave(8*(j-1)+1:8*j)';
        r = corrcoef(gloss, HK);
        R(i,j) = r(1,2);
        
        HKzscore = data.HKzscore(8*(j-1)+1:8*j)';
        r_z = corrcoef(gloss, HKzscore);
        R_zscore(i,j) = r_z(1,2); 
        
    end
end

% 相関係数のヒートマップ
figure;
heatmap(R', 'ColorLimits',[-1 1]);
colormap('jet');
xlabel('光沢感パラメータ');
ylabel('H-K効果パラメータ');

%% 一部のパラメータに限定した相関係数(z-score化したものを使用)
% SDと彩度0.0460のH-K
% D,diffuse0.1と彩度0.0316のH-K
% D,diffuse0.3と彩度0.0388のH-K
% D,diffuse0.5と彩度0.0388のH-K

% H-K効果を輝度で平均化
dataHK = zeros(3,3,8);
for i = 1:8
    dataHK(:,:,i) = reshape(data.HKzscore(data.color==colorName(i)), [3,3])';
end
HK_meanLum = reshape(mean(dataHK), [3,8]);

% 相関係数
R_param = zeros(108,1);
for i = 1:108
    gloss = sValue(2:9,i)';
    if idx_gloss(i,5) == 1 % SD
        HK = HK_meanLum(3,:);
    else
        if idx_gloss(i,3) == 1 % D, diffuse=0.1
            HK = HK_meanLum(1,:);
        else
            HK = HK_meanLum(2,:);
        end
    end
    
    r = corrcoef(gloss,HK);
    R_param(i) = r(1,2);
end

% 相関係数のヒートマップ
figure;
heatmap(R_param');
colormap('jet');

R_SD_D_mean = mean(reshape(R_param,[2,54]),2);

% SD,D,diffuseパラメータでわける
R_method_diffuse = R_param(idx_method_diffuse);
% プロット
figure;
x = reshape(repmat([1,2,3,4,5,6], [18,1]),[1,6*18]);
y = reshape(R_method_diffuse, [1,108]);
scatter(x,y);
hold on;
x_mean = [1,2,3,4,5,6];
y_mean = mean(R_method_diffuse);
scatter(x_mean,y_mean,72,[1 0 0],'filled');

xlim([0 7]);
xticks(x_mean);
xticklabels({'0.1', '0.3', '0.5', '0.1', '0.3', '0.5'});
xlabel('diffuse');
ylabel('相関係数');
title('diffuseと彩色方法ごとの相関係数');
xline(3.5, '--');
ylim([0 1.3]);
text(1.75,1.2,'SD');
text(5.25,1.2,'D');
hold off;


