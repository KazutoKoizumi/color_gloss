% 彩度、輝度を散布図としてプロット（横軸：彩度、縦軸：輝度）
clear all;

% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["0.1", "0.3", "0.5"]; % k
roughness = ["0.05", "0.1", "0.2"]; %l
method = ["SD", "D"];

% size
scatter_sz = 20;
t_sz = 22;
sgt_sz = 22;
label_sz = 22;
ax_sz = 20;

% 読み込み
load('../../mat/colorSatLum/bunnySatLum.mat');
load('../../mat/colorSatLum/dragonSatLum.mat');
load('../../mat/colorSatLum/blobSatLum.mat');

% plot
for i = 1:1 % shape
    for j = 1:1 % light
        for k = 1:1 % diffuse
            f = figure;
            for l = 1:1 % roughness
                for m = 1:2 % method
                    
                    if i == 1
                        data = bunnySatLum(:,:,j,k,l,m);
                    elseif i == 2
                        data = dragonSatLum(:,:,j,k,l,m);
                    elseif i == 3
                        data = blobSatLum(:,:,j,k,l,m);
                    end
                    
                    subplot(1,2,2*(l-1)+m);
                    hold on;
                    
                    %x = maxk(data(:,1),round(size(data,1)*1));
                    %y = maxk(data(:,2),round(size(data,1)*1));
                    scatter(data(:,1),data(:,2),scatter_sz);
                    ax = gca;
                    %scatter(x,y);
                    
                    % title
                    %title(strcat(method(m),'  roughness:',roughness(l)),'FontSize',sgt_sz);
                    
                    % axis
                    xlabel('彩度','FontSize',label_sz);
                    ylabel('輝度','FontSize',label_sz);
                    xlim([0 0.05]);
                    ax.FontSize = ax_sz
                    set(gca, "FontName", "Noto Sans CJK JP");
                    
                    hold off;
                    %clear data;
                end
            end
            %sgtitle(strcat('shape:',shape(i),'   light:',light(j),'   diffuse:',diffuse(k),'  roughness:',roughness(l)),'FontSize',t_sz);
            
            %f.WindowState = 'maximized';
            %graphName = strcat(shape(i),'_',light(j),'_',diffuse(k),'.png');
            %fileName = strcat('../../mat/colorSatLum/graph/',graphName);
            %saveas(gcf, fileName);
        end
    end
end
                
                    
                    
                    
                    
