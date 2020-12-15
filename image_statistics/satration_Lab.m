%% Lab色空間で彩度を求めて、ハイライトとそれ以外の領域の色度コントラストを定義する

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

paramnum = 3*2*diffuseN*roughN*2;

%% 基準白色点
load('../../mat/ccmat');
cx2u = makecform('xyz2upvpl');
wp_rgb = [1 1 1];
wp_XYZ = TNT_rgb2XYZ(wp_rgb',ccmat)';
%prop = wp_XYZ(2);
%wp_XYZ = wp_XYZ ./ prop;
wp_upvpl = applycform(wp_XYZ,cx2u);

%% ハイライトとハイライトの周辺領域のマスクマップ
load('../../mat/highlight/highlightMap.mat');

%% Main
colorContrast = zeros(8,108); % 色度座標間のユークリッド距離
contrast = zeros(8,108); % コントラスト
chroma = zeros(8,108); % 全体の平均彩度（chroma）
chromaHL = zeros(8,108); % ハイライト領域の平均彩度
chromaHLno = zeros(8,108); % 非ハイライト領域の平均彩度
lab_mean = zeros(108,6); % 色相考慮していない
progress = 1;
for i = 1:3 % shape
    load(strcat('../../mat/',shape(i),'Mask/mask.mat'));
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                % ハイライトとそれ以外の領域のマスクマップ
                %HL_mask = highlightMap(:,:,1,i,j,3);
                %HLno_mask = highlightMap(:,:,2,i,j,3);
                
                %% データ読み込み
                load(strcat('../../mat_analysis/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredSD.mat'));
                load(strcat('../../mat_analysis/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredD.mat'));
                [iy,ix,iz] = size(coloredSD(:,:,:,1));
                
                for n = 2:9 % color
                    %% 色空間変換  XYZ -> L*a*b*
                    lab = zeros(iy,ix,iz,2);
                    lab(:,:,:,1) = xyz2lab(coloredSD(:,:,:,n),'WhitePoint', wp_XYZ);
                    lab(:,:,:,2) = xyz2lab(coloredD(:,:,:,n),'WhitePoint', wp_XYZ);
                    
                    upvpl =zeros(iy,ix,iz,2);
                    upvpl(:,:,:,1) = applycform(coloredSD(:,:,:,n),cx2u);
                    upvpl(:,:,:,2) = applycform(coloredD(:,:,:,n),cx2u);
                    
                    
                    for m = 1:2 % method   
                        count = 36*(i-1) + 18*(j-1) + 6*(k-1) + 2*(l-1) + m;
                        
                        % ハイライト領域、ハイライト以外の領域のLab
                        labHL = lab(:,:,:,m) .* highlightMap(:,:,1,i,j,k);
                        labHLno = lab(:,:,:,m) .* highlightMap(:,:,2,i,j,k);
                        %labHLno = lab(:,:,:,m) .* (mask - highlightMap(:,:,1,i,j,k));
                        
                        %labHL = upvpl(:,:,:,m) .* highlightMap(:,:,1,i,j,k);
                        %labHLno = upvpl(:,:,:,m) .* highlightMap(:,:,2,i,j,k);
                        %labHLno = lab(:,:,:,m) .* (mask - highlightMap(:,:,1,i,j,k));
                        
                        lab_list = zeros(nnz(lab(:,:,:,m).*mask)/3,3);
                        labHL_list = zeros(nnz(labHL)/3,3);
                        labHLno_list = zeros(nnz(labHLno)/3,3);
                        for p =1:3
                            lab_temp = lab(:,:,p,m) .* mask;
                            lab_temp(lab_temp==0) = [];
                            lab_list(:,p) = lab_temp;
                            
                            HL_temp = labHL(:,:,p);
                            HL_temp(HL_temp==0) = [];
                            HLno_temp = labHLno(:,:,p);
                            HLno_temp(HLno_temp==0) = [];
                            
                            labHL_list(:,p) = HL_temp;
                            labHLno_list(:,p) = HLno_temp;
                        end
                        
                        % 平均色度座標
                        labHL_mean = mean(labHL_list);
                        labHLno_mean = mean(labHLno_list);
                        lab_mean(count,1:3) = labHL_mean;
                        lab_mean(count,4:6) = labHLno_mean;
                        
                        %% 彩度を求める
                        % 全体
                        chroma_list = sqrt(sum(lab_list(:,2:3).^2,2));
                        chroma(n-1,count) = mean(chroma_list);
                        % ハイライト領域と非ハイライト領域それぞれ
                        chromaHL_list = sqrt(sum(labHL_list(:,2:3).^2,2));
                        chromaHLno_list = sqrt(sum(labHLno_list(:,2:3).^2,2));
                        chromaHL(n-1,count) = mean(chromaHL_list);
                        chromaHLno(n-1,count) = mean(chromaHL_list);
                        
                        %% 色度コントラストを求める
                        % ハイライトとそれ以外の領域のそれぞれで平均色度座標を算出
                        % それらのユークリッド距離を求める
                        vec = labHL_mean - labHLno_mean;
                        colorContrast(n-1,count) = norm(vec(2:3));
                        contrast(n-1,count) = norm(vec);
                        %contrast(n-1,count)
                    end
                end
                
                %% 進行度表示
                fprintf('finish : %d/54\n\n', progress);
                progress = progress + 1;
                
            end
        end
    end
end
%}

