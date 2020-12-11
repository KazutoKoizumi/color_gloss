%% ハイライトとそれ以外の領域の彩度をそれぞれ求める

clear all;
%% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["alpha005", "alpha01", "alpha02"]; %l
method = ["SD", "D"];
diffuseVar = ["0.1", "0.3", "0.5"];
roughVar = ["0.05", "0.1", "0.2"];
diffuseN = size(diffuse,2);
roughN = size(roughness,2);
methodN = size(method,2);

allObj = 3*2*3*3*2;
paramnum = 3*2*diffuseN*roughN*2;
progress = 1;

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
    %idx_shape(:,i) = find(idx(:,1)==i);
    idx_diffuse(:,i) = find(idx(:,3)==i);
    idx_rough(:,i) = find(idx(:,4)==i);
    for j = 1:2
        %idx_shape_method(:,3*(j-1)+i) = find(idx(:,1)==i & idx(:,5)==j);
        idx_diffuse_method(:,diffuseN*(j-1)+i) = find(idx(:,3)==i & idx(:,5)==j);
        idx_rough_method(:,roughN*(j-1)+i) = find(idx(:,4)==i & idx(:,5)==j);
    end
end

load('../../mat/upvplWhitePoints.mat');
load('../../mat/saturationMax.mat');
[~,iMax] = max(saturationMax);

load('../../mat/highlight/highlightMap.mat');

%% Main
highlightSat = zeros(2,108);
for i = 1:3 % shape
    load(strcat('../../mat/',shape(i),'Mask/mask.mat'));
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                %% データ読み込み
                load(strcat('../../mat_analysis/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredSD.mat'));
                load(strcat('../../mat_analysis/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredD.mat'));
                [iy,ix,iz] = size(coloredSD(:,:,:,1));
                
                %% 色空間変換
                upvpl = zeros(iy,ix,iz,2); % 1:SD, 2:D
                cx2u = makecform('xyz2upvpl');
                upvpl(:,:,:,1) = applycform(coloredSD(:,:,:,2),cx2u);
                upvpl(:,:,:,2) = applycform(coloredD(:,:,:,2),cx2u);
                
                %% 彩度を記録
                HL_mask = highlightMap(:,:,1,i,j,3);
                %HLno_mask = mask-highlightMap(:,:,1,i,j,3);
                HLno_mask = highlightMap(:,:,2,i,j,3);
                satHighlight = zeros(1,nnz(HL_mask));
                satNoHighlight = zeros(1,nnz(HLno_mask));
                
                for m = 1:2 % method
                    count = [0 0 0]; % [all, highlight, nohighlight]
                    for p = 1:iy
                        for q = 1:ix
                            if mask(p,q)==1
                                count(1) = count(1) + 1;
                                
                                % 輝度チェック
                                if upvpl(p,q,3,m) <= upvplWhitePoints(iMax,3)
                                    idx = find(upvplWhitePoints(:,3)<upvpl(p,q,3,m), 1, 'last');
                                    if isempty(idx) == 1
                                        idx = 1;
                                    end
                                else
                                    idx = find(upvplWhitePoints(:,3)>upvpl(p,q,3,m), 1);
                                    if isempty(idx) == 1
                                        idx = find(upvplWhitePoints(:,3),1,'last');
                                    end
                                end
                                
                                % 白色点からの変位
                                displacement = zeros(1,2);
                                displacement(1) = upvpl(p,q,1,m) - upvplWhitePoints(idx,1);
                                displacement(2) = upvpl(p,q,2,m) - upvplWhitePoints(idx,2);
                                
                                % 彩度
                                sat = sqrt(sum(displacement.^2));
                                
                                % ハイライト
                                if HL_mask(p,q) == 1
                                    count(2) = count(2) + 1;
                                    satHighlight(count(2)) = sat;
                                end
                                if HLno_mask(p,q) == 1 % ハイライト周辺
                                    count(3) = count(3) + 1;
                                    satNoHighlight(count(3)) = sat;
                                end
                                
                            end
                        end
                    end
                    
                    % 平均彩度
                    highlightSat(:,progress) = [mean(satHighlight);mean(satNoHighlight)];
                    
                    %% 進行度表示
                    fprintf('finish : %d/%d\n\n', progress, allObj);
                    progress = progress + 1;
                end
            end
        end
    end
