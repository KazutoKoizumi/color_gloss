%% xyz形式のファイルを読み込み彩色するプログラム
% 彩色の際にマスク処理を行い、オブジェクト部分のみを彩色する
% 彩色前に色度を白色点に合わせる, 背景の色度も白色点に合わせる
% まとめて彩色
clear all;

%% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["alpha005", "alpha01", "alpha02"]; %l

load('../mat/ccmat.mat');
allObj = 3*2*3*3;
progress = 0;

%% Main
for p = 1:3  % shape
    load(strcat('../mat/',shape(p),'Mask/mask.mat'));
    for q = 1:2  % light
        for r = 1:3  % diffuse
            for s = 1:3  % roughness
                %% データ読み込み
                load(strcat('../mat/',shape(p),'/',light(q),'/',diffuse(r),'/',roughness(s),'/xyzSD.mat'));
                load(strcat('../mat/',shape(p),'/',light(q),'/',diffuse(r),'/',roughness(s),'/xyzD.mat'));
                load(strcat('../mat/',shape(p),'/',light(q),'/',diffuse(r),'/',roughness(s),'/xyzS.mat'));
                
                scale = 0.4;
                if q == 1
                    lum =  2*(r+1);
                elseif q == 2
                    if p == 1
                        lumPar = [2, 2.5, 3];
                    elseif p == 2
                        lumPar = [2.3, 3, 3];
                    elseif p == 3
                        lumPar = [2, 2, 3];
                    end
                    lum = lumPar(r)
                end
                
                %% トーンマップ
                tonemapImage = zeros(size(xyzSD, 1), size(xyzSD, 2), size(xyzSD, 3), 2);
                tonemapImage(:,:,:,1) = tonemaping(xyzS,xyzSD,lum,scale,ccmat); % TonemapS
                tonemapImage(:,:,:,2) = tonemaping(xyzD,xyzSD,lum,scale,ccmat); % TonemapD
                
                %% マスク処理
                maskImage = zeros(size(xyzSD, 1), size(xyzSD, 2), size(xyzSD, 3), 2);
                for i = 1:size(xyzSD, 1)
                    for j = 1:size(xyzSD, 2)
                        if mask(i,j) == 1
                            maskImage(i,j,:,1) = tonemapImage(i,j,:,1); % mask S
                            maskImage(i,j,:,2) = tonemapImage(i,j,:,2); % mask D
                        end
                    end
                end
                
                %% 背景用の彩色
                gray = zeros(size(xyzSD, 1), size(xyzSD, 2), size(xyzSD, 3), 2);
                gray(:,:,:,1) = colorizeXYZ(tonemapImage(:,:,:,1), 1); % S
                gray(:,:,:,2) = colorizeXYZ(tonemapImage(:,:,:,2), 1); % D
                backImage = gray(:,:,:,1) + gray(:,:,:,2); % back : gray image
                
                %% 彩色
                coloredSD = colorizeXYZ(gray(:,:,:,1), 0) + colorizeXYZ(gray(:,:,:,2), 0);
                coloredD = colorizeXYZ(gray(:,:,:,2), 0) + gray(:,:,:,1);
                aveBrightness = zeros(1,9);
                
                %% 彩色画像と背景を合成
                for i = 1:size(xyzSD, 1)
                    for j = 1:size(xyzSD, 2)
                        if mask(i,j) == 0
                            for k = 1:9
                                coloredSD(i,j,:,k) = backImage(i,j,:);
                                coloredD(i,j,:,k) = backImage(i,j,:);
                            end
                        end
                    end
                end
                
                %% データ保存
                ss = strcat('../mat/',shape(p),'/',light(q),'/',diffuse(r),'/',roughness(s),'/coloredSD');
                sd = strcat('../mat/',shape(p),'/',light(q),'/',diffuse(r),'/',roughness(s),'/coloredD');
                save(ss,'coloredSD');
                save(sd,'coloredD');
                
                %% 進行度表示
                progress = progress + 1;
                fprintf('finish : %d/%d\n\n', progress, allObj);
            end
        end
    end
end             
