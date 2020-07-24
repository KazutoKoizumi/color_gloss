% 背景用のノイズパターンを作る
% x,y : image size
function imageXYZ = backNoise(y,x)
    imageRGB = zeros(y,x,3);
    
    img = randi(255, y,x);
    
    for i = 1:3
        imageRGB(:,:,i) = img;
    end
    
    imageRGB = reshape(imageRGB,[],3)'*257;
    
    LUT = load('../mat/20191108_w.lut');
    rgb = TNT_RGBTorgb_LUT(imageRGB',LUT);
    
    load('../mat/ccmat.mat');
    imageXYZ = TNT_rgb2XYZ(rgb',ccmat);
    imageXYZ = imageXYZ';
    
    imageXYZ = reshape(imageXYZ,y,x,3);
    
end 