%% Lab色空間で彩度を求めて、ハイライトとそれ以外の領域の色度コントラストを定義する

clear all;

%% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["alpha005", "alpha01", "alpha02"]; %l
method = ["SD", "D"];

%% 基準白色点
load('../../mat/ccmat');
cx2u = makecform('xyz2upvpl');
wp_rgb = [1 1 1];
wp_XYZ = TNT_rgb2XYZ(wp_rgb',ccmat)';
wp_XYZ = wp_XYZ * (1/wp_XYZ(2));
wp_upvpl = applycform(XYZ,cx2u);

%% ハイライト領域とそれ以外のマスクマップ
load('../../mat/highlight/highlightMap.mat');

%% Main
for i = 1:1 % shape
    load(strcat('../../mat/',shape(i),'Mask/mask.mat'));
    for j = 1:1 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                %% データ読み込み
                load(strcat('../../mat_analysis/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredSD.mat'));
                load(strcat('../../mat_analysis/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredD.mat'));
                [iy,ix,iz] = size(coloredSD(:,:,:,1));
                
                for n = 2:9 % color
                    %% 色空間変換  XYZ -> L*a*b*
                    lab = zeros(iy,ix,iz,2);
                    lab(:,:,:,1) = xyz2lab(coleredSD(:,:,:,n),'WhitePoint', wp_XYZ);
                    lab(:,:,:,2) = xyz2lab(coleredD(:,:,:,n),'WhitePoint', wp_XYZ);
                    
                    %% 色度コントラストを求める
                    % ハイライトとそれ以外の領域のそれぞれで平均色度座標を算出
                    % それらのユークリッド距離を求める
                    labHighlight = zeros(3,nnz(highlightMap(:,:,i,j,3)));
                    labNoHighlight = zeros(3,nnz(mask-highlightMap(:,:,i,j,3)));
                    for m = 1:2 % method
                        count = [0 0 0]; % [all, highlight, nohighlight]
                        for p = 1:iy
                            for q =1:ix
                                if mask(p,q)==1
                                    count(1) = count(1) + 1;
                                    
                                    
                    
                    