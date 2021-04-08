%　grayとの有意差の有無がわかるように選考尺度値をプロットする

exp = 'experiment_gloss';
sn = 'all';

mkdir(strcat('../../analysis_result/',exp,'/',sn,'/graph_sig_diff'));
load(strcat('../../analysis_result/',exp,'/',sn,'/sv.mat'));
load(strcat('../../analysis_result/',exp,'/',sn,'/selectionScale.mat'));
load(strcat('../../analysis_result/',exp,'/',sn,'/sigDiffTable.mat'));

rows = sigDiffTable.color1 == 'gray';
T = sigDiffTable(rows,:);
sa = [-0.1, 0, 0.1];

colorNum = [1 2 3 4 5 6 7 8 9];
colorNum = [colorNum-0.1; colorNum; colorNum+0.1];
colorName = ["gray","red","orange","yellow","green","blue-green","cyan","blue","magenta"];
graphColor = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];

% stimuli parameter
shape = ["bunny", "dragon", "blob"];
light = ["area", "envmap"];
diffuse = ["0.1", "0.3", "0.5"];
diffuseVar = [0.1,0.3,0.5];
roughness = ["0.05", "0.1", "0.2"];
roughVar = [0.05,0.1,0.2];
method = ["SD", "D"];

% max, min value
vMax = max(reshape(max(max(selectionScale)), 1, 108));
vMin = min(reshape(min(min(selectionScale)), 1, 108));
vAbs = max(abs([vMin, vMax]));

% size
t_sz = 22;
sgt_sz = 20;
label_sz = 22;
ax_sz = 20;
lgd_sz = 16;

noSigDiffNum = zeros(1,8);


% plot
for i =1:3  % shape
    for j = 1:2  % light
        f = figure;
        for k = 1:3  % diffuse
            for m = 1:2  % method
                % plot
                subplot(3,2,2*(k-1)+m);
                hold on;
                for l = 1:3  % roughness
                    %plot(colorNum, sv(:,:,i,j,k,l,m), '--o','Color',graphColor(l,:),'MarkerFaceColor','auto');
                    h(l) = errorbar(colorNum(l,1), selectionScale(1,3,i,j,k,l,m), -selectionScale(1,1,i,j,k,l,m), selectionScale(1,2,i,j,k,l,m), '-o','Color',graphColor(l,:));
                    errorbar(colorNum(l,2:9), selectionScale(2:9,3,i,j,k,l,m), -selectionScale(2:9,1,i,j,k,l,m), selectionScale(2:9,2,i,j,k,l,m), '-o','Color',graphColor(l,:)); % 95%CI
                    hold on;
                    
                    % 有意差のある部分を塗りつぶす
                    rows = (T.shape==shape(i) & T.light==light(j) & T.diffuse==diffuseVar(k) & T.roughness==roughVar(l) & T.colorize==method(m));
                    grayT = T(rows,:);
                    for p = 1:8
                        if grayT.significantDifference(p) == 1 % 有意差あり
                            x = find(colorName==grayT.color2(p));
                            plot(x+sa(l),selectionScale(x,3,i,j,k,l,m), 'o', 'Color',graphColor(l,:), 'MarkerFaceColor',graphColor(l,:));
                            
                            noSigDiffNum(p) = noSigDiffNum(p)+1;
                        end
                    end
                end   
                ax = gca;
                        
                % title
                title(strcat(method(m),'  diffuse:',diffuse(k)),'FontSize',sgt_sz);
                
                % axis
                xticks(colorNum(2,:));
                xticklabels({'gray', '0', '45', '90', '135', '180', '225', '270', '315'})
                xlabel('色相 (degree)','FontSize',label_sz);
                xlim([0 10]);
                ylabel('選好尺度値','FontSize',label_sz);
                ylim([-vAbs, vAbs]);
                ax.FontSize = ax_sz;
                
                % legend
                lgd = legend(h, {'0.05', '0.1', '0.2'});
                lgd.NumColumns = 3;
                lgd.Title.String = 'roughness';
                lgd.Title.FontWeight = 'normal';
                lgd.FontSize = lgd_sz;
                %lgd.Location = 'northeastoutside'
                
                hold off;
            end
        end
        %sgtitle(strcat('shape:',shape(i),'   light:',light(j)),'FontSize',t_sz);
        
        
        f.WindowState = 'maximized';
        graphName = strcat(shape(i),'_',light(j),'_sig_diff.png');
        fileName = strcat('../../analysis_result/',exp,'/',sn,'/graph_sig_diff/',graphName);
        %saveas(gcf, fileName);
        %}
    end
end

% 色ごとにgrayとの有意差がない個数
noSigDiffNum = array2table(noSigDiffNum, 'VariableNames',colorName(2:9));
%}
%{
%% 抜粋
% plot
for i =1:1  % shape
    for j = 1:1  % light
        f = figure;
        for k = 2:2  % diffuse
            for m = 1:2  % method
                % plot
                subplot(1,2,m);
                hold on;
                for l = 2:2  % roughness
                    %plot(colorNum, sv(:,:,i,j,k,l,m), '--o','Color',graphColor(l,:),'MarkerFaceColor','auto');
                    h(l) = errorbar(colorNum(l,1), selectionScale(1,3,i,j,k,l,m), -selectionScale(1,1,i,j,k,l,m), selectionScale(1,2,i,j,k,l,m), '-o','Color',graphColor(1,:));
                    errorbar(colorNum(l,2:9), selectionScale(2:9,3,i,j,k,l,m), -selectionScale(2:9,1,i,j,k,l,m), selectionScale(2:9,2,i,j,k,l,m), '-o','Color',graphColor(1,:)); % 95%CI
                    hold on;
                    
                    % 有意差のある部分を塗りつぶす
                    rows = (T.shape==shape(i) & T.light==light(j) & T.diffuse==diffuseVar(k) & T.roughness==roughVar(l) & T.colorize==method(m));
                    grayT = T(rows,:);
                    for p = 1:8
                        if grayT.significantDifference(p) == 1 % 有意差あり
                            x = find(colorName==grayT.color2(p));
                            plot(x+sa(l),selectionScale(x,3,i,j,k,l,m), 'o', 'Color',graphColor(1,:), 'MarkerFaceColor',graphColor(1,:));
                            
                        end
                    end
                end               
                        
                % title
                title(method(m));
                
                % axis
                xticks(colorNum(2,:));
                xticklabels({'gray', '0', '45', '90', '135', '180', '225', '270', '315'});
                xlabel('色相');
                xlim([0 10]);
                ylabel('光沢感（選好尺度値）');
                ylim([-vAbs, vAbs]);
                
                %{
                % legend
                lgd = legend(h, {'0.1', '0.3', '0.5'});
                lgd.NumColumns = 3;
                lgd.Title.String = 'roughness';
                lgd.Title.FontWeight = 'normal';
                %}
                
                hold off;
            end
        end
        sgtitle(strcat('shape:',shape(i),'   light:',light(j),'   diffuse:0.1  roughness:0.1'));
    end
end
%}