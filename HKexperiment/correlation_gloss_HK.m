%% 光沢感の選好尺度値とH-K効果との相関係数を求める
clear all;

sn1 = 'all'; % 実験1被験者名
sn2 = 'all'; % 実験2被験者名

colorName = ["red","orange","yellow","green","blue-green","cyan","blue","magenta"];

load(strcat('../../analysis_result/experiment_gloss/',sn1,'/sv.mat'));
if strcmp(sn2,'all') == 1
    load(strcat('../../analysis_result/experiment_HK/',sn2,'/HKtable.mat'));
    flag = 0;
else
    load(strcat('../../analysis_result/experiment_HK/',sn2,'/data.mat'));
    flag = 1;
end
    
load('../../mat/patch/patchLuminance.mat');
load('../../mat/patch/patchSaturation.mat');

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

idx_method_diffuse = zeros(18,6);
for i = 1:2
    for j = 1:3
        idx_method_diffuse(:,3*(i-1)+j) = find(idx_gloss(:,5)==i & idx_gloss(:,3)==j);
    end
end

sValue = zeros(9, paramnum);
for i = 1:paramnum
    sValue(:,i) = sv(:,:,idx_gloss(i,1),idx_gloss(i,2),idx_gloss(i,3),idx_gloss(i,4),idx_gloss(i,5))';
end


%% 相関係数
R = zeros(108,9);
R_zscore = zeros(108,9);
for i = 1:108
    gloss = sValue(2:9,i)';
    for j = 1:9
        if flag == 0
            HK = HKtable.HKmean(8*(j-1)+1:8*j)';
            HKzscore = HKtable.HKzscore(8*(j-1)+1:8*j)';
        else
            HK = data.HKave(8*(j-1)+1:8*j)';
            HKzscore = data.HKzscore(8*(j-1)+1:8*j)';
        end
        r = corrcoef(gloss, HK);
        R(i,j) = r(1,2);
        
        r_z = corrcoef(gloss, HKzscore);
        R_zscore(i,j) = r_z(1,2); 
        
    end
end

% 相関係数のヒートマップ
figure;
heatmap(R', 'ColorLimits',[-1 1]);
colormap('jet');
xlabel('光沢感パラメータ');
ylabel('H-K効果パラメータ');

% 実験1の各刺激条件ごとの平均値
R_sti_mean = mean(R,2);
figure;
heatmap(R_sti_mean');
colormap('jet');
xlabel('光沢感パラメータ');
ylabel('H-K効果パラメータ');

%{
%% 一部のパラメータに限定した相関係数(z-score化したものを使用)
% SDと彩度0.0460のH-K
% D,diffuse0.1と彩度0.0316のH-K
% D,diffuse0.3と彩度0.0388のH-K
% D,diffuse0.5と彩度0.0388のH-K

% H-K効果を輝度で平均化
dataHK = zeros(3,3,8);
for i = 1:8
    if flag == 0
        dataHK(:,:,i) = reshape(HKtable.HKzscore(HKtable.color==colorName(i)), [3,3])';
    else
        dataHK(:,:,i) = reshape(data.HKzscore(data.color==colorName(i)), [3,3])';
    end
end
HK_meanLum = reshape(mean(dataHK), [3,8]);

% 相関係数
R_param = zeros(108,1);
for i = 1:108
    gloss = sValue(2:9,i)';
    if idx_gloss(i,5) == 1 % SD
        HK = HK_meanLum(3,:);
    else
        if idx_gloss(i,3) == 1 % D, diffuse=0.1
            HK = HK_meanLum(1,:);
        else
            HK = HK_meanLum(2,:);
        end
    end
    
    r = corrcoef(gloss,HK);
    R_param(i) = r(1,2);
end

% 相関係数のヒートマップ
figure;
heatmap(R_param');
colormap('jet');

R_SD_D_mean = mean(reshape(R_param,[2,54]),2);
%}

% SD,D,diffuseパラメータでわける
R_method_diffuse = R_sti_mean(idx_method_diffuse);
% プロット, diffuse,method以外のパラメータが同じ刺激を結ぶ
figure;
x_mean = 1:6;
y_mean = mean(R_method_diffuse);
%{
x = reshape(repmat([1,2,3,4,5,6], [18,1]),[1,6*18]);
y = reshape(R_method_diffuse, [1,108]);
scatter(x,y);
hold on;
scatter(x_mean,y_mean,72,[1 0 0],'filled');
%}
for i = 1:18
    for m = 1:2
        plot(x_mean(3*(m-1)+1:3*m),R_method_diffuse(i,3*(m-1)+1:3*m),'--o','Color',[0 0.4470 0.7410]);
        hold on;
    end
end
plot(x_mean(1:3),y_mean(1,1:3),'-o','Color',[1,0,0]);
plot(x_mean(4:6),y_mean(1,4:6),'-o','Color',[1,0,0])
    scatter(x_mean,y_mean,72,[1 0 0],'filled');
    
xlim([0 7]);
xticks(x_mean);
xticklabels({'0.1', '0.3', '0.5', '0.1', '0.3', '0.5'});
xlabel('diffuse');
ylabel('相関係数');
%title('diffuseと彩色方法ごとの相関係数');
xline(3.5, '--');
ylim([min(R_sti_mean)-0.1, 1.3]);
text(1.75,1.2,'SD');
text(5.25,1.2,'D');
hold off;

%% 相関係数の分散分析（diffuse,methodの主効果を見る）
shape = [repmat("bunny",[1 36]),repmat("dragon",[1 36]),repmat("blob",[1 36])];
light = repmat([repmat("area",[1 18]),repmat("envmap",[1 18])],[1 3]);
diffuse = repmat([ones(1,6)*0.1,ones(1,6)*0.3,ones(1,6)*0.5],[1 6]);
roughness = repmat([ones(1,2)*0.05,ones(1,2)*0.1,ones(1,2)*0.2],[1 18]);
method = repmat(["SD","D"],[1,54]);
%p = anovan(R,{shape,light,diffuse,roughness,method}, 'model','full', 'varnames',{'shape','light','diffuse','roughness','method'});
p = anovan(R_sti_mean,{shape,light,diffuse,roughness,method}, 'model','interaction', 'varnames',{'shape','light','diffuse','roughness','method'});

