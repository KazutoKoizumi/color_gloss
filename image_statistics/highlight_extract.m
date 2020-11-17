%% 輝度閾値を設定してハイライト部分を取り出す
clear all;

%% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["alpha005", "alpha01", "alpha02"]; %l
method = ["SD", "D"];
diffuseN = size(diffuse,2);
roughN = size(roughness,2);
methodN = size(method,2);

allObj = 3*2*3*3*2;
load('../../mat/ccmat.mat');
load('../../mat/highlight/lumThreshold.mat');


%% 輝度閾値
% 


%% ハイライト抽出
count = 37;
for i = 3:3 % shape
    load(strcat('../../mat/',shape(i),'Mask/mask.mat'));
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                load(strcat('../../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredD.mat'));
                
                lumMap = coloredD(:,:,2,1);
                lumMap = lumMap .* mask;

                lumMap(lumMap < lumThreshold(count)) = 0;
                lumMap = cast(lumMap,'uint8');

                imageRGB = imageXYZ2RGB(coloredD(:,:,:,2),ccmat);
                highlight_RGB = imageRGB .* lumMap;

                figure;
                image(imageRGB);
                title(strcat('shape:',num2str(i),'  light:',num2str(j),'  diffuse:',num2str(k),'  roughness:',num2str(l)));
                figure;
                image(highlight_RGB);
                title(strcat('shape:',num2str(i),'  light:',num2str(j),'  diffuse:',num2str(k),'  roughness:',num2str(l)));
                
                count = count + 1;
                
            end
        end
    end
end
