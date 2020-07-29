% wImageXYZ2rgb_wtm
% 
% Calculate XYZ values (0-1) from rgb values (CIE1931 coordinates) 
% without tonemap procedure.
%
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage: 
%    rgb = XYZ2rgb(XYZ, ccmat);
%   
% Input:  
%   XYZ(image): [iy ix 3]
%   lw: parameter of Reinhard function
%   ccmat:  color conversion matrix created by makeccmatrix.m
%
% Output:
%   rgb:    rgb vector or matrices
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 

function rgb = wImageXYZ2rgb_wtm(XYZ, ccmat)

    [iy,ix,iz] = size(XYZ);

    XYZ = reshape(XYZ,[],3)';
    
    rgb = TNT_XYZ2rgb(XYZ,ccmat);
    size(rgb);
    
    %LUT = load('../mat/20191108_w.lut');
    LUT = load('../mat/20200729T122706.lut');
    rgb = uint8(TNT_rgb2RGB_LUT(rgb',LUT)/257);
    
    rgb = reshape(rgb,iy,ix,iz);
    
%     imshow(rgb);

end


