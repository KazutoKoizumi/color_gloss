%% H-K効果と色度コントラストから光沢を回帰
clear all;

load('../../analysis_result/experiment_gloss/all/sv.mat');
load('../../analysis_result/experiment_gloss/all/glossEffect/glossEffect.mat');
load('../../mat/HKeffect/HKstimuli.mat');
load('../../mat/contrast/contrast.mat');
load('../../mat/contrast/contrastLab.mat');

graphColor = [[0 0 0]; [1 0 0]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0 1 0]; 
            [0.4660 0.6740 0.1880]; [0.310 0.7450 0.9330]; [0 0.4470 0.7410]; [1 0 1]];
gridNum = 30;
        
paramnum = 108;
idx = zeros(paramnum, 5);
idx_noMethod = zeros(54,4);
count = 1;
count_noMethod = 1;
for i = 1:3 % shape
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                idx_noMethod(count_noMethod,:) = [i,j,k,l];
                count_noMethod = count_noMethod + 1;
                for m = 1:2 % SD or D
                    idx(count,:) = [i, j, k, l, m];
                    count = count + 1;
                end
            end
        end
    end
end

for i = 1:3
    idx_diffuse(:,i) = find(idx(:,3)==i);
    idx_rough(:,i) = find(idx(:,4)==i);
    idx_diffuse_noMethod(:,i) = find(idx_noMethod(:,3)==i);
    for j = 1:2
        idx_diffuse_method(:,3*(j-1)+i) = find(idx(:,3)==i & idx(:,5)==j);
        idx_rough_method(:,3*(j-1)+i) = find(idx(:,4)==i & idx(:,5)==j);
    end
end

gloss = zeros(9, 108);
for i = 1:paramnum
    gloss(:,i) = sv(:,:,idx(i,1),idx(i,2),idx(i,3),idx(i,4),idx(i,5))';
end
gray = repmat(gloss(1,:),[8,1]);
%gloss_SD = reshape(gloss(:,1:2:108),[9*54,1]);
%gloss_D = reshape(gloss(:,2:2:108),[9*54,1]);
gloss_SD = zscore(reshape(gloss(:,1:2:108),[9*54,1]));
gloss_D = zscore(reshape(gloss(:,2:2:108),[9*54,1]));

%glossColor = gloss(2:9,:) - gray;

HK = HKstimuli(:,:,1);
% grayを含めたH-K効果, grayのH-K効果を1とする
HKall = ones(9,108);
HKall(2:9,:) = HK;
HK_SD_z = zscore(reshape(HKall(:,1:2:108),[9*54,1])); 
HK_D_z = zscore(reshape(HKall(:,2:2:108),[9*54,1]));
%HKallZscore = zscore(HKall,0,1);

% grayを含めた色度コントラスト, u'v'L色度, grayの色度コントラストを0とする
contrastAll = zeros(9,108);
contrastAll(2:9,:) = repmat(contrast,[8 1]);
contrast_SD_z = zscore(reshape(contrastAll(:,1:2:108),[9*54,1]));
contrast_D_z = zscore(reshape(contrastAll(:,2:2:108),[9*54,1]));
%contrastAllZscore = zscore(contrastAll,0,1);

% zscore化
%HKzscore = zscore(HK,0,1);
%contrastLabZscore = zscore(contrastLab,0,1);


%% 光沢感回帰
%% SD条件についてH-Kで回帰
y = reshape(gloss(:,1:2:108), [9*54,1]);
x1 = reshape(HKall(:,1:2:108), [9*54,1]);
md_SD_HK = fitlm(x1,y)

%% SD条件についてH-Kと色度差で回帰
y = gloss_SD;
x1 = HK_SD_z;
x2 = contrast_SD_z;
%x1 = reshape(HKallZscore(:,1:2:108), [9*54,1]);
%x2 = reshape(contrastAllZscore(:,1:2:108), [9*54,1]);
X = [x1 x2];
md_SD_HK_cont = fitlm(X,y)

% プロット
figure;
%scatter3(x1,x2,y,'filled');

