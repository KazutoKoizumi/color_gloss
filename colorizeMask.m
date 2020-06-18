%% xyz形式のファイルを読み込み彩色するプログラム
% 彩色の際にマスク処理を行い、オブジェクト部分のみを彩色する
clear all;

% Object
material = 'bunny';
light = 'area';
Drate = 'D01';
alpha = 'alpha005';

load(strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/xyzSD.mat'));
load(strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/xyzD.mat'));
load(strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/xyzS.mat'));
load('../mat/ccmat.mat');
load('../mat/monitorColorMax.mat');
load('../mat/logScale.mat');
load(strcat('../mat/',material,'Mask/mask.mat'));

scale = 0.4;

tonemapImage = zeros(size(xyzSD, 1), size(xyzSD, 2), size(xyzSD, 3), 2);
%tonemapImage(:,:,:,1) = wTonemapDiff(xyzS,xyzSD,1,scale,ccmat); % TonemapS
%tonemapImage(:,:,:,2) = wTonemapDiff(xyzD,xyzSD,1,scale,ccmat); % TonemapD

tonemapImage(:,:,:,1) = tonemaping(xyzS,xyzSD,1,scale,ccmat); % TonemapS
tonemapImage(:,:,:,2) = tonemaping(xyzD,xyzSD,1,scale,ccmat); % TonemapD

maskImage = zeros(size(xyzSD, 1), size(xyzSD, 2), size(xyzSD, 3), 2);
for i = 1:size(xyzSD, 1)
    for j = 1:size(xyzSD, 2)
        if mask(i,j) == 1
            maskImage(i,j,:,1) = tonemapImage(i,j,:,1); % mask S
            maskImage(i,j,:,2) = tonemapImage(i,j,:,2); % mask D
        end
    end
end

backImage = tonemapImage(:,:,:,1) + tonemapImage(:,:,:,2);
coloredSD = colorizeXYZ(maskImage(:,:,:,1)) + colorizeXYZ(maskImage(:,:,:,2));
coloredD = colorizeXYZ(maskImage(:,:,:,2)) + maskImage(:,:,:,1);
aveBrightness = zeros(1,9);

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

for i = 1:9
    %figure;
    wImageXYZ2rgb_wtm(coloredSD(:,:,:,i),ccmat);
    %figure;
    wImageXYZ2rgb_wtm(coloredD(:,:,:,i),ccmat);
end

ss = strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/coloredSD');
sd = strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/coloredD');
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
        %disp(upvpl(400,400,:));
        %disp(i);
        coloredXyzData(:,:,:,i) = applycform(upvpl,cu2x);
    end
end

