% 画像のuvlからrgb値に変換する

function rgb = conv_upvpl2rgb(upvpl, ccmat)

    cu2x = makecform('upvpl2xyz');
    xyz = applycform(upvpl,cu2x);
    
    [iy,ix,iz] = size(xyz);
    
    xyz = reshape(xyz,[],3)';
    
    rgb = TNT_XYZ2rgb(xyz,ccmat);
    %size(rgb);
    
    LUT = load('../mat/20200729T122706.lut');
    rgb = uint8(TNT_rgb2RGB_LUT(rgb',LUT)/257);
    
    rgb = reshape(rgb,iy,ix,iz);
    
end