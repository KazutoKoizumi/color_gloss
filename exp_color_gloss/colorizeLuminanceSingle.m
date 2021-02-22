%% xyz形式のファイルを読み込み彩色するプログラム
% 彩色の際にマスク処理を行い、オブジェクト部分のみを彩色する
% 輝度に応じて彩色時の彩度を変える、thresholdの輝度値以下では一定、以上では線形に彩度を落とす
% 一色のみの彩色
% or オブジェクト部分の輝度の
clear all;

% Object
material = 'bunny';
light = 'area';
Drate = 'D01';
alpha = 'alpha02';
tLum = '6'; %3, 6, 7, 10, 15
thresholdLum = 6;
color = 'blue';
colorNum = 7;

load(strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/xyzSD.mat'));
load(strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/xyzD.mat'));
load(strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/xyzS.mat'));
load('../mat/ccmat.mat');
load('../mat/monitorColorMaxKlab.mat');
load('../mat/logScaleKlab.mat');
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
coloredSD = colorizeXYZ(maskImage(:,:,:,1),thresholdLum,colorNum,mask) + colorizeXYZ(maskImage(:,:,:,2),thresholdLum,colorNum,mask);
coloredD = colorizeXYZ(maskImage(:,:,:,2),thresholdLum,colorNum,mask) + maskImage(:,:,:,1);
aveBrightness = zeros(1,9);

cS = colorizeXYZ(maskImage(:,:,:,1),thresholdLum,colorNum,mask) ;
cD = colorizeXYZ(maskImage(:,:,:,2),thresholdLum,colorNum,mask) ;

for i = 1:size(xyzSD, 1)
    for j = 1:size(xyzSD, 2)
        if mask(i,j) == 0
            for k = 1:2
                coloredSD(i,j,:,k) = backImage(i,j,:);
                coloredD(i,j,:,k) = backImage(i,j,:);
                cS(i,j,:,k) = backImage(i,j,:);
                cD(i,j,:,k) = backImage(i,j,:);
            end
        end
    end
end

for i = 1:2
    %figure;
    wImageXYZ2rgb_wtm(coloredSD(:,:,:,i),ccmat);
    %figure;
    wImageXYZ2rgb_wtm(coloredD(:,:,:,i),ccmat);
end

ss = strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/coloredSDlum',tLum,color);
sd = strcat('../mat/',material,'/',light,'/',Drate,'/',alpha,'/coloredDlum',tLum,color);
save(ss,'coloredSD');
save(sd,'coloredD');

function coloredXyzData = colorizeXYZ(xyzMaterial, thresholdLum, color, mask)
    cx2u = makecform('xyz2upvpl');
    cu2x = makecform('upvpl2xyz');
    upvplMaterial = applycform(xyzMaterial,cx2u);
    [iy,ix,iz] = size(xyzMaterial);
    coloredXyzData = zeros(iy,ix,iz,2);
    coloredXyzData(:,:,:,1) = xyzMaterial;
    load('../mat/fixedColorMax.mat');
    load('../mat/upvplWhitePoints.mat');
    saturateMax = zeros(size(fixedColorMax,1), size(fixedColorMax,2));
    saturateMax = fixedColorMax(:,:,color);
    
    maxLum = 25;
    a = 1/(thresholdLum-maxLum);
    b = -maxLum/(thresholdLum-maxLum);
    
    %{
    % 0.087 ~ 0.34
    m = zeros(2,8);
    for i = 1:2
        for j = 1:8
            m = max(abs(fixedColorMax(:,i,j)));
            if m ~= 0
                %0.13
                saturateMax(:,i,j) = fixedColorMax(:,i,j)/m*0.2;
            end
        end
    end
     %}
    
    distriLum = zeros(size(fixedColorMax,1), 2);
    distriLum(:,2) = fixedColorMax(:,3,1);
    for i = 1:iy
        for j = 1:ix
            if mask(i,j) == 1
                for k = 1:size(distriLum,1)-1
                    if upvplMaterial(i,j,3) > distriLum(k,2) && upvplMaterial(i,j,3) < distriLum(k+1,2)
                        distriLum(k,1) = distriLum(k,1) + 1;
                    end
                end
            end
        end
    end
    
    [modeLum, modeLumIndex] = max(distriLum(:,1));
    colorizeSaturation = saturateMax(35,:)
    count = zeros(1,2);
    
    %saturateMax
    for i = 1:2
        upvpl = upvplMaterial;
        for j = 1:iy
            for k = 1:ix
                for l = 1:size(saturateMax,1)-1
                    if upvpl(j,k,3) > saturateMax(l,3) && upvplMaterial(j,k,3) < saturateMax(l+1,3)
                        if i == 1
                            upvpl(j,k,1) = upvplWhitePoints(l,1);
                            upvpl(j,k,2) = upvplWhitePoints(l,2);
                        else
                            f = 1;
                            if upvpl(j,k,3) > thresholdLum
                                f = a * upvpl(j,k,3) + b;
                            end
                            if f < 0
                                f = 0;
                            end
                            %}
                            %if max(abs(fixedColorMax(:,1,i-1))) < max(abs(saturateMax(:,1,i-1)))
                            %    upvpl(j,k,1) = f * fixedColorMax(l,1,i-1)+upvplWhitePoints(l,1);
                            %    upvpl(j,k,2) = f * fixedColorMax(l,2,i-1)+upvplWhitePoints(l,2);
                            %    %disp(upvpl(j,k,:))
                            %else
                            
                            upvpl(j,k,1) = f * saturateMax(l,1)+upvplWhitePoints(l,1);
                            upvpl(j,k,2) = f * saturateMax(l,2)+upvplWhitePoints(l,2);
                            
                            %{
                            if abs(colorizeSaturation(2)) < abs(saturateMax(l,2))
                                upvpl(j,k,1) = f * colorizeSaturation(1)+upvplWhitePoints(l,1);
                                upvpl(j,k,2) = f * colorizeSaturation(2)+upvplWhitePoints(l,2);
                                count(1) = count(1) + 1;
                            else
                                upvpl(j,k,1) = f * saturateMax(l,1)+upvplWhitePoints(l,1);
                                upvpl(j,k,2) = f * saturateMax(l,2)+upvplWhitePoints(l,2);
                                count(2) = count(2) + 1;
                            end
                            %}
                            %end
                        end
                    end
                end
            end
        end
        disp(count)
        coloredXyzData(:,:,:,i) = applycform(upvpl,cu2x);
    end
end

