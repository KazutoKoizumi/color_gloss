%% 標準偏差を求める
%clear all;

exp = 'experiment_gloss';
sn = 'all';

load(strcat('../../analysis_result/',exp,'/',sn,'/sv.mat'));
load(strcat('../../analysis_result/',exp,'/',sn,'/BSsample.mat'));

% パラメータ
diffuse = ["0.1", "0.3", "0.5"];
roughness = ["0.05", "0.1", "0.2"];
method = ["SD", "D"];
diffuseN = size(diffuse,2);
roughN = size(roughness,2);
methodN = size(method,2);

paramnum = 3*2*diffuseN*roughN*2;
idx = zeros(paramnum, 5);
B = 10000; % ブートストラップのリサンプリング回数
count = 1;
for i = 1:3 % shape
    for j = 1:2 % light
        for k = 1:diffuseN % diffuse
            for l = 1:roughN % roughness
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
    idx_diffuse(:,i) = find(idx(:,3)==i);
    idx_rough(:,i) = find(idx(:,4)==i);
    for j = 1:2
        idx_diffuse_method(:,diffuseN*(j-1)+i) = find(idx(:,3)==i & idx(:,5)==j);
        idx_rough_method(:,roughN*(j-1)+i) = find(idx(:,4)==i & idx(:,5)==j);
    end
end
for i = 1:2
    %idx_light(:,i) = find(idx(:,2)==i);
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

% diffuse,roughness,methodパラメータごとに平均を取る
% diffuseで平均
[SDnoGray_diffuse,SDnoGray_diffuse_mean] = getMean(diffuseN,idx_diffuse,SDnoGray);
% roughnessで平均
[SDnoGray_rough,SDnoGray_rough_mean] = getMean(roughN,idx_rough,SDnoGray);
% methodで平均
[SDnoGray_method,SDnoGray_method_mean] = getMean(methodN,idx_method,SDnoGray);

% diffuseとmethodで平均
[SDnoGray_diffuse_method,SDnoGray_diffuse_method_mean] = getMean(diffuseN*methodN,idx_diffuse_method,SDnoGray);
% roughnessとmethodで平均
[SDnoGray_rough_method,SDnoGray_rough_method_mean] = getMean(roughN*methodN,idx_rough_method,SDnoGray);

%% 標準偏差のプロット
% diffuse
x_label = 'diffuse';
y_label = '標準偏差';
t = 'diffuseごとの選好尺度値の標準偏差';
%f = scatterPlot(paramnum,diffuseN,SDnoGray_diffuse,SDnoGray_diffuse_mean,diffuse,x_label,y_label,t);

% roughness
x_label = 'roughness';
t = 'roughnessごとの選好尺度値の標準偏差';
%f = scatterPlot(paramnum,roughN,SDnoGray_rough,SDnoGray_rough_mean,roughness,x_label,y_label,t);

% method
x_label = '彩色方法';
t = '彩色方法ごとの選好尺度値の標準偏差';
%f = scatterPlot(paramnum,methodN,SDnoGray_method,SDnoGray_method_mean,method,x_label,y_label,t);

% diffuseごとにわけたものをSDとDにさらにわける
x_label = 'diffuse';
t = 'difffuseと彩色方法ごとの標準偏差';
xtick_param = repmat(diffuse,1,2);
f = scatterPlot(paramnum,diffuseN*methodN,SDnoGray_diffuse_method,SDnoGray_diffuse_method_mean,xtick_param,x_label,y_label,t);
hold on;
l = xline(3.5, '--');
ylim([0 0.75]);
text(1.75,0.7,'SD');
text(5.25,0.7,'D');
hold off;

% roughnessごとにわけたものをSDとDにさらにわける
x_label = 'roughness';
t = 'roughnessと彩色方法ごとの標準偏差';
xtick_param = repmat(roughness,1,2);
f = scatterPlot(paramnum,roughN*methodN,SDnoGray_rough_method,SDnoGray_rough_method_mean,xtick_param,x_label,y_label,t);
hold on;
l = xline(3.5, '--');
ylim([0 0.75]);
text(1.75,0.7,'SD');
text(5.25,0.7,'D');
hold off;

%% 有意差の有無の検定（標準偏差）
BS_SDnoGray = arrangeBS(B,BSsample,1);

sigDiff_SD_diffuse = BStest(B,BS_SDnoGray,paramnum,diffuse,diffuseN,idx_diffuse); 
sigDiff_SD_rough = BStest(B,BS_SDnoGray,paramnum,roughness,roughN,idx_rough);
sigDiff_SD_method = BStest(B,BS_SDnoGray,paramnum,method,methodN,idx_method);

