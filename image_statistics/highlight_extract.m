%% 輝度閾値を設定してハイライト部分を取り出す
clear all;

%% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["alpha005", "alpha01", "alpha02"]; %l
method = ["SD", "D"];
diffuseN = size(diffuse,2);
roughN = size(roughness,2);
methodN = size(method,2);

allObj = 3*2*3*3*2;
load('../../mat/ccmat.mat');
load('../../mat/highlight/lumThreshold.mat');


%% 輝度閾値
% 


%% ハイライト抽出
%count = 1;
highlightMap = zeros(720,960,2,3,2,3); % highlight or diffuse, shape, light, diffuse

for i = 1:3 % shape
    load(strcat('../../mat/',shape(i),'Mask/mask.mat'));
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:1 % roughnessは最小のもの
                count = 18*(i-1) + 9*(j-1) + 3*(k-1) + l;
                load(strcat('../../mat_analysis/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredD.mat'));
                
                lumMap = coloredD(:,:,2,1);
                lumMap = lumMap .* mask;
                
                % ハイライト領域
                HLmap = lumMap; 
                HLmap(HLmap < lumThreshold(1,count)) = 0;
                HLmap(HLmap ~= 0) = 1;
                HLmap = cast(HLmap,'uint8');
                highlightMap(:,:,1,i,j,k) = HLmap;
                
                % ハイライト周辺のdiffuse領域
                HLnoMap = lumMap;
                HLnoMap(HLnoMap < lumThreshold(2,count) | HLnoMap >= lumThreshold(1,count)) = 0;
                HLnoMap(HLnoMap ~= 0) = 1;
                HLnoMap = cast(HLnoMap,'uint8');
                highlightMap(:,:,2,i,j,k) = HLnoMap;
                
                imageRGB = imageXYZ2RGB(coloredD(:,:,:,2),ccmat);
                HL_RGB = imageRGB .* HLmap;
                HL_RGB(HL_RGB~=0) = 255;
                HLno_RGB = imageRGB .* HLnoMap;
                HLno_RGB(HLno_RGB~=0) = 255;
                
                %{
                figure;
                image(imageRGB);
                title(strcat('shape:',num2str(i),'  light:',num2str(j),'  diffuse:',num2str(k),'  roughness:',num2str(l)));
                figure;
                image(HL_RGB);
                title(strcat('shape:',num2str(i),'  light:',num2str(j),'  diffuse:',num2str(k),'  roughness:',num2str(l)));
                figure;
                image(HLno_RGB);
                title(strcat('shape:',num2str(i),'  light:',num2str(j),'  diffuse:',num2str(k),'  roughness:',num2str(l)));
                %}
                
                %count = count + 1;
                
            end
        end
    end
end

save('../../mat/highlight/highlightMap.mat', 'highlightMap');