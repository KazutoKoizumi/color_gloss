%% 標準偏差を求める

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

%% grayを覗いた有彩色の標準偏差
% 推定値から求める
load(strcat('../../analysis_result/',exp,'/',sn,'/sv.mat'));

sValueNoGray = zeros(8, paramnum);
for i = 1:paramnum
    sValueNoGray(:,i) = sv(:,2:9,idx(i,1),idx(i,2),idx(i,3),idx(i,4),idx(i,5))';
end

SD_NoGray = std(sValueNoGray);


%% grayからの差
%{
% gray含めて全色でまとめて標準偏差を求める
sValue = zeros(9, paramnum);
for i = 1:paramnum
    sValue(:,i) = sv(:,:,idx(i,1),idx(i,2),idx(i,3),idx(i,4),idx(i,5))';
end

SD = std(sValue);
%}

% grayとある1色の標準偏差を求めて、その平均を取る
sValue_one_ave = zeros(2,8,108);
for i = 1:paramnum
    sValue_one_ave(1,:,i) = sv(:,1,idx(i,1),idx(i,2),idx(i,3),idx(i,4),idx(i,5))';
    for j = 2:9
        sValue_one_ave(2,j,i) = sv(:,j,idx(i,1),idx(i,2),idx(i,3),idx(i,4),idx(i,5))';
    end
end
    
SD_colors = std(sValue_one_ave);
SD = reshape(mean(SD_colors),1,108); 

%{
% 選好尺度値の平均 → 標準偏差
sValue_ave_one = zeros(2,108);
for i = 1:paramnum
    sValue_ave_one(1,i) = sv(:,1,idx(i,1),idx(i,2),idx(i,3),idx(i,4),idx(i,5))';
    sValue_ave_one(2,i) = mean(sv(:,2:9,idx(i,1),idx(i,2),idx(i,3),idx(i,4),idx(i,5)));
end

SD_ave_one = std(sValue_ave_one);
%}
