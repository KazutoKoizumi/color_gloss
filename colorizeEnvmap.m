%% xyz形式のファイルを読み込み彩色するプログラム
% 照明にenvmapを使用している、envmapの色は消さない、背景部分を黒にして彩色する
clear all;

% Object
material = 'bunny';
light = 'envmap';
Drate = 'D05';
alpha = 'alpha10';
maskName = 'bunny';

load(strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/xyzSD.mat'));
load(strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/xyzD.mat'));
load(strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/xyzS.mat'));
load('../mat/ccmat.mat');
load('../mat/monitorColorMax.mat');
load('../mat/logScale.mat');
load(strcat('../mat/',maskName,'Mask/mask.mat'));

scale = 0.4;

maskImage = zeros(size(xyzSD, 1), size(xyzSD, 2), size(xyzSD, 3), 3);
for i = 1:size(xyzSD, 1)
    for j = 1:size(xyzSD, 2)
        if mask(i,j) == 1
            maskImage(i,j,:,1) = xyzS(i,j,:); % xyzS
            maskImage(i,j,:,2) = xyzD(i,j,:); % xyzD
            maskImage(i,j,:,3) = xyzSD(i,j,:); % xyzSD
        end
    end
end

tonemapImage = zeros(size(xyzSD, 1), size(xyzSD, 2), size(xyzSD, 3), 2);
tonemapImage(:,:,:,1) = wTonemapDiff(maskImage(:,:,:,1),maskImage(:,:,:,3),1,scale,ccmat); % TonemapS
tonemapImage(:,:,:,2) = wTonemapDiff(maskImage(:,:,:,2),maskImage(:,:,:,3),1,scale,ccmat); % TonemapD

coloredSD = colorizeXYZ(tonemapImage(:,:,:,1)) + colorizeXYZ(tonemapImage(:,:,:,2));
coloredD = colorizeXYZ(tonemapImage(:,:,:,2)) + tonemapImage(:,:,:,1);
aveBrightness = zeros(1,9);

for i = 1:9
    %figure;
    wImageXYZ2rgb_wtm(coloredSD(:,:,:,i),ccmat);
    %figure;
    wImageXYZ2rgb_wtm(coloredD(:,:,:,i),ccmat);
end

ss = strcat('../mat/',material,'/',light,'Color/',Drate,'/',alpha,'/coloredSD');
sd = strcat('../mat/',material,'/',light,'Color/',Drate,'/',alpha,'/coloredD');
save(ss,'coloredSD');
save(sd,'coloredD');

function coloredXyzData = colorizeXYZ(xyzMaterial)
    cx2u = makecform('xyz2upvpl');
    cu2x = makecform('upvpl2xyz');
    upvplMaterial = applycform(xyzMaterial,cx2u);
    [iy,ix,iz] = size(xyzMaterial);
    coloredXyzData = zeros(iy,ix,iz,9);
    coloredXyzData(:,:,:,1) = xyzMaterial;
    load('../mat/fixedColorMax.mat');
    load('../mat/upvplWhitePoints.mat');
    weight = ones(2,8);
    saturateMax = fixedColorMax;
    % 0.087 ~ 0.34
    m = zeros(2,8);
    for i = 1:2
        for j = 1:8
            m = max(abs(fixedColorMax(:,i,j)));
            if m ~= 0
                %0.13
                saturateMax(:,i,j) = fixedColorMax(:,i,j)/m*0.13;
            end
        end
    end
    
    %saturateMax
    for i = 1:9
        upvpl = upvplMaterial;
        for j = 1:iy
            for k = 1:ix
                for l = 1:size(fixedColorMax,1)-1
                    if upvpl(j,k,3) > fixedColorMax(l,3,1) && upvplMaterial(j,k,3) < fixedColorMax(l+1,3,1)
                        if i == 1
                            upvpl(j,k,1) = upvplWhitePoints(l,1);
                            upvpl(j,k,2) = upvplWhitePoints(l,2);
                        else
                            if max(abs(fixedColorMax(:,1,i-1))) < max(abs(saturateMax(:,1,i-1)))
                                upvpl(j,k,1) = fixedColorMax(l,1,i-1)+upvplWhitePoints(l,1);
                                upvpl(j,k,2) = fixedColorMax(l,2,i-1)+upvplWhitePoints(l,2);
                            else
                                upvpl(j,k,1) = saturateMax(l,1,i-1)+upvplWhitePoints(l,1);
                                upvpl(j,k,2) = saturateMax(l,2,i-1)+upvplWhitePoints(l,2);
                            end
                        end
                    end
                end
            end
        end
        disp(upvpl(400,400,:));
        disp(i);
        coloredXyzData(:,:,:,i) = applycform(upvpl,cu2x);
    end
end

