% パッチ形状のmatファイルを作成する

load('../../mat/patch/patch.mat');

imageSize = size(patch);
patchMask = zeros(imageSize(1),imageSize(2));

patchLumTrans = patch(:,:,2)';
idx = find(patch(:,:,2)'==0);
y = round(min(idx)/imageSize(2))+1;
x = min(idx)-imageSize(2)*(y-1);

xMax = find(patch(y,:,2)==0, 1, 'last' );
yMax = find(patch(:,x,2)==0, 1, 'last' );

patchMask(y:yMax,x:xMax) = 1;

save('../../mat/patch/patchMask.mat','patchMask');