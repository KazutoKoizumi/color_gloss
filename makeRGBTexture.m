load('../mat/ccmat.mat');

materialBunny = 'bunny'; % Object Bunny
materialDragon = 'dragon'; % Object Dragon
materialBlob = 'blob'; %Object Blob
materialSphere = 'sphere'; % Object Sphere

light = 'area'; % light : area or envmap
Drate = 'D01'; % diffuse rate
alpha = 'alpha10'; % roughness parameter

%{
% Dragon
load(strcat('./mat/',materialDragon,'/',SDrate,'/',alpha,'/coloredSD.mat'));
load(strcat('./mat/',materialDragon,'/',SDrate,'/',alpha,'/coloredD.mat'));
[ix,iy,iz] = size(coloredSD(:,:,:,1));
dragonSD = zeros(ix,iy,iz,9);
dragonD = zeros(ix,iy,iz,9);

for i = 1:9
    dragonSD(:,:,:,i) = wImageXYZ2rgb_wtm(coloredSD(:,:,:,i),ccmat);
end
for i = 1:9
    dragonD(:,:,:,i) = wImageXYZ2rgb_wtm(coloredD(:,:,:,i),ccmat);
end
save(strcat('./stimuli/',materialDragon,'/',SDrate,'/',alpha,'/dragonSD.mat'),'dragonSD');
save(strcat('./stimuli/',materialDragon,'/',SDrate,'/',alpha,'/dragonD.mat'),'dragonD');
figure;
montage(dragonSD/255,'size',[3 3]);
figure;
montage(dragonD/255,'size',[3 3]);
%}

%{
% Bunny
load(strcat('./mat/',materialBunny,'/',light,'/',Drate,'/',alpha,'/coloredSD.mat'));
load(strcat('./mat/',materialBunny,'/',light,'/',Drate,'/',alpha,'/coloredD.mat'));
[ix,iy,iz] = size(coloredSD(:,:,:,1));
bunnySD = zeros(ix,iy,iz,9);
bunnyD = zeros(ix,iy,iz,9);

for i = 1:9
    bunnySD(:,:,:,i) = wImageXYZ2rgb_wtm(coloredSD(:,:,:,i),ccmat);
    %wtColorCheck(Dsame);
end

for i = 1:9
    bunnyD(:,:,:,i) = wImageXYZ2rgb_wtm(coloredD(:,:,:,i),ccmat);
    %wtColorCheck(Dsame);
end

save(strcat('./stimuli/',materialBunny,'/',light,'/',Drate,'/',alpha,'/bunnySD.mat'),'bunnySD');
save(strcat('./stimuli/',materialBunny,'/',light,'/',Drate,'/',alpha,'/bunnyD.mat'),'bunnyD');
figure;
montage(bunnySD/255,'size',[3 3]);
figure;
montage(bunnyD/255,'size',[3 3]);
%}

%{
% Blob
load(strcat('./mat/',materialBlob,'/',SDrate,'/',alpha,'/coloredSD.mat'));
load(strcat('./mat/',materialBlob,'/',SDrate,'/',alpha,'/coloredD.mat'));
[ix,iy,iz] = size(coloredSD(:,:,:,1));
blobSD = zeros(ix,iy,iz,9);
blobD = zeros(ix,iy,iz,9);

for i = 1:9
    blobSD(:,:,:,i) = wImageXYZ2rgb_wtm(coloredSD(:,:,:,i),ccmat);
    %wtColorCheck(Dsame);
end

for i = 1:9
    blobD(:,:,:,i) = wImageXYZ2rgb_wtm(coloredD(:,:,:,i),ccmat);
    %wtColorCheck(Dsame);
end

save(strcat('./stimuli/',materialBlob,'/',SDrate,'/',alpha,'/blobSD.mat'),'blobSD');
save(strcat('./stimuli/',materialBlob,'/',SDrate,'/',alpha,'/blobD.mat'),'blobD');
figure;
montage(blobSD/255,'size',[3 3]);
figure;
montage(blobD/255,'size',[3 3]);
%}


% Sphere
load(strcat('../mat/',materialSphere,'/',light,'/',Drate,'/',alpha,'/coloredSD.mat'));
load(strcat('../mat/',materialSphere,'/',light,'/',Drate,'/',alpha,'/coloredD.mat'));
[ix,iy,iz] = size(coloredSD(:,:,:,1));
sphereSD = zeros(ix,iy,iz,9);
sphereD = zeros(ix,iy,iz,9);

for i = 1:9
    sphereSD(:,:,:,i) = wImageXYZ2rgb_wtm(coloredSD(:,:,:,i),ccmat);
end
for i = 1:9
    sphereD(:,:,:,i) = wImageXYZ2rgb_wtm(coloredD(:,:,:,i),ccmat);
end
save(strcat('../stimuli/',materialSphere,'/',light,'/',Drate,'/',alpha,'/sphereSD.mat'),'sphereSD');
save(strcat('../stimuli/',materialSphere,'/',light,'/',Drate,'/',alpha,'/sphereD.mat'),'sphereD');
figure;
montage(sphereSD/255,'size',[3 3]);
figure;
montage(sphereD/255,'size',[3 3]);
%}