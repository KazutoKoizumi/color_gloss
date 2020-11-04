%% 実験結果からH-K効果量（輝度比）を計算する

exp = 'experiment_HK';
sn = 'sample';

colorName = ["red","orange","yellow","green","blue-green","cyan","blue","magenta"];
lumNum = 3;
satNum = 3;
colorNum = 8;
stiNum = lumNum * satNum * colorNum;

mkdir(strcat('../../analysis_result/',exp,'/',sn));
load(strcat('../../data/',exp,'/',sn,'/table_',sn));


%% テーブル変数用の輝度・彩度データ
load('../../mat/patch/patchLuminance.mat');
load('../../mat/patch/patchSaturation.mat');
lum = zeros(stiNum,1);
sat = zeros(stiNum,1);
count = 0;
for i = 1:3
    for j = 1:3
        for k = 1:8
            count = count + 1;
            lum(count) = patchLuminance(dataTable.luminance(count));
            sat(count) = patchSaturation(dataTable.saturation(count));
        end
    end
end

%% 実験結果（RGB値）を輝度（Y）に変換
repeat = 1;
grayLum = zeros(stiNum,repeat)
for i = 1:3
    for j = 1:3
        for k = 1:8
            for l = 1:repeat
                RGB = (ones(3,1) * cast(table2array(dataTable(count,3+l)))/255,'double');
                
            end
        end
    end
end
            
%% 
function xyz = conv_RGB2XYZ(RGB,ccmat)

LUT = load('../../mat/gamma_lut');