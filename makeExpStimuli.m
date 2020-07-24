% 彩色済みの刺激を形状ごとに実験用の刺激にまとめる

% Object
shape = ["bunny", "dragon", "blob"];
light = ["area", "envmap"];
diffuse = ["D01", "D03", "D05"];
roughness = ["alpha005", "alpha01", "alpha02"];
colorizeM = ["SD", "D"];

% stimuli matrix
% low, column, rgb, color, light, diffuse, roughness, SDorD
stimuliBunny = zeros(720, 960, 3, 9, size(light,2), size(diffuse,2), size(roughness,2), size(colorizeM,2));
stimuliDragon = zeros(720, 960, 3, 9, size(light,2), size(diffuse,2), size(roughness,2), size(colorizeM,2));
stimuliBlob = zeros(720, 960, 3, 9, size(light,2), size(diffuse,2), size(roughness,2), size(colorizeM,2));

obj = 3; % 1:bunny, 2:dragon, 3:blob

for i = 1:size(light,2)
    for j = 1:size(diffuse,2)
        for k = 1:size(roughness,2)
            load(strcat('../stimuli/',shape(obj),'/',light(i),'/',diffuse(j),'/',roughness(k),'/',shape(obj),'SD.mat'));
            load(strcat('../stimuli/',shape(obj),'/',light(i),'/',diffuse(j),'/',roughness(k),'/',shape(obj),'D.mat'));
            
            if obj == 1
                stimuliBunny(:,:,:,:,i,j,k,1) = bunnySD;
                stimuliBunny(:,:,:,:,i,j,k,2) = bunnyD;
            elseif obj == 2
                stimuliDragon(:,:,:,:,i,j,k,1) = dragonSD;
                stimuliDragon(:,:,:,:,i,j,k,2) = dragonD;
            elseif obj == 3
                stimuliBlob(:,:,:,:,i,j,k,1) = blobSD;
                stimuliBlob(:,:,:,:,i,j,k,2) = blobD;
            end
            
        end
    end
end

if obj == 1
    stimuli = strcat('../stimuli/stimuliBunny.mat');
    save(stimuli, 'stimuliBunny', '-v7.3');
elseif obj == 2
    stimuli = strcat('../stimuli/stimuliDragon.mat');
    save(stimuli, 'stimuliDragon', '-v7.3');
elseif obj == 3
    stimuli = strcat('../stimuli/stimuliBlob.mat');
    save(stimuli, 'stimuliBlob', '-v7.3');
end