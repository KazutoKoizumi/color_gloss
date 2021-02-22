% 輝度値にもとづいたマスク処理用の配列を作成する

% Object
material = 'Bunny';

load(strcat('./mat/',material,'Mask/maskImage.mat'));
imageSize = size(maskImage);
mask = zeros(imageSize(1), imageSize(2));

thresholdUp = 3.0;
thresholdDown = 1.5;

for i=1:imageSize(1)
    for j=1:imageSize(2)
        mask(i,j) = maskImage(i,j,2);
        if mask(i,j) > thresholdUp
            mask(i,j) = thresholdUp;
        end
        if mask(i,j) < thresholdDown
            mask(i,j) = 0;
        end
        mask(i,j) = 1 - (mask(i,j) / thresholdUp);
    end
end

save(strcat('./mat/',material,'Mask/maskLuminance.mat'), 'mask');
