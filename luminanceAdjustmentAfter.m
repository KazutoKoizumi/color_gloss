%% 彩色後にエリアライトを使用した画像とenvmapを使用した画像の背景部分の平均輝度を揃える
% エリアライトを使用した画像とenvmapを使用した画像の背景部分の平均輝度を比較
% これが一致するようにエリアライトの画像全体の輝度を定数倍する
% load:coloredSD,coloredD  save:coloredSD,coloredD

%% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["rough005", "rough01", "rough02"]; %l

load('../mat/upvplWhitePoints.mat');
monitorMinLum = min(upvplWhitePoints(:,3));
allObj = 3*3*3*2;
progress = 0;

%% Main
for i = 1:3 % shape
    load(strcat('../mat/',shape(i),'Mask/mask.mat'));
    for k = 1:3 % diffuse
        for l = 1:3 % roughness
            for m = 1:2 % method
                %% データ読み込み
                if m == 1
                    load(strcat('../mat/',shape(i),'/',light(1),'/',diffuse(k),'/',roughness(l),'/coloredSD.mat'));
                    xyzArea = coloredSD;
                    load(strcat('../mat/',shape(i),'/',light(2),'/',diffuse(k),'/',roughness(l),'/coloredSD.mat'));
                    xyzEnv = coloredSD;
                    clear coloredSD;
                elseif m == 2
                    load(strcat('../mat/',shape(i),'/',light(1),'/',diffuse(k),'/',roughness(l),'/coloredD.mat'));
                    xyzArea = coloredD;
                    load(strcat('../mat/',shape(i),'/',light(2),'/',diffuse(k),'/',roughness(l),'/coloredD.mat'));
                    xyzEnv = coloredD;
                    clear coloredD;
                end
                [iy,ix,iz] = size(xyzArea(:,:,:,1));
                
                %% エリアライト、envmapそれぞれの背景部分の平均輝度を求める
                lumMap = zeros(iy,ix,2); %1:area, 2:envmap
                lumMap(:,:,1) = xyzArea(:,:,2,1);
                lumMap(:,:,2) = xyzEnv(:,:,2,1);
                
                backMask = ~mask;
                lumMap = lumMap .* backMask;
                
                pixelNum = nnz(backMask);
                
                lumSum = sum(lumMap, [1 2]);
                meanLum = lumSum / pixelNum;
                meanLum = reshape(meanLum, [1,2]); % 平均輝度
                
                %% それぞれの平均輝度からエリアライトにかける定数を求める
                proportion = meanLum(2) / meanLum(1);
                
                %% エリアライトの輝度調整
                proportionMap = ones(iy,ix)*proportion;
                
                xyzArea = xyzArea .* proportionMap;
                xyzEnv = xyzEnv .* proportionMap;
                
                minArea = min(xyzArea(:,:,2,:),[],'all');
                minEnv = min(xyzEnv(:,:,2,:),[],'all');
                
                %% データ保存
                if m == 1
                    coloredSD = xyzArea;
                    save(strcat('../mat/',shape(1),'/',light(1),'/',diffuse(k),'/',roughness(l),'/coloredSD'),'coloredSD');
                    coloredSD = xyzEnv;
                    save(strcat('../mat/',shape(2),'/',light(1),'/',diffuse(k),'/',roughness(l),'/coloredSD'),'coloredSD');
                    clear coloredSD;
                elseif m == 2
                    coloredD = xyzArea;
                    save(strcat('../mat/',shape(1),'/',light(1),'/',diffuse(k),'/',roughness(l),'/coloredD'),'coloredD');
                    coloredD = xyzEnv;
                    save(strcat('../mat/',shape(2),'/',light(1),'/',diffuse(k),'/',roughness(l),'/coloredD'),'coloredD');
                    clear coloredD;
                end
                
                %% 進行度表示
                progress = progress + 1;
                fprintf('finish : %d/%d\n\n', progress, allObj);
            end
        end
    end
end

                
                