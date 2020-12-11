%% 刺激画像の色について、各ピクセルの彩度、輝度を求める（その後散布図としてプロット->stimuliSatLumPlot.m）
%clear all;

%% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["alpha005", "alpha01", "alpha02"]; %l
colorizeM = ["SD", "D"];

allObj = 3*2*3*3*2;
progress = 0;

load('../../mat/upvplWhitePoints.mat');
load('../../mat/saturationMax.mat');
[~,iMax] = max(saturationMax);

%% Main
for i = 1:3 % shape
    load(strcat('../../mat/',shape(i),'Mask/mask.mat'));
    sat_lum = zeros(nnz(mask),2,2,3,3,2);
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                %% データ読み込み
                load(strcat('../../mat_analysis/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredSD.mat'));
                load(strcat('../../mat_analysis/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredD.mat'));
                [iy,ix,iz] = size(coloredSD(:,:,:,1));
                
                %% 色空間変換
                upvpl = zeros(iy,ix,iz,2); % 1:SD, 2:D
                cx2u = makecform('xyz2upvpl');
                upvpl(:,:,:,1) = applycform(coloredSD(:,:,:,2),cx2u);
                upvpl(:,:,:,2) = applycform(coloredD(:,:,:,2),cx2u);
                
                %% 彩度、輝度を記録
                for m = 1:2 % colorize method
                    count = 0;
                    for p = 1:iy
                        for q = 1:ix
                            if mask(p,q) == 1
                                count = count + 1;
                                
                                
                                % 輝度チェック
                                if upvpl(p,q,3,m) <= upvplWhitePoints(iMax,3)
                                    idx = find(upvplWhitePoints(:,3)<upvpl(p,q,3,m), 1, 'last');
                                    if isempty(idx) == 1
                                        idx = 1;
                                    end
                                else
                                    idx = find(upvplWhitePoints(:,3)>upvpl(p,q,3,m), 1);
                                    if isempty(idx) == 1
                                        idx = find(upvplWhitePoints(:,3),1,'last');
                                    end
                                end
                                
                                % 白色点からの変位
                                displacement = zeros(1,2);
                                displacement(1) = upvpl(p,q,1,m) - upvplWhitePoints(idx,1);
                                displacement(2) = upvpl(p,q,2,m) - upvplWhitePoints(idx,2);
                                %}
                                
                                % 彩度
                                sat_lum(count,1,j,k,l,m) = sqrt(sum(displacement.^2));
                                %sat_lum(count,1,j,k,l,m) = upvpl(p,q,1,m);
                                % 輝度
                                sat_lum(count,2,j,k,l,m) = upvpl(p,q,3,m);  
                            end
                        end
                    end
                    
                    %{
                    %% プロット
                    figure;
                    scatter(sat_lum(:,1,j,k,l,m), sat_lum(:,2,j,k,l,m));
                    %}
                    
                    % D条件での相関係数
                    
                    %% 進行度表示
                    progress = progress + 1;
                    fprintf('finish : %d/%d\n\n', progress, allObj);
                end
                
                if i == 2
                    a = 1;
                end
            end
        end
    end
    
    %% 形状ごとに記録
    if i == 1
        bunnySatLum = sat_lum;
    elseif i == 2
        dragonSatLum = sat_lum;
    elseif i == 3
        blobSatLum = sat_lum;
    end
    
end

%% 保存
save('../../mat/colorSatLum/bunnySatLum.mat', 'bunnySatLum');
save('../../mat/colorSatLum/dragonSatLum.mat', 'dragonSatLum');
save('../../mat/colorSatLum/blobSatLum.mat', 'blobSatLum');
    
    
                                
