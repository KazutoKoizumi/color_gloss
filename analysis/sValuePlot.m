%　選考尺度値をプロットする

exp = 'experiment_gloss';
sn = 'preexp_koizumi';

load(strcat('../../analysis_result/',exp,'/',sn,'/sv'));
load(strcat('../../analysis_result/',exp,'/',sn,'errorRange'));

colorNum = [1 2 3 4 5 6 7 8 9];
colorName = ["gray","red","orange","yellow","green","blue-green","cyan","blue","magenta"];
graphColor = [1 0.5 0.5; 0.75 0.75 0.75; 0.5 1 0.5];

% stimuli parameter
shape = ["bunny", "dragon", "blob"];
light = ["area", "envmap"];
diffuse = ["0.1", "0.3", "0.5"];
roughness = ["0.05", "0.1", "0.2"];
method = ["SD", "D"];

% plot
for i =1:3  % shape
    for j = 1:2  % light
        figure;
        for m = 1:2  % colorize(method)
            for k = 1:3  % diffuse
                subplot(2,3,3*(m-1)+k);
                hold on;
                for l = 1:3  % roughness
                    plot(colorNum, sv(:,:,i,j,k,l,m), '--o','Color',graphColor(1:l),'MarkerFaceColor','auto');
                    errorbar(colorNum, errorRange(:,3,i,j,k,l,m), -errorRange(:,3,i,j,k,l,m), errorRange(:,3,i,j,k,l,m), 'Color',graphColou(1:l)); % 68%CI
                    hold on;
                end
                title(strcat(method(m),' diffuse:',diffuse(k),' roughness:',roughness(l)));
                xticklabels(colorName);
                xlabel('色相');
                xlim([0 10]);
                ylabel('選考尺度値');
                ylim([-3 3]);
                hold off;
            end
        end
        sgtitle(strcat('shape:',shape(i),' light:',light(j)));
    end
end