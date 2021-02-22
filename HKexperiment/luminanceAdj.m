%% 背景の輝度・色度設定する関数
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage
%   backImage = luminanceAdj(bgImage,fla_light,lum)
% Input
%   bgImage : 背景画像
%   flag_light : 1:area, 2:envmap
%   lum : トーンマップの輝度
%
% Output
%   backImage : 輝度調整して無彩色にした背景画像
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function backImage = luminanceAdj(bgImage,flag_light,lum)
    backImage = tonemaping(bgImage,lum);
    [iy,ix,iz] = size(bgImage);
    
    load('../../mat/proportion.mat');
    load('../../mat/upvplWhitePoints.mat');
    monitorMinLum = upvplWhitePoints(2,3);
    
    % XYZ -> u'v'l
    cx2u = makecform('xyz2upvpl');
    cu2x = makecform('upvpl2xyz');
    upvplBack = applycform(backImage,cx2u);
    
    if flag_light == 1
        % エリアライトなので輝度調整
        upvplBack(:,:,3) = upvplBack(:,:,3) * proportion;

        % 最小輝度を下回る部分の調整
        minMap = upvplBack(:,:,3) < monitorMinLum;
        minMapMask = ~minMap;
        minMap = minMap * monitorMinLum;
        upvplBack(:,:,3) = upvplBack(:,:,3) .* minMapMask + minMap;

        % u'v'l -> XYZ
        backImage = applycform(upvplBack,cu2x);
    end

    % 無彩色にする
    backNoMask = ones(iy, ix);
    backImage = colorizeXYZ(backImage,backImage,backNoMask,1);

end