sigDiff_SD_diffuse_methodSD = BStest(B,BS_SDnoGray,paramnum/methodN,diffuse,diffuseN,idx_diffuse_method(:,1:3));
sigDiff_SD_diffuse_methodD = BStest(B,BS_SDnoGray,paramnum/methodN,diffuse,diffuseN,idx_diffuse_method(:,4:6));

sigDiff_SD_rough_methodSD = BStest(B,BS_SDnoGray,paramnum/methodN,roughness,roughN,idx_rough_method(:,1:3));
sigDiff_SD_rough_methodD = BStest(B,BS_SDnoGray,paramnum/methodN,roughness,roughN,idx_rough_method(:,4:6));


%% grayからの差
% 有彩色8色の選好尺度値の平均と無彩色の選好尺度値の差を取る
svNoGray_mean = mean(svNoGray);

glossEffect = svNoGray_mean - svGray;
save('../../analysis_result/experiment_gloss/all/glossEffect/glossEffect.mat','glossEffect');

% diffuse,roughnessパラメータごとに平均を取る
% diffuseで平均
[glossEffect_diffuse,glossEffect_diffuse_mean] = getMean(diffuseN,idx_diffuse,glossEffect);
% roughnessで平均
[glossEffect_rough,glossEffect_rough_mean] = getMean(roughN,idx_rough,glossEffect);
% methodで平均
[glossEffect_method,glossEffect_method_mean] = getMean(methodN,idx_method,glossEffect);

% diffuse とmethodで平均
[glossEffect_diffuse_method,glossEffect_diffuse_method_mean] = getMean(diffuseN*methodN,idx_diffuse_method,glossEffect);
% roughnessとmethodで平均
[glossEffect_rough_method,glossEffect_rough_method_mean] = getMean(roughN*methodN,idx_rough_method,glossEffect);

%% grayからの差のプロット
% diffuse
x_label = 'diffuse';
y_label = '効果量';
t = 'diffuseごとの彩色による光沢感上昇の効果量';
f = scatterPlot(paramnum,diffuseN,glossEffect_diffuse,glossEffect_diffuse_mean,diffuse,x_label,y_label,t);

%roughness
x_label = 'roughness';
t = 'roughnessごとの彩色による光沢感上昇の効果量';
f = scatterPlot(paramnum,roughN,glossEffect_rough,glossEffect_rough_mean,roughness,x_label,y_label,t);

% method
x_label = '彩色方法';
t = '彩色方法ごとの彩色による光沢感上昇の効果量';
f = scatterPlot(paramnum,methodN,glossEffect_method,glossEffect_method_mean,method,x_label,y_label,t);

% diffuseごとにわけたものをSDとDにさらにわける
x_label = '拡散反射率';
t = 'difffuseと彩色方法ごとの効果量';
xtick_param = repmat(diffuse,1,2);
%f = scatterPlot(paramnum,diffuseN*methodN,glossEffect_diffuse_method,glossEffect_diffuse_method_mean,xtick_param,x_label,y_label,t);
hold on;
l = xline(3.5, '--');
ylim([0 4]);
%text(1.75,3.75,'全体条件');
%text(5.25,3.75,'拡散条件');
hold off;

%{
% SD彩色の場合のroughenss
x_label = 'roughness';
t = 'SD彩色でのroughnessごとの彩色による光沢感上昇の効果量';
f = scatterPlot(paramnum/methodN,roughN,glossEffect_rough_method(:,1:3),glossEffect_rough_method_mean(:,1:3),roughness,x_label,y_label,t);

% D彩色の場合のroughness
x_label = 'roughness';
t = 'D彩色でのroughnessごとの彩色による光沢感上昇の効果量';
f = scatterPlot(paramnum/methodN,roughN,glossEffect_rough_method(:,4:6),glossEffect_rough_method_mean(:,4:6),roughness,x_label,y_label,t);
%}

% roughnessごとにわけたものをSDとDにさらにわける
x_label = 'roughness';
t = 'roughnessと彩色方法ごとの効果量';
xtick_param = repmat(roughness,1,2);
f = scatterPlot(paramnum,roughN*methodN,glossEffect_rough_method,glossEffect_rough_method_mean,xtick_param,x_label,y_label,t);
hold on;
l = xline(3.5, '--');
ylim([0 4]);
text(1.75,3.75,'SD');
text(5.25,3.75,'D');
hold off;


%% 有意差の有無の検定
BSglossEffect = arrangeBS(B,BSsample,2);

%sigDiff_diffuse = BStest(B,BSglossEffect,paramnum,diffuse,diffuseN,idx_diffuse);
%sigDiff_rough = BStest(B,BSglossEffect,paramnum,roughness,roughN,idx_rough);
%sigDiff_method = BStest(B,BSglossEffect,paramnum,method,methodN,idx_method);