% diffuseごとに整理
colorMarker = [[0 0.4470 0.7410];[0.8500 0.3250 0.0980];[0.9290 0.6940 0.1250]];
HK_hue = reshape(HK_SD_z,[9,54]);
cont_hue = reshape(contrast_SD_z,[9,54]);
gloss_hue = reshape(gloss_SD,[9,54]);
HK_diffuse_method = zeros(18,6,9);
cont_diffuse_method = zeros(18,6,9);
gloss_diffuse_method = zeros(18,6,9);
for i = 1:9 % hue
    HK_diffuse_method(:,1:3,i) = arrangeParam(54,3,idx_diffuse_noMethod,HK_hue(i,:));
    cont_diffuse_method(:,1:3,i) = arrangeParam(54,3,idx_diffuse_noMethod,cont_hue(i,:));
    gloss_diffuse_method(:,1:3,i) = arrangeParam(54,3,idx_diffuse_noMethod,gloss_hue(i,:));
end

for i = 1:3 % diffuse
    for j = 1:9 % hue
        scatter3(HK_diffuse_method(:,i,j),cont_diffuse_method(:,i,j),gloss_diffuse_method(:,i,j),'filled','MarkerFaceColor',graphColor(j,:));
        hold on;
    end
end
hold on;
[x1_grid,x2_grid] = meshgrid(linspace(min(x1),max(x1),gridNum),linspace(min(x2),max(x2),gridNum));
z = md_SD_HK_cont.Coefficients.Estimate(1) + md_SD_HK_cont.Coefficients.Estimate(2)*x1_grid + md_SD_HK_cont.Coefficients.Estimate(3)*x2_grid;
mesh(x1_grid,x2_grid,z);
xlabel('H-K効果');
ylabel('色度コントラスト');
zlabel('光沢感')
title('SD条件　光沢感');
set(gca, "FontName", "Noto Sans CJK JP");
hold off;

%% D条件についてH-Kで回帰
y = reshape(gloss(:,2:2:108), [9*54,1]);
x1 = reshape(HKall(:,2:2:108), [9*54,1]);
md_D_HK = fitlm(x1,y)

%% D条件についてH-Kと色度差で回帰
y = gloss_D;
x1 = HK_D_z;
x2 = contrast_D_z;
%x1 = reshape(HKallZscore(:,2:2:108), [9*54,1]);
%x2 = reshape(contrastAllZscore(:,2:2:108), [9*54,1]);
X = [x1 x2];
md_D_HK_cont = fitlm(X,y)

% プロット
figure;
HK_hue = reshape(HK_D_z,[9,54]);
cont_hue = reshape(contrast_D_z,[9,54]);
gloss_hue = reshape(gloss_D,[9,54]);
for i = 1:9 % hue
    HK_diffuse_method(:,4:6,i) = arrangeParam(54,3,idx_diffuse_noMethod,HK_hue(i,:));
    cont_diffuse_method(:,4:6,i) = arrangeParam(54,3,idx_diffuse_noMethod,cont_hue(i,:));
    gloss_diffuse_method(:,4:6,i) = arrangeParam(54,3,idx_diffuse_noMethod,gloss_hue(i,:));
end

for i = 1:3 % diffuse
    for j = 1:9 % hue
        scatter3(HK_diffuse_method(:,3+i,j),cont_diffuse_method(:,3+i,j),gloss_diffuse_method(:,3+i,j),'filled','MarkerFaceColor',graphColor(j,:));
        hold on;
    end
end
hold on;
[x1_grid,x2_grid] = meshgrid(linspace(min(x1),max(x1),gridNum),linspace(min(x2),max(x2),gridNum));
z = md_D_HK_cont.Coefficients.Estimate(1) + md_D_HK_cont.Coefficients.Estimate(2)*x1_grid + md_D_HK_cont.Coefficients.Estimate(3)*x2_grid;
mesh(x1_grid,x2_grid,z);
xlabel('H-K効果');
ylabel('色度コントラスト');
zlabel('光沢感')
title('D条件　光沢感');
set(gca, "FontName", "Noto Sans CJK JP");
hold off;


%% 光沢感増大効果を回帰で求める

% grayを含むか否か
flag = 1; % 0:含む、1:含まない
if flag == 0
    p = 9;
    q = 1;
else
    p = 8;
    q = 2;
    graphColor = [[1 0 0]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0 1 0]; 
            [0.4660 0.6740 0.1880]; [0.310 0.7450 0.9330]; [0 0.4470 0.7410]; [1 0 1]];
end

% 光沢感増大効果
cg_effect = gloss(q:9,:) - repmat(gloss(1,:),[p,1]);
cg_effect_SD = zscore(reshape(cg_effect(:,1:2:108),[p*54,1]));
cg_effect_D = zscore(reshape(cg_effect(:,2:2:108),[p*54,1]));

