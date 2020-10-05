%% 相関係数を求める

exp = 'experiment_gloss';
sn = 'all';

paramnum = 3*2*3*3*2;
idx = zeros(paramnum, 5);
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

%% ブートストラップサンプルから相関係数のばらつき（標準偏差と95％信頼区間）求める
% 10000個の相関係数を求めて、そこからばらつきを求める
load(strcat('../../analysis_result/',exp,'/',sn,'/BSsample.mat'));

