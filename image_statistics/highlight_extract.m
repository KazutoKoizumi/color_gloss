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
load(strcat('../../mat/',shape(1),'Mask/mask.mat'));

load(strcat('../../mat/',shape(1),'/',light(1),'/',diffuse(1),'/',roughness(3),'/coloredSD.mat'));

%% 輝度閾値
% 
threshold = 9;

%% 輝度抽出
lumMap = coloredSD(:,:,2,1);
lumMap = lumMap .* mask;

lumMap(lumMap < threshold) = 0;
lumMap = cast(lumMap,'uint8');

imageRGB = imageXYZ2RGB(coloredSD(:,:,:,2),ccmat);
highlight_RGB = imageRGB .* lumMap;

figure;
image(imageRGB);
figure;
image(highlight_RGB);
