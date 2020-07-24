% 彩色ファイル(colored)を刺激用のRGB値に変換する（uint8で保存）
clear all;

load('../mat/ccmat.mat');

% Object
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["alpha005", "alpha01", "alpha02"]; %l
colorizeM = ["SD", "D"];

% stimuli matrix
% low, column, rgb, color, light, diffuse, roughness, SDorD
stimuliBunny = zeros(720, 960, 3, 9, size(light,2), size(diffuse,2), size(roughness,2), size(colorizeM,2), 'uint8');
stimuliDragon = zeros(720, 960, 3, 9, size(light,2), size(diffuse,2), size(roughness,2), size(colorizeM,2), 'uint8');
stimuliBlob = zeros(720, 960, 3, 9, size(light,2), size(diffuse,2), size(roughness,2), size(colorizeM,2), 'uint8');

for i = 1:3
    for j = 1:2
        for k = 1:3
            for l = 1:3
                load(strcat('../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredSD.mat'));
                load(strcat('../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredD.mat'));
                [ix,iy,iz] = size(coloredSD(:,:,:,1));
                stimuliSD = zeros(ix,iy,iz,9);
                stimuliD = zeros(ix,iy,iz,9);
                
                for m = 1:9
                    stimuliSD(:,:,:,m) =  wImageXYZ2rgb_wtm(coloredSD(:,:,:,m),ccmat);
                    stimuliD(:,:,:,m) = wImageXYZ2rgb_wtm(coloredD(:,:,:,m),ccmat);
                end
                
                stimuliSD = cast(stimuliSD, 'uint8');
                stimuliD = cast(stimuliD, 'uint8');
                
                save(strcat('../stimuli/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/stimuliSD.mat'),'stimuliSD');
                save(strcat('../stimuli/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/stimuliD.mat'),'stimuliD');
                
                %{
                figure;
                montage(stimuliSD/255,'size',[3 3]);
                figure;
                montage(stimuliD/255,'size',[3 3]);
                %}
                
                if i == 1
                    stimuliBunny(:,:,:,:,j,k,l,1) = stimuliSD;
                    stimuliBunny(:,:,:,:,j,k,l,2) = stimuliD;
                elseif i == 2
                    stimuliDragon(:,:,:,:,j,k,l,1) = stimuliSD;
                    stimuliDragon(:,:,:,:,j,k,l,2) = stimuliD;
                elseif i == 3
                    stimuliBlob(:,:,:,:,j,k,l,1) = stimuliSD;
                    stimuliBlob(:,:,:,:,j,k,l,2) = stimuliD;
                end
                
                clear coloredSD coloredD stimuliSD stimuliD;
                
                fprintf('%d,%d,%d,%d\n', i,j,k,l);
            end
        end
    end
end

save('../stimuli/stimuliBunny.mat', 'stimuliBunny');
save('../stimuli/stimuliDragon.mat', 'stimuliDragon');
save('../stimuli/stimuliBlob.mat', 'stimuliBlob');