% 有彩色H-K効果
HK_SD_z_color = zscore(reshape(HKall(q:9,1:2:108),[p*54,1])); 
HK_D_z_color = zscore(reshape(HKall(q:9,2:2:108),[p*54,1])); 

% 有彩色色度コントラスト
contrast_SD_z_color = zscore(reshape(contrastAll(q:9,1:2:108),[p*54,1]));
contrast_D_z_color = zscore(reshape(contrastAll(q:9,2:2:108),[p*54,1]));

contrastLab_SD_z = zscore(reshape(contrastLab(:,1:2:108),[8*54,1]));
contrastLab_D_z = zscore(reshape(contrastLab(:,2:2:108),[8*54,1]));

%% SD条件において増大効果の回帰（H-K効果、色度コントラスト）
y = cg_effect_SD;
x1 = HK_SD_z_color;
x2 = contrast_SD_z_color;
X = [x1 x2];
md_cgEffect_SD_HK_cont = fitlm(X,y)

% プロット
figure;
% diffuseごとに整理
colorMarker = [[0 0.4470 0.7410];[0.8500 0.3250 0.0980];[0.9290 0.6940 0.1250]];
HK_hue = reshape(HK_SD_z_color,[p,54]);
cont_hue = reshape(contrast_SD_z_color,[p,54]);
cg_effect_hue = reshape(cg_effect_SD,[p,54]);
HK_diffuse_method = zeros(18,6,p);
cont_diffuse_method = zeros(18,6,p);
cg_effect_diffuse_method = zeros(18,6,p);
for i = 1:p % hue
    HK_diffuse_method(:,1:3,i) = arrangeParam(54,3,idx_diffuse_noMethod,HK_hue(i,:));
    cont_diffuse_method(:,1:3,i) = arrangeParam(54,3,idx_diffuse_noMethod,cont_hue(i,:));
    cg_effect_diffuse_method(:,1:3,i) = arrangeParam(54,3,idx_diffuse_noMethod,cg_effect_hue(i,:));
end

for i = 1:3 % diffuse
    for j = 1:p % hue
        scatter3(HK_diffuse_method(:,i,j),cont_diffuse_method(:,i,j),cg_effect_diffuse_method(:,i,j),'filled','MarkerFaceColor',graphColor(j,:));
        hold on;
    end
end
hold on;
[x1_grid,x2_grid] = meshgrid(linspace(min(x1),max(x1),gridNum),linspace(min(x2),max(x2),gridNum));
z = md_cgEffect_SD_HK_cont.Coefficients.Estimate(1) + md_cgEffect_SD_HK_cont.Coefficients.Estimate(2)*x1_grid + md_cgEffect_SD_HK_cont.Coefficients.Estimate(3)*x2_grid;
mesh(x1_grid,x2_grid,z);
xlabel('H-K効果');
ylabel('色度コントラスト');
zlabel('増大効果')
title('SD条件　増大効果');
set(gca, "FontName", "Noto Sans CJK JP");
hold off;

%% SD条件、色相以外の条件を平均して回帰
cg_effect_param_mean = zscore(mean(cg_effect(:,1:2:108),2));
HK_param_mean = zscore(mean(HKall(q:9,1:2:108),2));
cont_param_mean = zscore(mean(contrastAll(q:9,1:2:108),2));

y = cg_effect_param_mean;
x1 = HK_param_mean;
x2 = cont_param_mean;
X = [x1 x2];
md_cgEffect_SD_param_mean = fitlm(X,y)

% プロット
figure;
for i = 1:p % hue
    scatter3(HK_param_mean(i),cont_param_mean(i),cg_effect_param_mean(i),'filled','MarkerFaceColor',graphColor(i,:));
    hold on;
end
[x1_grid,x2_grid] = meshgrid(linspace(min(x1),max(x1),gridNum),linspace(min(x2),max(x2),gridNum));
z = md_cgEffect_SD_param_mean.Coefficients.Estimate(1) + md_cgEffect_SD_param_mean.Coefficients.Estimate(2)*x1_grid + md_cgEffect_SD_param_mean.Coefficients.Estimate(3)*x2_grid;
mesh(x1_grid,x2_grid,z);
xlabel('H-K効果');
ylabel('色度コントラスト');
zlabel('増大効果');
title('SD条件　増大効果　色相平均');
set(gca, "FontName", "Noto Sans CJK JP");
hold off;

%% SD条件、色相間で平均を取る
cg_effect_hue_mean = zscore(mean(cg_effect(:,1:2:108)));
HK_hue_mean = zscore(mean(HKall(q:9,1:2:108)));
cont_hue_mean = zscore(mean(contrastAll(q:9,1:2:108)));

