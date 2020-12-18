%% H-K効果を説明する線形回帰モデルの作成、ハイライトに対応するH-K効果の算出

load(strcat('../../analysis_result/experiment_HK/all/HKtable.mat'));
exp = 'experiment_HK';
snID = ["A", "B", "C", "D", "E", "F", 'All'];
colorName = ["red","orange","yellow","green","blue-green","cyan","blue","magenta"];

%% 輝度について平均化
HKlum = HKtable(1:24,2:3); % 輝度に関して平均化したH-K効果
for s = 1:6 % subject
    subjectData = zeros(24,5);
    for j = 1:24
        temp = zeros(3,5);
        for k = 1:3 % luminance parameter
            temp(k,:) = HKtable.(3+s)(24*(k-1)+j,:);
        end
        subjectData(j,:) = mean(temp);
    end
    HKlum = addvars(HKlum,subjectData,'NewVariableNames',strcat('subject_',snID(s)));
end
% 被験者ごとの平均
for s = 1:6
    HKlum = addvars(HKlum,mean(HKlum.(2+s),2),'NewVariableNames',strcat('subject_',snID(s),'_mean'));
end
% 被験者ごとのz-score


for i = 1:8 % color
    luminance = repmat(HKtable.lum(HKtable.color==colorName(i)), [30 1]);
    saturation = repmat(HKtable.sat(HKtable.color==colorName(i)), [30 1]);
    HK = zeros(9*30,1);
    for j = 1:6 % subject
        HK_individual = HKtable.(3+j)(repmat(HKtable.color==colorName(i),[1 5]));
        HK(9*5*(j-1)+1:9*5*j) = HK_individual;
    end
    
    X = [ones(size(luminance)), luminance, saturation, luminance.*saturation];
    [b,~,~,~,stats] = regress(HK,X)
    
    % プロット
    figure;
    scatter3(luminance,saturation,HK,'filled');
    hold on;
    lumFit = min(luminance):(max(luminance)-min(luminance))/10:max(luminance);
    satFit = min(saturation):(max(saturation)-min(saturation))/10:max(saturation);
    [LUMFIT,SATFIT] = meshgrid(lumFit,satFit);
    HKFIT = b(1) + b(2)*LUMFIT + b(3)*SATFIT + b(4)*LUMFIT.*SATFIT;
    mesh(LUMFIT,SATFIT,HKFIT)
    xlabel('luminance');
    ylabel('saturation');
    zlabel('H-K effect');
    title(strcat('H-K効果  ',colorName(i)));
    %view(50,10);
    hold off
end