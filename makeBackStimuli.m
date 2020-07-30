% 刺激画像の背景のみの画像（RGB）をつくる
% 無彩色にしたあとにRGBに変換、areaとenvmapをまとめる

clear all;

load('../mat/ccmat.mat');
load('../mat/monitorColorMax.mat');
load('../mat/logScale.mat');

load('../mat/back/backArea.mat');
load('../mat/back/backEnv.mat');

scale = 0.4;
[iy, ix, iz] = size(backArea);

bgStimuli = zeros(iy, ix, iz, 2); % 1:area, 2:envmap
bgStimuli(:,:,:,1) = colorizeXYZ(tonemaping(backArea,backArea,2,scale,ccmat), 1);
bgStimuli(:,:,:,2) = colorizeXYZ(tonemaping(backEnv,backEnv,2,scale,ccmat), 1);

for i= 1:2
    bgStimuli(:,:,:,i) = wImageXYZ2rgb_wtm(bgStimuli(:,:,:,i),ccmat);
end

bgStimuli = cast(bgStimuli, 'uint8');

save('../stimuli/back/bgStimuli.mat', 'bgStimuli');

figure;
montage(bgStimuli, 'size', [1 2]);


function coloredXyzData = colorizeXYZ(xyzMaterial, flag)
    cx2u = makecform('xyz2upvpl');
    cu2x = makecform('upvpl2xyz');
    upvplMaterial = applycform(xyzMaterial,cx2u);
    [iy,ix,iz] = size(xyzMaterial);
    if flag == 0
        coloredXyzData = zeros(iy,ix,iz,9);
        coloredXyzData(:,:,:,1) = xyzMaterial;
    elseif flag == 1
        coloredXyzData = zeros(iy,ix,iz);
        coloredXyzData(:,:,:) = xyzMaterial;
    end
    %coloredXyzData = zeros(iy,ix,iz,9);
    %coloredXyzData(:,:,:,1) = xyzMaterial;
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
                saturateMax(:,i,j) = fixedColorMax(:,i,j)/m*0.2;
            end
        end
    end
    flagLum = 0;
    
    %saturateMax
    for i = 1:9
        upvpl = upvplMaterial;
        for j = 1:iy
            for k = 1:ix
                for l = 1:size(fixedColorMax,1)-1
                    if upvpl(j,k,3) < fixedColorMax(1,3,1)
                        flagLum = 1;
                    end
                    if (upvpl(j,k,3) > fixedColorMax(l,3,1) && upvplMaterial(j,k,3) < fixedColorMax(l+1,3,1)) || (flagLum == 1)
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
                    if flagLum == 1
                        flagLum = 0;
                        break;
                    end
                end
            end
        end
        %disp(upvpl(400,400,:));
        %disp(i);
        if flag == 0
            coloredXyzData(:,:,:,i) = applycform(upvpl,cu2x);
        elseif flag == 1
            coloredXyzData(:,:,:) = applycform(upvpl,cu2x);
            break
        end
        %coloredXyzData(:,:,:,i) = applycform(upvpl,cu2x);
    end
end

