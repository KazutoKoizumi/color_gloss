%% 標準偏差を求める

exp = 'experiment_gloss';
sn = 'all';

load(strcat('../../analysis_result/',exp,'/',sn,'/sv.mat'));
load(strcat('../../analysis_result/',exp,'/',sn,'/BSsample.mat'));

paramnum = 3*2*3*3*2;
idx = zeros(paramnum, 5);
B = 10000; % ブートストラップのリサンプリング回数
count = 1;
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

for i = 1:3
    idx_shape(:,i) = find(idx(:,1)==i);
    idx_diffuse(:,i) = find(idx(:,3)==i);
    idx_rough(:,i) = find(idx(:,4)==i);
end
for i = 1:2
    idx_light(:,i) = find(idx(:,2)==i);
    idx_method(:,i) = find(idx(:,5)==i);
end

%% grayを覗いた有彩色の標準偏差
% 推定値から求める

svGray = zeros(1,paramnum);
svNoGray = zeros(8, paramnum);
for i = 1:paramnum
    svGray(1,i) = sv(:,1,idx(i,1),idx(i,2),idx(i,3),idx(i,4),idx(i,5));
    svNoGray(:,i) = sv(:,2:9,idx(i,1),idx(i,2),idx(i,3),idx(i,4),idx(i,5))';
end

SDnoGray = std(svNoGray);

% パラメータごとに平均を取る
% shape, diffuse, roughness
SDnoGray_shape = zeros(36,3);
SDnoGray_diffuse = zeros(36,3);
SDnoGray_rough = zeros(36,3);
for i = 1:36
    for j = 1:3
        SDnoGray_shape(i,j) = SDnoGray(idx_shape(i,j));
        SDnoGray_diffuse(i,j) = SDnoGray(idx_diffuse(i,j));
        SDnoGray_rough(i,j) = SDnoGray(idx_rough(i,j));
    end
end
SDnoGray_shape_mean = mean(SDnoGray_shape);
SDnoGray_diffuse_mean = mean(SDnoGray_diffuse);
SDnoGray_rough_mean = mean(SDnoGray_rough);



%% grayからの差
% 有彩色8色の選好尺度値の平均と無彩色の選好尺度値の差を取る
svNoGray_mean = mean(svNoGray);

glossEffect = svNoGray_mean - svGray;

% roughness
glossEffect_rough = zeros(36,3);
for i = 1:36
    for j = 1:3
        glossEffect_rough(i,j) = glossEffect(idx_rough(i,j));
    end
end
glossEffect_rough_mean = mean(glossEffect_rough);


% 有意差の有無の検証

% ブートストラップサンプルの整理
BS_mean = mean(BSsample(:,2:9,:,:,:,:,:),2); % 有彩色の選好尺度値の平均
sa = BS_mean - BSsample(:,1,:,:,:,:,:);
BSglossEffect = zeros(B,108);
count = 1;
for i = 1:3
    for j = 1:2
        for k = 1:3
            for l = 1:3
                for m = 1:2
                    BSglossEffect(:,count) = sa(:,1,i,j,k,l,m);
                    count = count + 1;
                end
            end
        end
    end
end

BSglossEffect_rough = zeros(B,3,36);
for i = 1:36
    for j = 1:3
        BSglossEffect_rough(:,j,i) = BSglossEffect(:,idx_rough(i,j));
    end
end
BSglossEffect_rough_mean = mean(BSglossEffect_rough,3);


% ブートストラップサンプルから求めた10000個の差から有意差の有無をチェック
ubi = round(B*97.5/100);
lbi = round(B*2.5/100);

sampleDiff = BSglossEffect_rough_mean(:,1) - BSglossEffect_rough_mean(:,2);
sdata = sort(sampleDiff);
upLim = sdata(ubi);
lowLim = sdata(lbi);
if upLim*lowLim > 0 % 有意差あり
    sigDiff = 1;
else
    sigDiff = 0;
end