sigDiff_diffuse_methodSD = BStest(B,BSglossEffect,paramnum/methodN,diffuse,diffuseN,idx_diffuse_method(:,1:3));
sigDiff_diffuse_methodD = BStest(B,BSglossEffect,paramnum/methodN,diffuse,diffuseN,idx_diffuse_method(:,4:6));

sigDiff_rough_methodSD = BStest(B,BSglossEffect,paramnum/methodN,roughness,roughN,idx_rough_method(:,1:3));
sigDiff_rough_methodD = BStest(B,BSglossEffect,paramnum/methodN,roughness,roughN,idx_rough_method(:,4:6));


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

%% 散布図プロット用の関数
% roughness,diffuse,method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input
%  paramAll : 全パラメータの組み合わせの数（条件数）
%  paramNum : パラメータの個数
%  value : 値全て
%  value_mean : 平均値
%  x_tick : x軸の軸ラベル
%  x_label : x軸のラベル
%  y_label : y軸のラベル
%  t : タイトル
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f = scatterPlot(paramAll,paramNum,value,value_mean,x_tick,x_label,y_label,t)
    
    figure;
    x_mean = 1:paramNum;
    
    %{
    x = reshape(repmat(x_mean,paramAll/paramNum,1),1,paramAll);
    y = reshape(value, 1, paramAll);
    scatter(x,y);
    hold on;
    scatter(x_mean,value_mean,72,[1 0 0],'filled');
    %}
    
    % diffuse,method以外のパラメータが同じ刺激を結ぶ
    for i = 1:paramAll/paramNum
        for m = 1:2
            p = plot(x_mean(3*(m-1)+1:3*m),value(i,3*(m-1)+1:3*m),'--o','Color',[0 0.4470 0.7410]);
            hold on;
        end
    end
    plot(x_mean(1:3),value_mean(1,1:3),'-o','Color',[1,0,0],'LineWidth',1.5);
    plot(x_mean(4:6),value_mean(1,4:6),'-o','Color',[1,0,0],'LineWidth',1.5);
    scatter(x_mean,value_mean,72,[1 0 0],'filled');
    
    % グラフの設定
    xlim([0 paramNum+1]);
    xticks(x_mean);
    xticklabels(x_tick);
    xlabel(x_label);
    ylabel(y_label);
    title(t, 'FontSize',13);
    set(gca, "FontName", "Noto Sans CJK JP");
    hold off;
    
    f = 1;
end

%% ブートストラップサンプルの整理
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input
%  B : リサンプリング回数
%  sample : ブートストラップ標本
%  flag : 1=標準偏差, 2=grayからの差
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function arrangeSample = arrangeBS(B,sample,flag)
    
    if flag == 1
        value = std(sample(:,2:9,:,:,:,:,:),0,2);
    elseif flag == 2
        BS_mean = mean(sample(:,2:9,:,:,:,:,:),2);
        value = BS_mean - sample(:,1,:,:,:,:,:);
    end       
        
    arrangeSample = zeros(B,108);
    count = 1;
    for i = 1:3
        for j = 1:2
            for k = 1:3
                for l = 1:3
                    for m = 1:2
                        arrangeSample(:,count) = value(:,1,i,j,k,l,m);
                        count = count + 1;
                    end
                end
            end
        end
    end
    
    a = 1;
    
end

%% ブートストラップ検定
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input
%  B : リサンプリング数
%  arrangeSample : 整理後のブートストラップ標本
%  paramAll : 全パラメータの組み合わせの数（条件数）
%  param : パラメータ
%  paramNum : パラメータ数
%  idx : パラメータのインデックス
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sigDiffTable = BStest(B,arrangeSample,paramAll,param,paramNum,idx)
    
    alpha = 5;
    if paramNum > 2
        alpha = 5/paramNum;
    end

    BSvalue_param = zeros(B,paramNum,paramAll/paramNum);
    for i = 1:paramAll/paramNum
        for j = 1:paramNum
           BSvalue_param(:,j,i) = arrangeSample(:,idx(i,j));
        end
    end
    BSvalue_param_mean = mean(BSvalue_param,3);
    
    ubi = round(B*(100-alpha)/100);
    lbi = round(B*alpha/100);
    
    comb = nchoosek(1:paramNum,2);
    combination = param(comb);
    sigDiff = zeros(1,size(comb,1));
    for i = 1:size(comb,1)
        sampleDiff = BSvalue_param_mean(:,comb(i,1)) - BSvalue_param_mean(:,comb(i,2));
        sdata = sort(sampleDiff);
        upLim = sdata(ubi);
        lowLim = sdata(lbi);
        if upLim*lowLim > 0 % 有意差あり
            sigDiff(i) = 1;
        else
            sigDiff(i) = 0;
        end
    end
    
    sigDiffTable = table(combination,sigDiff');

end