end
%}

%% ハイライト領域についてdiffuse,roughnessパラメータごとに平均を取る
% diffuseとmethodで平均
[HLsat_diffuse_method,HLsat_diffuse_method_mean] = getMean(diffuseN*methodN,idx_diffuse_method,highlightSat(1,:));
% roughnessとmethodで平均
[HLsat_rough_method,HLsat_rough_method_mean] = getMean(roughN*methodN,idx_rough_method,highlightSat(1,:));

% プロット
% diffuse method
x_label = 'diffuse';
y_label = '彩度';
t = 'difffuseと彩色方法ごとのハイライト領域の彩度';
xtick_param = repmat(diffuseVar,1,2);
f = scatterPlot(paramnum,diffuseN*methodN,HLsat_diffuse_method,HLsat_diffuse_method_mean,xtick_param,x_label,y_label,t);
hold on;
l = xline(3.5, '--');
ylim([0 0.052]);
text(1.75,0.05,'SD');
text(5.25,0.05,'D');
hold off

% roughenss method
x_label = 'roughness';
t = 'roughnessと彩色方法ごとのハイライト領域の彩度';
xtick_param = repmat(roughVar,1,2);
f = scatterPlot(paramnum,roughN*methodN,HLsat_rough_method,HLsat_rough_method_mean,xtick_param,x_label,y_label,t);
hold on;
l = xline(3.5, '--');
ylim([0 0.052]);
text(1.75,0.05,'SD');
text(5.25,0.05,'D');
hold off


%% ハイライト以外の領域について平均
% diffuseとmethodで平均
[noHLsat_diffuse_method,noHLsat_diffuse_method_mean] = getMean(diffuseN*methodN,idx_diffuse_method,highlightSat(2,:));
% roughnessとmethodで平均
[noHLsat_rough_method,noHLsat_rough_method_mean] = getMean(roughN*methodN,idx_rough_method,highlightSat(2,:));

% プロット
% diffuse method
x_label = 'diffuse';
t = 'diffuseと彩色方法ごとのハイライト領域以外の彩度';
xtick_param = repmat(diffuseVar,1,2);
f = scatterPlot(paramnum,diffuseN*methodN,noHLsat_diffuse_method,noHLsat_diffuse_method_mean,xtick_param,x_label,y_label,t);
hold on;
l = xline(3.5, '--');
ylim([0 0.052]);
text(1.75,0.05,'SD');
text(5.25,0.05,'D');
hold off

% roughness method
x_label = 'roughness';
t = 'roughnessと彩色方法ごとのハイライト領域以外の彩度';
xtick_param = repmat(roughVar,1,2);
f = scatterPlot(paramnum,roughN*methodN,noHLsat_rough_method,noHLsat_rough_method_mean,xtick_param,x_label,y_label,t);
hold on;
l = xline(3.5, '--');
ylim([0 0.052]);
text(1.75,0.05,'SD');
text(5.25,0.05,'D');
hold off

%% コントラスト
contrast = abs(highlightSat(1,:) - highlightSat(2,:));
% プロット
[contrast_diffuse_method,contrast_diffuse_method_mean] = getMean(diffuseN*methodN,idx_diffuse_method,contrast);
x_label = 'diffuse';
y_label = '色度コントラスト';
t = 'diffuseと彩色方法ごとの色度コントラスト';
xtick_param = repmat(diffuseVar,1,2);
f = scatterPlot(paramnum,diffuseN*methodN,contrast_diffuse_method,contrast_diffuse_method_mean,xtick_param,x_label,y_label,t);
hold on;
l = xline(3.5, '--');
%ylim([0 0.052]);
%text(1.75,0.05,'SD');
%text(5.25,0.05,'D');
hold off

%% 保存
save('../../mat/highlight/highlightSat.mat','highlightSat');

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
    x = reshape(repmat(x_mean,paramAll/paramNum,1),1,paramAll);
    y = reshape(value, 1, paramAll);
    scatter(x,y);
    hold on;
    scatter(x_mean,value_mean,72,[1 0 0],'filled');
    
    % グラフの設定
    xlim([0 paramNum+1]);
    xticks(x_mean);
    xticklabels(x_tick);
    xlabel(x_label);
    ylabel(y_label);
    title(t, 'FontSize',13);
    hold off;
    
    f = 1;
end
                