%% 相関係数を求める

exp = 'experiment_gloss';
sn = 'all';

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

%% 推定値から求める
load(strcat('../../analysis_result/',exp,'/',sn,'/sv.mat'));

sValue = zeros(9, paramnum);
for i = 1:paramnum
    sValue(:,i) = sv(:,:,idx(i,1),idx(i,2),idx(i,3),idx(i,4),idx(i,5))';
end

% 相関係数
R = corrcoef(sValue);

% パラメータでわける、形状・照明
R_shape_light = zeros(18,18,6);
for i = 1:6
    R_shape_light(:,:,i) = R((i-1)*18+1:i*18,(i-1)*18+1:i*18);
end

% 各パラメータごとに相関係数の平均を求める
% shape, diffuse, roughness
for i = 1:3
    idx_shape(:,i) = find(idx(:,1)==i);
    idx_diffuse(:,i) = find(idx(:,3)==i);
    idx_rough(:,i) = find(idx(:,4)==i);
end
R_shape = zeros(36,3);
R_diffuse = zeros(36,3);
R_rough = zeros(36,3);
for i = 1:36
    for j = 1:3
        l = j+1;
        if l>3
            l=rem(l,3);
        end
        R_shape(i,j) = R(idx_shape(i,j),idx_shape(i,l));
        R_diffuse(i,j) = R(idx_diffuse(i,j),idx_diffuse(i,l));
        R_rough(i,j) = R(idx_rough(i,j),idx_rough(i,l));
    end
end
R_shape_mean = mean(R_shape);
R_diffuse_mean = mean(R_diffuse);
R_rough_mean = mean(R_rough);

% light, method
for i = 1:2
    idx_light(:,i) = find(idx(:,2)==i);
    idx_method(:,i) = find(idx(:,5)==i);
end
R_light = zeros(54,1);
R_method = zeros(54,1);
for i = 1:54
    R_light(i) = R(idx_light(i,1),idx_light(i,2));
    R_method(i) = R(idx_method(i,1),idx_method(i,2));
end
R_light_mean = mean(R_light);
R_method_mean = mean(R_method);


%% ブートストラップサンプルから相関係数のばらつき（標準偏差と95％信頼区間）求める
% 10000個の相関係数を求めて、そこからばらつきを求める
load(strcat('../../analysis_result/',exp,'/',sn,'/BSsample.mat'));

sValueBS = zeros(9, paramnum, B);
R_BS = zeros(paramnum,paramnum,B);
for i = 1:B
    for j = 1:paramnum
        sValueBS(:,j,i) = BSsample(i,:,idx(j,1),idx(j,2),idx(j,3),idx(j,4),idx(j,5))';
    end
    R_BS(:,:,i) = corrcoef(sValueBS(:,:,i));
end

ubi = round(B*97.5/100);
lbi = round(B*2.5/100);
sdata = sort(R_BS,3);
R_range(:,:,1) = sdata(:,:,lbi) - R(:,:); % 下限
R_range(:,:,2) = sdata(:,:,ubi) - R(:,:); % 上限
R_range(:,:,3) = R(:,:); % 推定値

 

