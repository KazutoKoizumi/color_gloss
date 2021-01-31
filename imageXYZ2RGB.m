% XYZ値の画像をRGB値に変換する（rgbが0~1を超えていないかチェックあり）
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage: 
%    rgb = XYZ2rgb(XYZ, ccmat);
%   
% Input:  
%   XYZ(image): [iy ix 3]
%   ccmat:  color conversion matrix created by makeccmatrix.m
%
% Output:
%   rgb:    rgb vector or matrices
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 

function rgb = imageXYZ2RGB(XYZ, ccmat)

    [iy,ix,iz] = size(XYZ);

    XYZ = reshape(XYZ,[],3)';
    
    rgb = TNT_XYZ2rgb(XYZ,ccmat);
    
    % 色域を超えていないかチェック
    rgbMax = max(max(rgb,[],2));
    rgbMin = min(min(rgb,[],2));
    
    if (rgbMax > 1) || (rgbMin < 0)
        rgbMax
        rgbMin
        %error('rgb value is outside between 0 and 1');
    end 
    %}
    
    LUT = load('../mat/gamma_lut.lut');
    rgb = uint8(TNT_rgb2RGB_LUT(rgb',LUT)/257);
    
    rgb = reshape(rgb,iy,ix,iz);
end
