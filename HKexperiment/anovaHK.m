%% HK効果量のanova

sn = 'all';
sn_list = ["koizumi", "nohira", "totsuka", "taniguchi", "kosone", "saeki"]; 

load(strcat('../../analysis_result/experiment_HK/all/HKtable.mat'));

%% anova 全被験者データ
luminance = repmat(HKtable.lum', [1 30]);
saturation = repmat(HKtable.sat', [1 30]);
color = repmat(HKtable.color', [1 30]);
HK = zeros(1,72*30);
for i = 1:6
    HK_individual = reshape(HKtable.(3+i), [1 72*5]);
    HK(72*5*(i-1)+1:72*5*i) = HK_individual;
end

[p, tbl] = anovan(HK,{luminance,saturation,color}, 'model','full', 'varnames',{'luminance','saturation','hue'});

%% 各被験者データ
p_individual = zeros(7,6);
for i = 1:6
    n = 72*5*(i-1)+1;
    m = 72*5*i;
    p(:,i) = anovan(HK(n:m),{luminance(n:m),saturation(n:m),color(n:m)}, 'model','full','varnames',{'luminance','saturation','hue'});
end
