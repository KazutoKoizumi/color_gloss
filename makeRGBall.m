%% 彩色ファイル(colored)を刺激用のRGB値に変換する（uint8で保存）
clear all;

%% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["rough005", "rough01", "rough02"]; %l
colorizeM = ["SD", "D"];

load('../mat/ccmat.mat');
allObj = 3*2*3*3;
progress = 0;

%% 形状ごとに刺激画像データをまとめる
% low, column, rgb, color, light, diffuse, roughness, SDorD
stimuliBunny = zeros(720, 960, 3, 9, size(light,2), size(diffuse,2), size(roughness,2), size(colorizeM,2), 'uint8');
stimuliDragon = zeros(720, 960, 3, 9, size(light,2), size(diffuse,2), size(roughness,2), size(colorizeM,2), 'uint8');
stimuliBlob = zeros(720, 960, 3, 9, size(light,2), size(diffuse,2), size(roughness,2), size(colorizeM,2), 'uint8');

%% Main
for i = 1:3
    for j = 1:2
        for k = 1:3
            for l = 1:3
                %% データ読み込み
                load(strcat('../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredSD.mat'));
                load(strcat('../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredD.mat'));
                [ix,iy,iz] = size(coloredSD(:,:,:,1));
                stimuliSD = zeros(ix,iy,iz,9);
                stimuliD = zeros(ix,iy,iz,9);
                
                disp([i j k l])
                %% XYZ　-> RGB(uint8) （rgbが0~1を超えていないかチェック）
                for m = 1:9
                    m
                    % TN2
                    %stimuliSD(:,:,:,m) =  imageXYZ2RGB(coloredSD(:,:,:,m),ccmat);
                    %stimuliD(:,:,:,m) = imageXYZ2RGB(coloredD(:,:,:,m),ccmat);
                    
                    % TN3
                    stimuliSD(:,:,:,m) = conv_XYZ2RGB(coloredSD(:,:,:,m));
                    stimuliD(:,:,:,m) = conv_XYZ2RGB(coloredD(:,:,:,m));
                end
                
                stimuliSD = cast(stimuliSD, 'uint8');
                stimuliD = cast(stimuliD, 'uint8');
                
                %% 個別データ保存
                save(strcat('../stimuli/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/stimuliSD.mat'),'stimuliSD');
                save(strcat('../stimuli/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/stimuliD.mat'),'stimuliD');
                
                % 画像表示
                %{
                figure;
                montage(stimuliSD/255,'size',[3 3]);
                figure;
                montage(stimuliD/255,'size',[3 3]);
                %}
                
                %% 形状ごとに刺激画像データをまとめる
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
                
                %% 進行度表示
                progress = progress + 1;
                fprintf('finish : %d/%d\n\n', progress, allObj);
            end
        end
    end
end

%% まとめたデータを保存
%save('../stimuli/stimuliBunny.mat', 'stimuliBunny');
%save('../stimuli/stimuliDragon.mat', 'stimuliDragon');
%save('../stimuli/stimuliBlob.mat', 'stimuliBlob');