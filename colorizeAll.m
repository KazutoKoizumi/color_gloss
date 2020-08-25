%% xyz形式のファイルを読み込み彩色するプログラム
% オブジェクト部分のみを彩色する
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
for i = 1:3  % shape
    load(strcat('../mat/',shape(i),'Mask/mask.mat'));
    for j = 1:2  % light
        for k = 1:3  % diffuse
            for l = 1:3  % roughness
                %{
                % --------- 輝度調整していない場合 -----------------------------
                %% データ読み込み
                load(strcat('../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/xyzSD.mat'));
                load(strcat('../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/xyzS.mat'));
                load(strcat('../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/xyzD.mat'));
                
                %{
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
                %}
                lum = 3.5;
                
                %% トーンマップ
                tonemapImage = zeros(size(xyzSD, 1), size(xyzSD, 2), size(xyzSD, 3), 2);
                tonemapImage(:,:,:,1) = tonemaping(xyzS,lum); % specular
                tonemapImage(:,:,:,2) = tonemaping(xyzD,lum); % diffuse
                
                %% 全体を無色にする
                backNoMask = ones(size(xyzSD, 1), size(xyzSD, 2));
                noColorSpecular = colorizeXYZ(tonemapImage(:,:,:,1),tonemapImage(:,:,:,1),backNoMask,1);
                noColorDiffuse = colorizeXYZ(tonemapImage(:,:,:,2),tonemapImage(:,:,:,2),backNoMask,1);
                % -------------------------------------------------------------
                %}
                
                % --------- 輝度調整している場合 -----------------------------
                %% データ読み込み
                load(strcat('../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/xyzSD.mat'));
                load(strcat('../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/xyzStonemapBack.mat'));
                load(strcat('../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/xyzDtonemapBack.mat'));
                
                %% 全体を無色にする
                backNoMask = ones(size(xyzSD, 1), size(xyzSD, 2));
                noColorSpecular = colorizeXYZ(xyzStonemap,xyzDtonemap,backNoMask,1);
                noColorDiffuse = colorizeXYZ(xyzDtonemap,xyzDtonemap,backNoMask,1);
                % -----------------------------------------------------------
                
                %% SD彩色
                % specularとdiffuseのXYZを加算
                noColorSD = noColorSpecular + noColorDiffuse;
                
                % 彩色
                coloredSD = colorizeXYZ(noColorSD,noColorSD,mask,0);
                
                %% D彩色
                % diffuseに彩色
                colorDiffuse = colorizeXYZ(noColorDiffuse,noColorSD,mask,0);

                % 無彩色specularと彩色diffuseを加算
                coloredD = noColorSpecular + colorDiffuse;
                
                %% データ保存
                ss = strcat('../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredSDBack');
                sd = strcat('../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredDBack');
                save(ss,'coloredSD');
                save(sd,'coloredD');
                
                %% 進行度表示
                progress = progress + 1;
                fprintf('finish : %d/%d\n\n', progress, allObj);
            end
        end
    end
end             
