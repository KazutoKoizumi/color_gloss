%% 相関係数を求める
clear all;

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

for i = 1:3
    idx_shape(:,i) = find(idx(:,1)==i);
    idx_diffuse(:,i) = find(idx(:,3)==i);
    idx_rough(:,i) = find(idx(:,4)==i);
    for j = 1:2
        idx_diffuse_method(:,3*(j-1)+i) = find(idx(:,3)==i & idx(:,5)==j);
        idx_rough_method(:,3*(j-1)+i) = find(idx(:,4)==i & idx(:,5)==j);
    end
end

for i = 1:2
    idx_light(:,i) = find(idx(:,2)==i);
    idx_method(:,i) = find(idx(:,5)==i);
end

%% 推定値から求める
load(strcat('../../analysis_result/',exp,'/',sn,'/sv.mat'));

sValue = zeros(9, paramnum);
for i = 1:paramnum
    sValue(:,i) = sv(:,:,idx(i,1),idx(i,2),idx(i,3),idx(i,4),idx(i,5))';
end

% 相関係数
R = corrcoef(sValue);

% SD条件同士、D条件同士、SDとD条件間の相関係数の3種にわける
n = 1:108;
comb = nchoosek(n,2);
count = ones(1,3);
for i = 1:size(comb,1)
    flag = evenOdd(comb(i,1),comb(i,2));  % 1:SD, 2:D, 3:SDvsD
    if flag == 1
        R_method_SD(count(flag)) = R(comb(i,1),comb(i,2));
    elseif flag == 2
        R_method_D(count(flag)) = R(comb(i,1),comb(i,2));
    elseif flag == 3
        R_method_SDvsD(count(flag)) = R(comb(i,1),comb(i,2));
    end
    count(flag) = count(flag)+1;
end
R_method_mean = [mean(R_method_SD),mean(R_method_D),mean(R_method_SDvsD)];
    

% 各パラメータにわける
% diffuseが変化したときのSD条件とD条件間の相関係数
idxSort_diffuse_method = sort(idx_diffuse_method,2);
[R_diffuse_SDvsD, R_diffuse_SDvsD_maen] = getMean(3,idxSort_diffuse_method,R);

% roughnessが変化したときのSD条件とD条件間の相関係数
idxSort_rough_method = sort(idx_rough_method,2);
[R_rough_SDvsD, R_rough_SDvsD_maen] = getMean(3,idxSort_rough_method,R);

%% プロット
% diffuse
x_label = 'diffuse';
t = 'diffuseごとの相関係数';


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


%% パラメータが変化したときの、SD・D彩色条件間の相関係数とその平均
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input
%  paramNum : パラメータの個数(SD・Dについては除く)
%  idx : パラメータのインデックス
%  value : 値

% Output
%  v : パラメータごとに値をわける（列がパラメータ）
%  v_mean : パラメータごとの平均
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [v, v_mean] = getMean(paramNum,idx,value)

    v = zeros(54/paramNum,paramNum);
    for i = 1:54/paramNum
        for j = 1:paramNum
            v(i,j) = value(idx(i,2*j-1),idx(i,2*j));
        end
    end
    
    v_mean = mean(v);
    
end
 
%% 散布図プロット用の関数
% roughness,diffuse,method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input
%  paramNum : パラメータの個数
%  value : 値全て
%  value_mean : 平均値
%  x_tick : x軸の軸ラベル
%  x_label : x軸のラベル
%  t : タイトル
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f = scatterPlot(paramNum,value,value_mean,x_tick,x_label,t)
    
    figure;
    x_mean = 1:paramNum;
    x = reshape(repmat(x_mean,108/paramNum,1),1,108);
    y = reshape(value, 1, 108);
    scatter(x,y);
    hold on;
    scatter(x_mean,value_mean,72,[1 0 0],'filled');
    
    % グラフの設定
    xlim([0 paramNum+1]);
    xticks(x_mean);
    xticklabels(x_tick);
    xlabel(x_label);
    ylabel('相関係数');
    title(t, 'FontSize',13);
    hold off;
    
    f = 1;
end

%% 偶奇の一致を調べる

function flag = evenOdd(n1,n2)

    if rem(n1,2)==1 && rem(n2,2)==1  % 両方奇数
        flag = 1;
    elseif rem(n1,2)==0 && rem(n2,2)==0  % 両方奇数
        flag = 2;
    elseif rem(n1,2)+rem(n2,2) == 1  % 一方が偶数、一方が奇数
        flag = 3;
    end
    
end