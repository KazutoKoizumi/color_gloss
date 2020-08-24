%% レンダリング結果の輝度調整（トーンマップ含む）
% エリアライトを使用した画像とenvmapを使用した画像の背景部分の平均輝度を比較
% これが一致するようにエリアライトの画像全体の輝度を定数倍する
% load:coloredSD,coloredD  save:coloredSD,coloredD

%% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["alpha005", "alpha01", "alpha02"]; %l

load('../mat/upvplWhitePoints.mat');
monitorMinLum = min(upvplWhitePoints(:,3));
lum = 3.5;
allObj = 3*3*3;
progress = 0;

%% Main
for i = 1:3 % shape
    load(strcat('../mat/',shape(i),'Mask/mask.mat'));
    for k = 1:3 % diffuse
        for l = 1:3 % roughness
            %% データ読み込み、トーンマップ
            % area
            load(strcat('../mat/',shape(i),'/',light(1),'/',diffuse(k),'/',roughness(l),'/xyzS.mat'));
            load(strcat('../mat/',shape(i),'/',light(1),'/',diffuse(k),'/',roughness(l),'/xyzD.mat'));
            % トーンマップ
            xyzArea(:,:,:,1) = tonemaping(xyzS,lum);
            xyzArea(:,:,:,2) = tonemaping(xyzD,lum);
            xyzAreaSD = xyzArea(:,:,:,1) + xyzArea(:,:,:,2);
            
            % envmap
            load(strcat('../mat/',shape(i),'/',light(2),'/',diffuse(k),'/',roughness(l),'/xyzS.mat'));
            load(strcat('../mat/',shape(i),'/',light(2),'/',diffuse(k),'/',roughness(l),'/xyzD.mat'));
            % トーンマップ
            xyzEnv(:,:,:,1) = tonemaping(xyzS,lum);
            xyzEnv(:,:,:,2) = tonemaping(xyzD,lum);
            xyzEnvSD = xyzEnv(:,:,:,1) + xyzEnv(:,:,:,2);
            
            clear xyzS xyzD;
            [iy,ix,iz] = size(xyzAreaSD);
            
            %% 色空間変換
            cx2u = makecform('xyz2upvpl');
            cu2x = makecform('upvpl2xyz');
            upvplArea(:,:,:,1) = applycform(xyzArea(:,:,:,1),cx2u);
            upvplArea(:,:,:,2) = applycform(xyzArea(:,:,:,2),cx2u);
            upvplAreaSD = applycform(xyzAreaSD,cx2u);
            upvplEnv(:,:,:,1) = applycform(xyzEnv(:,:,:,1),cx2u);
            upvplEnv(:,:,:,2) = applycform(xyzEnv(:,:,:,2),cx2u);
            upvplEnvSD = applycform(xyzEnvSD,cx2u);   

            %% エリアライト、envmapそれぞれの背景部分の平均輝度を求める
            lumMap = zeros(iy,ix,2); %1:area, 2:envmap
            lumMap(:,:,1) = upvplAreaSD(:,:,3);
            lumMap(:,:,2) = upvplEnvSD(:,:,3);
            
            % 背景部分
            %backMask = ~mask;
            %lumMap = lumMap .* backMask;
            %pixelNum = nnz(backMask);
            
            % オブジェクト部分
            lumMap = lumMap .* mask;
            pixelNum = nnz(mask);

            lumSum = sum(lumMap, [1 2]);
            meanLum = lumSum / pixelNum;
            meanLum = reshape(meanLum, [1,2]); % 平均輝度

            %% それぞれの平均輝度からエリアライトにかける定数を求める
            weight = 1; % envmapの何倍に合わせるか
            proportion = meanLum(2)*weight / meanLum(1);

            %% エリアライトの輝度調整
            upvplArea(:,:,3,:) = upvplArea(:,:,3,:) * proportion;
            
            % 最小輝度を下回る部分の調整
            minMap = upvplArea(:,:,3,:) < monitorMinLum;
            minMapMask = ~minMap;
            minMap = minMap * monitorMinLum;
            upvplArea(:,:,3,:) = upvplArea(:,:,3,:) .* minMapMask + minMap;

            minArea = min(upvplArea(:,:,3,:),[],'all');

            %% データ保存
            % area
            xyzStonemap = applycform(upvplArea(:,:,:,1),cu2x);
            xyzDtonemap = applycform(upvplArea(:,:,:,2),cu2x);
            save(strcat('../mat/',shape(i),'/',light(1),'/',diffuse(k),'/',roughness(l),'/xyzStonemap'),'xyzStonemap');
            save(strcat('../mat/',shape(i),'/',light(1),'/',diffuse(k),'/',roughness(l),'/xyzDtonemap'),'xyzDtonemap');
            
            % envmap
            xyzStonemap = xyzEnv(:,:,:,1);
            xyzDtonemap = xyzEnv(:,:,:,2);
            save(strcat('../mat/',shape(i),'/',light(2),'/',diffuse(k),'/',roughness(l),'/xyzStonemap'),'xyzStonemap');
            save(strcat('../mat/',shape(i),'/',light(2),'/',diffuse(k),'/',roughness(l),'/xyzDtonemap'),'xyzDtonemap');
            
            %% 進行度表示
            progress = progress + 1;
            fprintf('finish : %d/%d\n\n', progress, allObj);
        end
    end
end

                
                