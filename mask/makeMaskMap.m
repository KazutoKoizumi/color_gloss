% オブジェクトのマスク処理のためのmatファイルを生成する関数

% Object
material = 'bunny';

load(strcat('../mat/',material,'Mask/maskImage.mat'));
imageSize = size(maskImage);
mask = zeros(imageSize(1), imageSize(2));

% threshold  bunny:1.5, blob:1.0, dragon:1.5, sphere:1.7
threshold = 1.7;

for i=1:imageSize(1)
    for j=1:imageSize(2)
        if maskImage(i,j,2) < threshold
            mask(i,j) = 1;
        end
    end
end

save(strcat('../mat/',material,'Mask/mask.mat'), 'mask');
