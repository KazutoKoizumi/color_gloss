% 個人データの表示

exp = 'experiment_gloss';
sn = ["koizumi", "nohira", "totsuka", "taniguchi", "kosone", "saeki"];
snID = ["A", "B", "C", "D", "E", "F", 'All'];
snFile = "individuals";

mkdir(strcat('../../analysis_result/',exp,'/',snFile,'/graph'));

%rows = sigDiffTable.color1 == 'gray';
%T = sigDiffTable(rows,:);
sa = [-0.1, 0, 0.1];
N = size(sn,2);

colorNum = [1 2 3 4 5 6 7 8 9];
colorName = ["gray","red","orange","yellow","green","blue-green","cyan","blue","magenta"];
graphColor = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]; [0.3010 0.7450 0.9330]; [0 0 0]];

% stimuli parameter
shape = ["bunny", "dragon", "blob"];
light = ["area", "envmap"];
diffuse = ["0.1", "0.3", "0.5"];
diffuseVar = [0.1,0.3,0.5];
roughness = ["0.05", "0.1", "0.2"];
roughVar = [0.05,0.1,0.2];
method = ["SD", "D"];

vMax = zeros(1,N+1);
vMin = zeros(1,N+1);
vAbs = zeros(1,N+1);

% plot
for i =1:3  % shape
    for j = 1:2  % light
        for l = 1:3 % roughness
            f = figure;
            for k = 1:3 % diffuse
                for m = 1:2 % method
                    subplot(3,2,2*(k-1)+m);
                    hold on;
                    for s = 1:N+1
                        % individuals or all data
                        if s <= N
                            load(strcat('../../analysis_result/',exp,'/',sn(s),'/sv.mat'));
                            load(strcat('../../analysis_result/',exp,'/',sn(s),'/selectionScale.mat'));
                            load(strcat('../../analysis_result/',exp,'/',sn(s),'/sigDiffTable.mat'));
                            
                            % max, min value 
                            vMax(s) = max(reshape(max(sv),1,108));
                            vMin(s) = min(reshape(min(sv),1,108));
                            vAbs(s) = max(abs([vMin, vMax]));
                            
                            plot(colorNum(1), selectionScale(1,3,i,j,k,l,m),'--o','Color',graphColor(s,:), 'MarkerSize',4);
                            h(s) = plot(colorNum(2:9), selectionScale(2:9,3,i,j,k,l,m),'--o','Color',graphColor(s,:), 'MarkerSize',4);
                        elseif s == N+1
                            load(strcat('../../analysis_result/',exp,'/all/selectionScale.mat'));
                            load(strcat('../../analysis_result/',exp,'/all/sigDiffTable.mat'));
                            
                            % max, min value
                            vMax(s) = max(reshape(max(max(selectionScale)), 1, 108));
                            vMin(s) = min(reshape(min(min(selectionScale)), 1, 108));
                            vAbs(s) = max(abs([vMin, vMax]));
                            
                            errorbar(colorNum(1), selectionScale(1,3,i,j,k,l,m), -selectionScale(1,1,i,j,k,l,m), selectionScale(1,2,i,j,k,l,m), '-o','Color',graphColor(s,:));
                            h(s) = errorbar(colorNum(2:9), selectionScale(2:9,3,i,j,k,l,m), -selectionScale(2:9,1,i,j,k,l,m), selectionScale(2:9,2,i,j,k,l,m), '-o','Color',graphColor(s,:)); % 95%CI
                            h(N+1).LineWidth = 1.5;
                        end
                        
                        rows = sigDiffTable.color1 == 'gray';
                        T = sigDiffTable(rows,:);
                        
                        % plot
                        %errorbar(colorNum(1), selectionScale(1,3,i,j,k,l,m), -selectionScale(1,1,i,j,k,l,m), selectionScale(1,2,i,j,k,l,m), '-o','Color',graphColor(s,:));
                        %h(s) = errorbar(colorNum(2:9), selectionScale(2:9,3,i,j,k,l,m), -selectionScale(2:9,1,i,j,k,l,m), selectionScale(2:9,2,i,j,k,l,m), '-o','Color',graphColor(s,:)); % 95%CI
                        hold on;
                        
                        %{
                        % line, marker
                        if s <= N
                            h(s).LineStyle = '--';
                            h(s).MarkerSize = 5;
                        elseif s == N+1;
                            h(N+1).LineWidth = 1.5;
                        end
                        %}
                        
                        % 有意差のある部分を塗りつぶす
                        rows = (T.shape==shape(i) & T.light==light(j) & T.diffuse==diffuseVar(k) & T.roughness==roughVar(l) & T.colorize==method(m));
                        grayT = T(rows,:);
                        for p = 1:8
                            if grayT.significantDifference(p) == 1 % 有意差あり
                                x = find(colorName==grayT.color2(p));
                                plot(x,selectionScale(x,3,i,j,k,l,m), 'o', 'Color',graphColor(s,:), 'MarkerFaceColor',graphColor(s,:));
                            end
                        end
                        
                        %{
                        % max, min value
                        vMax(s) = max(reshape(max(max(selectionScale)), 1, 108));
                        vMin(s) = min(reshape(min(min(selectionScale)), 1, 108));
                        vAbs(s) = max(abs([vMin, vMax]));
                        %}
                        
                    end                  

                    % title
                    title(strcat(method(m),'  diffuse:',diffuse(k)));

                    % axis
                    xticks(colorNum);
                    xticklabels({'gray', '0', '45', '90', '135', '180', '225', '270', '315'});
                    xlabel('色相');
                    xlim([0 11]);
                    ylabel('選好尺度値');
                    vAbs = max(vAbs);
                    ylim([-vAbs, vAbs]);
                    
                    % legend
                    lgd = legend(h,snID);
                    lgd.Title.String = 'subject';
                    lgd.Title.FontWeight = 'normal';
                    
                    hold off;
                end
            end
            
            sgtitle(strcat('shape:',shape(i),'   light:',light(j), '  roughness:',roughness(l)));
            
            f.WindowState = 'maximized';
            graphName = strcat(shape(i),'_',light(j),'_',roughness(l),'.png');
            fileName = strcat('../../analysis_result/',exp,'/',snFile,'/graph/',graphName);
            saveas(gcf, fileName);
        end
    end
end