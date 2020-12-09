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
wp_upvpl = applycform(wp_XYZ,cx2u);

%% ハイライト領域
load('../../mat/highlight/highlightMap.mat');

%% Main
colorContrast = zeros(8,108); % 色度座標間のユークリッド距離
contrast = zeros(8,108); % 輝度込み
progress = 1;
for i = 1:3 % shape
    load(strcat('../../mat/',shape(i),'Mask/mask.mat'));
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                % ハイライトとそれ以外の領域のマスクマップ
                HL_mask = highlightMap(:,:,i,j,3);
                HLno_mask = mask - highlightMap(:,:,i,j,3);
                
                %% データ読み込み
                load(strcat('../../mat_analysis/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredSD.mat'));
                load(strcat('../../mat_analysis/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredD.mat'));
                [iy,ix,iz] = size(coloredSD(:,:,:,1));
                
                for n = 2:9 % color
                    %% 色空間変換  XYZ -> L*a*b*
                    lab = zeros(iy,ix,iz,2);
                    lab(:,:,:,1) = xyz2lab(coloredSD(:,:,:,n),'WhitePoint', wp_XYZ);
                    lab(:,:,:,2) = xyz2lab(coloredD(:,:,:,n),'WhitePoint', wp_XYZ);
                    
                    %% 色度コントラストを求める
                    % ハイライトとそれ以外の領域のそれぞれで平均色度座標を算出
                    % それらのユークリッド距離を求める
                    for m = 1:2 % method
                        count = 36*(i-1) + 18*(j-1) + 6*(k-1) + 2*(l-1) + m;
                        labHL = lab(:,:,:,m) .* HL_mask;
                        labHLno = lab(:,:,:,m) .* HLno_mask;
                        
                        labHL_list = zeros(nnz(labHL)/3,3);
                        labHLno_list = zeros(nnz(labHLno)/3,3);
                        for p =1:3
                            HL_temp = labHL(:,:,p);
                            HL_temp(HL_temp==0) = [];
                            HLno_temp = labHLno(:,:,p);
                            HLno_temp(HLno_temp==0) = [];
                            
                            labHL_list(:,p) = HL_temp;
                            labHLno_list(:,p) = HLno_temp;
                        end
                        
                        % 平均色度座標
                        labHL_mean = mean(labHL_list);
                        labHLno_mean = mean(labHLno_list);
                        
                        % 色度コントラスト
                        vec = labHL_mean - labHLno_mean;
                        colorContrast(n-1,count) = norm(vec(2:3));
                        contrast(n-1,count) = norm(vec);
                    end
                end
                
                %% 進行度表示
                fprintf('finish : %d/54\n\n', progress);
                progress = progress + 1;
                
            end
        end
    end
end
                                    
                                    
                    
                    