%% 実験結果からH-K効果量（輝度比）を計算する
clear all;

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
repeat = 5;
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
data.Properties.VariableNames{'Var3'} = 'color';
data.grayLumAve = mean(data.grayLum,2);
%data = splitvars(data, 'grayLum');
data.HK = data.grayLum ./ data.lum;
data.HKave = data.grayLumAve ./ data.lum;

% z-score化
HKzscore = zeros(9*8,1);
for i =1:9
    HKzscore(8*(i-1)+1:8*i) = zscore(data.HKave(8*(i-1)+1:8*i));
end
data = addvars(data,HKzscore);

save(strcat('../../analysis_result/',exp,'/',sn,'/data.mat'), 'data');


%% プロット
axisColorNum = [1 2 3 4 5 6 7 8];
f = figure;
for i = 1:3 % lum
    for j = 1:3 % sat
        subplot(3,3,3*(i-1)+j)
        hold on;
        
        n= 24*(i-1) + 8*(j-1);
        plot(axisColorNum,data.HKave(n+1:n+8)');
        
        % title
        title(strcat('lum:',num2str(i),'  sat:',num2str(j)));
        
        % axis
        xticks(axisColorNum);
        %xticklabels({'red', 'orange', 'yellow', 'green', 'blue-green', 'cyan', 'blue', 'magenta'});
        xticklabels({'0', '45', '90', '135', '180', '225', '270', '315'});
        xlabel('hue');
        xlim([0 9]);
        ylabel('H-K効果の大きさ');
        ylim([0 max(data.HKave)+0.3]);

        
        hold off;     
    end
end

%% 輝度・彩度での変化がわかるようにプロット
% dim1:lum, dim2:sat, dim3:color
dataHK = zeros(3,3,8);
for i = 1:8
    dataHK(:,:,i) = reshape(data.HKave(data.color==colorName(i)), [3,3])';
end

% グラフの色
graphColor = [[1 0 0]; [0.9290,0.6940,0.1250]; [0.75 0.75 0]; [0 1 0]; [0.04470, 0.4470,0.7410]; [0 1 1]; [0 0 1]; [1 0 1]];
% 彩度変化プロット
f= figure;
for i = 1:3
    subplot(1,3,i);
    hold on;
    for j = 1:8
        scatter(patchSaturation,dataHK(i,:,j),[],graphColor(j,:),'filled');
    end
    xlabel('saturation');
    ylabel('H-K効果量');
    title(strcat('lum : ',int2str(i)));
    hold off;
end
sgtitle('彩度変化によるH-K効果の変化');

% 輝度変化のプロット
f= figure;
for i = 1:3
    subplot(1,3,i);
    hold on;
    for j = 1:8
        scatter(patchLuminance,dataHK(:,i,j)',[],graphColor(j,:),'filled');
    end
    xlabel('luminance');
    ylabel('H-K効果量');
    title(strcat('sat : ',int2str(i)));
    hold off;
end
sgtitle('輝度変化によるH-K効果の変化');
        

%% 輝度で平均化
HK_meanLum = reshape(mean(dataHK), [3,8]);
f = figure;
for i = 1:3
    subplot(3,1,i);
    
    plot(axisColorNum,HK_meanLum(i,:));
    
    title(strcat('saturation : ',num2str(i)));
    
    xticks(axisColorNum);
    xticklabels({'0', '45', '90', '135', '180', '225', '270', '315'});
    xlabel('hue');
    xlim([0 9]);
    ylabel('H-K効果の大きさ');
    ylim([1 max(data.HKave)+0.3]);
end
sgtitle('輝度で平均化したH-K効果');
    

%% RGBからXYZに変換する関数
function XYZ = conv_RGB2XYZ(RGB,ccmat)

    LUT = load('../../mat/gamma_lut.lut');
    rgb = TNT_RGBTorgb_LUT(RGB*257, LUT);
    
    XYZ = TNT_rgb2XYZ(rgb',ccmat);
    XYZ = XYZ';
    
end
    
    