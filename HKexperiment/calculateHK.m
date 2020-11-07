%% 実験結果からH-K効果量（輝度比）を計算する

exp = 'experiment_HK';
sn = 'pre_koizumi';

colorName = ["red","orange","yellow","green","blue-green","cyan","blue","magenta"];
lumNum = 3;
satNum = 3;
colorNum = 8;
stiNum = lumNum * satNum * colorNum;

mkdir(strcat('../../analysis_result/',exp,'/',sn));
load(strcat('../../data/',exp,'/',sn,'/table_',sn));
load('../../mat/ccmat');


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

%% 実験結果（RGB値）をXYZに変換
repeat = 1;
grayLum = zeros(stiNum,repeat);
count = 0;
for i = 1:3
    for j = 1:3
        for k = 1:8
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
data.HK = data.grayLum ./ data.lum;

%% プロット
axisColorNum = [1 2 3 4 5 6 7 8];
f = figure;
for i = 1:3 % lum
    for j = 1:3 % sat
        subplot(3,3,3*(i-1)+j)
        hold on;
        
        n= 24*(i-1) + 8*(j-1);
        plot(axisColorNum,data.HK(n+1:n+8)');
        
        % title
        title(strcat('lum:',num2str(i),'  sat:',num2str(j)));
        
        % axis
        xticks(axisColorNum);
        xticklabels({'red', 'orange', 'yellow', 'green', 'blue-green', 'cyan', 'blue', 'magenta'});
        xlabel('色相');
        xlim([0 9]);
        ylabel('H-K効果の大きさ');
        ylim([1 4]);

        
        hold off;     
    end
end

%% RGBからXYZに変換する関数
function XYZ = conv_RGB2XYZ(RGB,ccmat)

    LUT = load('../../mat/gamma_lut.lut');
    rgb = TNT_RGBTorgb_LUT(RGB*257, LUT);
    
    XYZ = TNT_rgb2XYZ(rgb',ccmat);
    XYZ = XYZ';
    
end
    
    