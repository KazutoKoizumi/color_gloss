%% xyz形式のファイルを読み込み彩色するプログラム
% 彩色の際に、輝度値にもとづいたマスク処理、彩色を行う
clear all;

% Object
material = 'Bunny';
SDrate = 'S09_D01';
maskName = 'Bunny';

load(strcat('./mat/',material,'/',SDrate,'/xyzSD.mat'));
load(strcat('./mat/',material,'/',SDrate,'/xyzD.mat'));
load(strcat('./mat/',material,'/',SDrate,'/xyzS.mat'));
load('mat/ccmat.mat');
load('mat/monitorColorMax.mat');
load('mat/logScale.mat');
load(strcat('./mat/',maskName,'Mask/maskLuminance.mat'));

scale = 0.4;
%backImage = wTonemapDiff(xyzS,xyzSD,1,scale,ccmat) + wTonemapDiff(xyzD,xyzSD,1,scale,ccmat);
coloredSD = colorizeXYZ(wTonemapDiff(xyzS,xyzSD,1,scale,ccmat),mask) + colorizeXYZ(wTonemapDiff(xyzD,xyzSD,1,scale,ccmat),mask);
coloredD = colorizeXYZ(wTonemapDiff(xyzD,xyzSD,1,scale,ccmat),mask) + wTonemapDiff(xyzS,xyzSD,1,scale,ccmat);
aveBrightness = zeros(1,9);

for i = 1:9
    %figure;
    wImageXYZ2rgb_wtm(coloredSD(:,:,:,i),ccmat);
    %figure;
    wImageXYZ2rgb_wtm(coloredD(:,:,:,i),ccmat);
end

ss = strcat('./mat/',material,'Luminance/',SDrate,'/coloredSD');
sd = strcat('./mat/',material,'Luminance/',SDrate,'/coloredD');
save(ss,'coloredSD');
save(sd,'coloredD');

function coloredXyzData = colorizeXYZ(xyzMaterial, maskL)
    cx2u = makecform('xyz2upvpl');
    cu2x = makecform('upvpl2xyz');
    upvplMaterial = applycform(xyzMaterial,cx2u);
    [iy,ix,iz] = size(xyzMaterial);
    coloredXyzData = zeros(iy,ix,iz,9);
    coloredXyzData(:,:,:,1) = xyzMaterial;
    load('mat/fixedColorMax.mat');
    load('mat/upvplWhitePoints.mat');
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
                                upvpl(j,k,1) = maskL(j,k)*fixedColorMax(l,1,i-1)+upvplWhitePoints(l,1);
                                upvpl(j,k,2) = maskL(j,k)*fixedColorMax(l,2,i-1)+upvplWhitePoints(l,2);
                            else
                                upvpl(j,k,1) = maskL(j,k)*saturateMax(l,1,i-1)+upvplWhitePoints(l,1);
                                upvpl(j,k,2) = maskL(j,k)*saturateMax(l,2,i-1)+upvplWhitePoints(l,2);
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