y = cg_effect_hue_mean';
x1 = HK_hue_mean';
x2 = cont_hue_mean';
X = [x1 x2];
md_cgEffect_SD_hue_mean = fitlm(X,y)

%% D条件において増大効果の回帰（H-K効果、色度コントラスト）
y = cg_effect_D;
x1 = HK_D_z_color;
x2 = contrast_D_z_color;
X = [x1 x2];
md_cgEffect_D_HK_cont = fitlm(X,y)

% プロット
figure;
HK_hue = reshape(HK_D_z_color,[p,54]);
cont_hue = reshape(contrast_D_z_color,[p,54]);
cg_effect_hue = reshape(cg_effect_D,[p,54]);
for i = 1:p % hue
    HK_diffuse_method(:,4:6,i) = arrangeParam(54,3,idx_diffuse_noMethod,HK_hue(i,:));
    cont_diffuse_method(:,4:6,i) = arrangeParam(54,3,idx_diffuse_noMethod,cont_hue(i,:));
    cg_effect_diffuse_method(:,4:6,i) = arrangeParam(54,3,idx_diffuse_noMethod,cg_effect_hue(i,:));
end

for i = 1:3 % diffuse
    for j = 1:p % hue
        scatter3(HK_diffuse_method(:,3+i,j),cont_diffuse_method(:,3+i,j),cg_effect_diffuse_method(:,3+i,j),'filled','MarkerFaceColor',graphColor(j,:));
        hold on;
    end
end
hold on;
[x1_grid,x2_grid] = meshgrid(linspace(min(x1),max(x1),gridNum),linspace(min(x2),max(x2),gridNum));
z = md_cgEffect_D_HK_cont.Coefficients.Estimate(1) + md_cgEffect_D_HK_cont.Coefficients.Estimate(2)*x1_grid + md_cgEffect_D_HK_cont.Coefficients.Estimate(3)*x2_grid;
mesh(x1_grid,x2_grid,z);
xlabel('H-K効果');
ylabel('色度コントラスト');
zlabel('増大効果');
title('D条件　増大効果');
set(gca, "FontName", "Noto Sans CJK JP");
hold off;

%% D条件、色相以外の条件を平均して回帰
cg_effect_param_mean = zscore(mean(cg_effect(:,2:2:108),2));
HK_param_mean = zscore(mean(HKall(q:9,2:2:108),2));
cont_param_mean = zscore(mean(contrastAll(q:9,2:2:108),2));

y = cg_effect_param_mean;
x1 = HK_param_mean;
x2 = cont_param_mean;
X = [x1 x2];
md_cgEffect_D_param_mean = fitlm(X,y)

% プロットan 
figure;
for i = 1:p % hue
    scatter3(HK_param_mean(i),cont_param_mean(i),cg_effect_param_mean(i),'filled','MarkerFaceColor',graphColor(i,:));
    hold on;
end
[x1_grid,x2_grid] = meshgrid(linspace(min(x1),max(x1),gridNum),linspace(min(x2),max(x2),gridNum));
z = md_cgEffect_D_param_mean.Coefficients.Estimate(1) + md_cgEffect_D_param_mean.Coefficients.Estimate(2)*x1_grid + md_cgEffect_D_param_mean.Coefficients.Estimate(3)*x2_grid;
mesh(x1_grid,x2_grid,z);
xlabel('H-K効果');
ylabel('色度コントラスト');
zlabel('増大効果');
title('D条件　増大効果　色相平均');
set(gca, "FontName", "Noto Sans CJK JP");
hold off;

%% D条件、色相間で平均して回帰
cg_effect_hue_mean = zscore(mean(cg_effect(:,2:2:108)));
HK_hue_mean = zscore(mean(HKall(q:9,2:2:108)));
cont_hue_mean = zscore(mean(contrastAll(q:9,2:2:108)));

y = cg_effect_hue_mean';
x1 = HK_hue_mean';
x2 = cont_hue_mean';
X = [x1 x2];
md_cgEffect_D_hue_mean = fitlm(X,y)

%% Labコントラストで効果量を回帰

%% SD条件
y = cg_effect_SD;
x1 = HK_SD_z_color;
x2 = contrastLab_SD_z;
X = [x1 x2];
md_cgEffect_SD_HK_contLab = fitlm(X,y)

