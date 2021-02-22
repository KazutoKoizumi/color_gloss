% 彩色関数
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage
%   coloredXYZ = colorizeXYZ(xyzMaterial, flag)
%
% Input
%   xyzMaterial : XYZ data
%   refLuminanceImage : reference luminance to decide saturation
%   mask : mask map
%   flag : if 0 all color, if 1 only gray scale
%
% Output
%   coloredXYZ : colorize XYZ data
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 彩色手順
% 各色相方向について各輝度ごとに最大彩度までの距離を求める
% 輝度ごとに距離が最小となる色相を求め、輝度ごとの彩色距離を決める
% 色相ごとに決めた距離に対応するuv座標を算出して彩色
%
% colorLimit.mでこれらの値を求める


function coloredXYZ = colorizeXYZ(xyzMaterial, refLuminanceImage, mask, flag)
    [iy,ix,iz] = size(xyzMaterial);
    load('../mat/fixedColorMax.mat');
    load('../mat/upvplWhitePoints.mat');
    %load('../mat/D65/fixedColorMaxD65.mat');
    %load('../mat/D65/upvplWhitePointsD65.mat');
    %fixedColorMax = fixedColorMaxD65;
    %upvplWhitePoints = upvplWhitePointsD65;
    
    % 色空間変換
    cx2u = makecform('xyz2upvpl');
    cu2x = makecform('upvpl2xyz');
    upvplMaterial = applycform(xyzMaterial,cx2u);
    upvplReference = applycform(refLuminanceImage,cx2u);
    
    % グレーのみか全色か
    if flag == 1  % 無色のみ
        coloredXYZ = zeros(iy,ix,iz);
        coloredXYZ(:,:,:) = xyzMaterial;
    else
        coloredXYZ = zeros(iy,ix,iz,9);
        coloredXYZ(:,:,:,1) = xyzMaterial;
    end
    
    % 彩色距離(uv座標の変位)読み込み
    load('../mat/saturateColor.mat');
    load('../mat/saturationMax.mat');
    %load('../mat/D65/saturateColorD65.mat');
    %load('../mat/D65/saturationMaxD65.mat');
    %saturateColor = saturateColorD65;
    %saturationMax = saturationMaxD65;
    
    lumStep = saturateColor(:,3,1);  % 輝度
    [~, iMax] = max(saturationMax);
    
    % 彩色
    for i = 1:9
        upvpl = upvplMaterial;
        for j = 1:iy
            for k = 1:ix
                if mask(j,k) == 1

                    % 彩色するピクセルの輝度チェック
                    if upvplReference(j,k,3) <= lumStep(iMax)
                        idx = find(lumStep<upvplReference(j,k,3), 1, 'last');   % ピクセル輝度に対応するインデックス
                        if isempty(idx) == 1
                            idx = 1;
                            %upvpl(j,k,3) = lumStep(idx);
                        end
                    else
                        idx = find(lumStep>upvplReference(j,k,3), 1);
                        if isempty(idx) == 1
                            idx = find(lumStep, 1, 'last');
                            %upvpl(j,k,3) = lumStep(idx);
                        end
                    end

                    % 彩色                
                    if i == 1 % 無色
                        upvpl(j,k,1) = upvplWhitePoints(idx,1);
                        upvpl(j,k,2) = upvplWhitePoints(idx,2);
                    else  % 有色
                        upvpl(j,k,1) = saturateColor(idx,1,i-1) + upvplWhitePoints(idx,1);
                        upvpl(j,k,2) = saturateColor(idx,2,i-1) + upvplWhitePoints(idx,2);
                    end
                end
            end
        end
        
        % 保存
        if flag == 1  % 無色のみ
            coloredXYZ(:,:,:) = applycform(upvpl,cu2x);
            break;
        else
            coloredXYZ(:,:,:,i) = applycform(upvpl,cu2x);
        end
    end
end

