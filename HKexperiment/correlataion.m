%% 光沢感と回帰したH-K効果との相関係数を求める
%clear all;

sn1 = 'all'; % 実験1被験者名
sn2 = 'all'; % 実験2被験者名
sn = ["koizumi", "nohira", "totsuka", "taniguchi", "kosone", "saeki"]; 

colorName = ["red","orange","yellow","green","blue-green","cyan","blue","magenta"];

load(strcat('../../analysis_result/experiment_gloss/',sn1,'/sv.mat'));
load('../../analysis_result/experiment_HK/all/HKtable.mat');

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
% 各刺激のハイライト領域のH-K効果との相関係数を見る
load('../../mat/HKeffect/HKstimuli.mat');
%R = zeros(108,9); 
R = zeros(1,108);
for i = 1:108 % 実験1パラメータ
    gloss = sValue(2:9,i)';
    %{
    for j = 1:9 % 実験2パラメータ
        HK = HKtable.HKzscore(8*(j-1)+1:8*j)';
        r = corrcoef(gloss, HK);
        R(i,j) = r(1,2);
    end
    %}
    HK = HKstimuli(:,i,1)';
    r = corrcoef(gloss, HK);
    R(i) = r(1,2);
end

% 相関係数のヒートマップ
figure;
heatmap(R, 'ColorLimits',[-1 1]);
colormap('jet');
xlabel('光沢感パラメータ');

%% 相関係数整理
% SD,D,diffuseパラメータでわける
R_method_diffuse = R(idx_method_diffuse);
% プロット
figure;
x_mean = [1,2,3,4,5,6];
y_mean = mean(R_method_diffuse);
%{
x = reshape(repmat([1,2,3,4,5,6], [18,1]),[1,6*18]);
y = reshape(R_method_diffuse, [1,108]);
scatter(x,y);
hold on;
%}
% diffuse,method以外のパラメータが同じ刺激を結ぶ
for i = 1:18
    for m = 1:2
        plot(x_mean(3*(m-1)+1:3*m),R_method_diffuse(i,3*(m-1)+1:3*m),'--o','Color',[0 0.4470 0.7410]);
        hold on;
    end
end
plot(x_mean(1:3),y_mean(1,1:3),'-o','Color',[1,0,0]);
plot(x_mean(4:6),y_mean(1,4:6),'-o','Color',[1,0,0]);
scatter(x_mean,y_mean,72,[1 0 0],'filled');

% グラフの設定
xlim([0 7]);
xticks(x_mean);
xticklabels({'0.1', '0.3', '0.5', '0.1', '0.3', '0.5'});
xlabel('diffuse');
ylabel('相関係数');
%title('diffuseと彩色方法ごとの相関係数');
xline(3.5, '--');
ylim([-1 1.3]);
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
p = anovan(R,{shape,light,diffuse,roughness,method}, 'model','interaction', 'varnames',{'shape','light','diffuse','roughness','method'});

shapeD = shape(1:2:108);
lightD = light(1:2:108);
diffuseD = diffuse(1:2:108);
roughD = roughness(1:2:108);
R_D = R(1:2:108);
p_D = anovan(R_D,{shapeD,lightD,diffuseD,roughD}, 'model','interaction', 'varnames',{'shape','light','diffuse','roughness'});
