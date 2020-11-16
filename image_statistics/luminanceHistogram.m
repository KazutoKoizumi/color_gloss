%% 輝度ヒストグラムを求める
clear all;

%% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["alpha005", "alpha01", "alpha02"]; %l
method = ["SD", "D"];

Dname = ["0.1", "0.3", "0.5"];
roughName = ["0.05", "0.1", "0.2"];
x = [1 2];

allObj = 3*2*3*3;
progress = 0;

%% Main
for i = 1:3 % shape
    load(strcat('../../mat/',shape(i),'Mask/mask.mat'));
    for j = 1:2 % light
        f = figure;
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                %% 輝度読み込み
                % データ読み込み
                load(strcat('../../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredSD.mat'));
                [iy,ix,iz] = size(coloredSD(:,:,:,1));
                
                load(strcat('../../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/xyzD.mat'));
                %lumMap = xyzD(:,:,2);

                lumMap = coloredSD(:,:,2,1);

                % オブジェクト部分のみ
                lumMap = lumMap .* mask;
                lumMap(lumMap==0) = [];

                % 背景部分
                %backMask = ~mask;
                %lumMap = lumMap .* backMask;
                %lumMap(lumMap==0) = [];

                % 画像全体
                % そのまま

                %% plot
                subplot(3,3,3*(k-1)+l);
                hold on;

                h = histogram(lumMap);
                
                %xlim([0 45]);
                title(strcat('diffuse:',Dname(k),'  roughness:',roughName(l)));

                hold off;
                
                max(lumMap)

                % 進行度表示
                progress = progress + 1;
                fprintf('finish : %d/%d\n\n', progress, allObj);
            end
        end
        sgtitle(strcat('shape:',shape(i),'  light:',light(j)));
    end
end
