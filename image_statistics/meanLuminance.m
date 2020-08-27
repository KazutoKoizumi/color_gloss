%% 平均輝度を求めるプログラム
clear all;

%% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["alpha005", "alpha01", "alpha02"]; %l
method = ["SD", "D"];

Dname = ["0.1", "0.3", "0.5"];
roughName = ["0.05", "0.1", "0.2"];
x = [1 2];

allObj = 3*2*3*3*2;
progress = 0;

meanLum = zeros(3,2,3,3,2);

%% 平均輝度を求める
for i = 1:3 % shape
    load(strcat('../../mat/',shape(i),'Mask/mask.mat'));
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                for m = 1:2 % method
                    % データ読み込み
                    load(strcat('../../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredSD.mat'));
                    load(strcat('../../mat/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredD.mat'));
                    [iy,ix,iz] = size(coloredSD(:,:,:,1));
                    
                    if m == 1
                        lumMap = coloredSD(:,:,2,1);
                    elseif m == 2
                        lumMap = coloredD(:,:,2,1);
                    end
                    
                    % オブジェクト部分のみ
                    lumMap = lumMap .* mask;
                    pixelNum = nnz(mask);
                    
                    % 背景部分
                    %backMask = ~mask;
                    %lumMap = lumMap .* backMask;
                    %pixelNum = nnz(backMask);
                    
                    % 画像全体
                    %pixelNum = nnz(lumMap);
                    
                    lumSum = sum(lumMap, 'all');
                    
                    meanLum(i,j,k,l,m) = lumSum / pixelNum;
                    
                    % 進行度表示
                    progress = progress + 1;
                    fprintf('finish : %d/%d\n\n', progress, allObj);
                end
            end
        end
    end
end

%% Plot
progress = 0;
luminanceMean = zeros(54,2);
for i = 1:3 % shape
    f = figure;
    for k = 1:3 % diffuse
        for l = 1:3 % roughness
            for m = 1:2 % method
                    
                    subplot(3,6,6*(k-1)+2*(l-1)+m);
                    hold on;
                    
                    y = meanLum(i,:,k,l,m); % 1:area, 2:envmap
                    bar(x,y);
                    
                    xticks(x);
                    xticklabels({'area', 'envmap'});
                    xlabel('照明');
                    ylabel('平均輝度');
                    
                    title(strcat(method(m),'  diffuse:',Dname(k),'  roughness:',roughName(l)));
                    
                    hold off;
                    
                    progress = progress + 1;
                    luminanceMean(progress,:) = meanLum(i,:,k,l,m);
                    
            end
        end
    end
    sgtitle(strcat('shape:',shape(i)));
end

luminanceMean = sum(luminanceMean) / 54;



