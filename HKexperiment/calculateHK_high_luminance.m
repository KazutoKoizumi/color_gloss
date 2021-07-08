%% 実験結果からH-K効果量（輝度比）を計算する（ハイライトの平均輝度）
%clear all;

exp = 'experiment_HK';
sn = 'high_lum_koizumi';

colorName = ["red","orange","yellow","green","blue-green","cyan","blue","magenta"];
lumNum = 1;
satNum = 3;
colorNum = 8;
stiNum = lumNum * satNum * colorNum;

mkdir(strcat('../../analysis_result/',exp,'/',sn));
load(strcat('../../data/',exp,'/',sn,'/table_',sn));
load('../../mat/ccmat');

%% テーブル変数用の輝度・彩度データ
%load('../../mat/patch/patchLuminance.mat');
patchLuminance = 20;
load('../../mat/patch/patchSaturation.mat');
lum = zeros(stiNum,1);
sat = zeros(stiNum,1);
count = 0;
for i = 1:lumNum
    for j = 1:satNum
        for k = 1:colorNum
            count = count + 1;
            lum(count) = patchLuminance(dataTable.luminance(count));
            sat(count) = patchSaturation(dataTable.saturation(count));
        end
    end
end

%% 実験結果（RGB値）をXYZに変換
repeat = 3;
grayLum = zeros(stiNum,repeat);
count = 0;
for i = 1:lumNum
    for j = 1:satNum
        for k = 1:colorNum
            count = count + 1;
            for l = 1:repeat
                RGB = ones(1,3) * cast(table2array(dataTable(count,3+l)),'double');
                XYZ = conv_RGB2XYZ(RGB,ccmat);
                grayLum(count,l) = XYZ(2);
            end
        end
    end
end

%% 結果
data = table(lum,sat,table2array(dataTable(:,3)),grayLum);
data.Properties.VariableNames{'Var3'} = 'color';
data.grayLumAve = mean(data.grayLum,2);
%data = splitvars(data, 'grayLum');
data.HK = data.grayLum ./ data.lum;
data.HKave = data.grayLumAve ./ data.lum;

% z-score化
HKzscore = zeros(lumNum*satNum*8,1);
for i =1:lumNum*satNum
    HKzscore(8*(i-1)+1:8*i) = zscore(data.HKave(8*(i-1)+1:8*i));
end
data = addvars(data,HKzscore);

save(strcat('../../analysis_result/',exp,'/',sn,'/data.mat'), 'data');

%% 前の結果と比較
load(strcat('../../analysis_result/',exp,'/all/HKtable.mat'));
load('../../mat/HKeffect/cf.mat','cf');
load('../../mat/HKeffect/Rsq.mat','Rsq');


%% RGBからXYZに変換する関数
function XYZ = conv_RGB2XYZ(RGB,ccmat)

    LUT = load('../../mat/gamma_lut.lut');
    rgb = TNT_RGBTorgb_LUT(RGB*257, LUT);
    
    XYZ = TNT_rgb2XYZ(rgb',ccmat);
    XYZ = XYZ';
    
end
    