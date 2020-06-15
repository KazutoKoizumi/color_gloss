% colorize.mで生成したmatファイルの確認

% Object
material = 'Bunny_watanabe';

load(strcat('./mat/',material,'/coloredSD.mat'));
load(strcat('./mat/',material,'/coloredD.mat'));

imwrite(coloredSD(:,:,:,5), strcat(material,'SD.png'));
imwrite(coloredD(:,:,:,5), strcat(material,'D.png'));