%% D条件
y = cg_effect_D;
x1 = HK_D_z_color;
x2 = contrastLab_D_z;
X = [x1 x2];
md_cgEffect_D_HK_contLab = fitlm(X,y)

%%
%{
%% 全刺激について光沢をH-Kと色度差で回帰
y = reshape(gloss, [9*108,1]);
x1 = reshape(HKallZscore, [9*108,1]);
x2 = reshape(contrastAllZscore, [9*108,1]);
%X = [ones(size(x1)) x1 x2];
%[b_HK_cont,~,~,~,stats_HK_cont] = regress(y,X)
X = [x1 x2];
md_HK_cont = fitlm(X,y)

% 全刺激について光沢をH-KとLabコントラストで回帰
%x2 = reshape(contrastLabZscore, [8*108,1]);
%X = [x1 x2];
%md_HK_LabCont = fitlm(X,y)

% D条件についてH-KとLabコントラストで回帰
%y = reshape(gloss(:,2:2:108), [9*54,1]);
%x1 = reshape(HKallZscore(:,2:2:108), [9*54,1]);
%x2 = reshape(contrastLabZscore(:,2:2:108), [9*54,1]);
%X = [x1 x2];
%md_D_HK_LabCont = fitlm(X,y)

%% SD条件におけるH-Kを用いた光沢予測モデルをD条件に適用
% 実際の測定値との差分を見る
glossEstimated = md_SD_HK.Coefficients.Estimate(1) + md_SD_HK.Coefficients.Estimate(2)*HKall(:,2:2:108);
glossEstimatedSD = md_SD_HK.Coefficients.Estimate(1) + md_SD_HK.Coefficients.Estimate(2)*HKall(:,1:2:108);
sa = gloss(:,2:2:108) - glossEstimated;

SSE = sum(sa.^2,'all');
SST = sum((gloss - mean(gloss,'all')).^2,'all');
R = 1 - (SSE/SST)

x = reshape(HKall(:,2:2:108), [9*54,1]);
y = reshape(sa,[9*54,1]);
figure;
scatter(x,y)

%% grayを除いた回帰
% 全刺激について光沢をH-KとLabコントラストで回帰
%y = reshape(gloss(2:9,:), [8*108,1]);
%x1 = reshape(HKallZscore(2:9,:), [8*108,1]);
%x2 = reshape(contrastLabZscore(2:9,:), [8*108,1]);
%X = [x1 x2];
%md_color_HK_LabCont = fitlm(X,y)

%{
%% Labコントラストで光沢効果量回帰
y = glossEffect';
x1 = zscore(mean(HK))';
x2 = zscore(mean(contrastLab))';
X = [ones(size(x1)) x1 x2];

[b_effect_Lab,~,~,~,stats_effect_Lab] = regress(y,X)

%% uvLコントラストで光沢効果量回帰
x2 = zscore(contrast)';
X = [ones(size(x1)) x1 x2];

[b_effect_uvL,~,~,~,stats_effect_uvL] = regress(y,X)

%% SD条件についてH-Kで光沢感回帰
glossColorSD = glossColor(:,1:2:108);
y = reshape(glossColorSD, [8*54,1]);
x1 = reshape(HK(:,1:2:108), [8*54,1]);
X = [ones(size(x1)) x1];

[b_SD,~,~,~,stats_SD] = regress(y,X)

%{
% 色相ごとに見る
color = ["0", "45", "90", "135", "180", "225", "270", "315"];
coef = zeros(8,2);
stat_hue = zeros(8,4);
for i = 1:8
    y = reshape(glossColorSD(i,:),[54,1]);
    x1 = reshape(HK(i,1:2:108), [54,1]);
    X = [ones(size(x1)), x1];
    [b,~,~,~,stats] = regress(y,X)
    coef(i,:) = b';
    stat_hue(i,:) = stats;
    
    figure;
    scatter(x1,y);
    title(color(i));
end
%}

%% SD条件についてH-Kで効果量回帰
y = zscore(glossEffect(1:2:108))';
x1 = zscore(mean(HK(:,1:2:108)))';
X = [ones(size(x1)) x1];

[b_effect_HK,~,~,~,stats_effect_HK] = regress(y,X)
%}
%}

%% パラメータごとに整理する関数
function v = arrangeParam(allParamN,paramNum,idx,value)
    v = zeros(allParamN/paramNum, paramNum);
    for i = 1:allParamN/paramNum
        for j = 1:paramNum
            v(i,j) = value(idx(i,j));
        end
    end
end