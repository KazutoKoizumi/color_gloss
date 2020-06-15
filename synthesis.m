% 黒背景でレンダリングしたオブジェクトに彩色したオブジェクト画像を,背景画像に合成する

% Object
material = 'Bunny';

load(strcat('./mat/',material,'/xyzSD.mat'));
load(strcat('./mat/',material,'/xyzD.mat'));
load(strcat('./mat/',material,'/xyzS.mat'));
load('mat/ccmat.mat');
load('mat/monitorColorMax.mat');
load('mat/logScale.mat');
load('maskBunnyBlackBrightness.mat');

load('./mat/BunnyBlack/coloredSD.mat');

scale = 0.4;
backImage = wTonemapDiff(xyzS,xyzSD,1,scale,ccmat) + wTonemapDiff(xyzD,xyzSD,1,scale,ccmat);

for i = 1:size(xyzSD, 1)
    for j = 1:size(xyzSD, 2)
        if mask(i,j) == 0
            for k = 1:9
                coloredSD(i,j,:,k) = backImage(i,j,:);
                coloredD(i,j,:,k) = backImage(i,j,:);
            end
        end
    end
end

ss = './mat/BunnySynthesis/coloredSD';
save(ss,'coloredSD');