%% データ整理
%% パラメータのインデックス
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

%% diffuse、roughnessパラメータごとに色度コントラストの平均を取る
% diffuseとmethodで平均
[contrast_diffuse_method,contrast_diffuse_method_mean] = getMean(diffuseN*methodN,idx_diffuse_method,contrast(1,:));
% roughnessとmethodで平均
[contrast_rough_method,contrast_rough_method_mean] = getMean(roughN*methodN,idx_rough_method,contrast(1,:));

% プロット
% diffuse, method
x_label = 'diffuse';
y_label = '色度コントラスト';
t = 'diffuseと彩色方法ごとの色度コントラスト';
xtick_param = repmat(diffuseVar,1,2);
f = scatterPlot(paramnum,diffuseN*methodN,contrast_diffuse_method,contrast_diffuse_method_mean,xtick_param,x_label,y_label,t);
hold on;
l = xline(3.5, '--');
ylim([0 9]);
text(1.75,8.5,'SD');
text(5.25,8.5,'D');
hold off

% roughness method
x_label = 'roughness';
t = 'roughnessと彩色方法ごとの色度コントラスト';
xtick_param = repmat(roughVar,1,2);
f = scatterPlot(paramnum,roughN*methodN,contrast_rough_method,contrast_rough_method_mean,xtick_param,x_label,y_label,t);
hold on;
l = xline(3.5, '--');
%ylim([0 0.052]);
%text(1.75,0.05,'SD');
%text(5.25,0.05,'D');
hold off

%% 横軸a、縦軸Lでプロット
HL_SD = lab_mean(1:2:108,1:3);
noHL_SD = lab_mean(1:2:108,4:6);
HL_D = lab_mean(2:2:108,1:3);
noHL_D = lab_mean(2:2:108,4:6);

% プロット
figure
hold on;
%scatter(HL_SD(:,2)',HL_SD(:,1)',[],'b');
%scatter(noHL_SD(:,2)',noHL_SD(:,1)',[],'r');
%scatter(HL_D(:,2)',HL_D(:,1)',[],'b','s');
%scatter(noHL_D(:,2)',noHL_D(:,1)',[],'r','s');

scatter(mean(HL_SD(:,2)),mean(HL_SD(:,1)),[],'b','filled');
scatter(mean(noHL_SD(:,2)),mean(noHL_SD(:,1)),[],'b','s','filled');
scatter(mean(HL_D(:,2)),mean(HL_D(:,1)),[],'r','filled');
scatter(mean(noHL_D(:,2)),mean(noHL_D(:,1)),[],'r','s','filled');
xlim([0 30]);
ylim([0 50]);
title('平均色度');
xlabel('a*');
ylabel('L*');
legend('SD, ハイライト','SD, diffuse','D, ハイライト','D, diffuse');
legend('Location','southeast');
hold off;


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
