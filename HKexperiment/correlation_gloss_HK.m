%% 光沢感の選好尺度値とH-K効果の選好尺度値を求める
clear all;

sn = 'pre_koizumi';
sn2 = 'all';

load(strcat('../../analysis_result/experiment_gloss/',sn2,'/sv.mat'));
load(strcat('../../analysis_result/experiment_HK/',sn,'/data.mat'));

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

sValue = zeros(9, paramnum);
for i = 1:paramnum
    sValue(:,i) = sv(:,:,idx_gloss(i,1),idx_gloss(i,2),idx_gloss(i,3),idx_gloss(i,4),idx_gloss(i,5))';
end

%% 相関係数
R = zeros(108,9);
for i = 1:108
    gloss = sValue(2:9,i)';
    for j = 1:9
        HK = data.HK(8*(j-1)+1:8*j)';
        
        r = corrcoef(gloss, HK);
        R(i,j) = r(1,2);
        
    end
end
        
        