% 彩色関数
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage
%   coloredXYZ = colorizeXYZ(xyzMaterial, flag)
%
% Input
%   xyzMaterial : XYZ data
%   flag : if 1 all color, if 1 only gray scale
%
% Output
%   coloredXYZ : colorize XYZ data
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function coloredXYZ = colorizeXYZ(xyzMaterial, flag)
    [iy,ix,iz] = size(xyzMaterial);
    load('../mat/fixedColorMax.mat');
    load('../mat/upvplWhitePoints.mat');
    
    % 色空間変換
    cx2u = makecform('xyz2upvpl');
    cu2x = makecform('upvpl2xyz');
    upvplMaterial = applycform(xyzMaterial,cx2u);
    
    % グレーのみか全色か
    if flag == 0
        coloredXYZ = zeros(iy,ix,iz,9);
        coloredXYZ(:,:,:,1) = xyzMaterial;
    elseif flag == 1
        coloredXYZ = zeros(iy,ix,iz);
        coloredXYZ(:,:,:) = xyzMaterial;
    end
    
    % 各色相方向について輝度ごとに最大の彩度までの距離を求める(uvL)
    
    
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
            coloredXYZ(:,:,:,i) = applycform(upvpl,cu2x);
        elseif flag == 1
            coloredXYZ(:,:,:) = applycform(upvpl,cu2x);
            break
        end
        %coloredXyzData(:,:,:,i) = applycform(upvpl,cu2x);
    end
end

