% ハイライトのHKの大きさのプロット（個人データと回帰式との比較も）
t_sz = 22;
sgt_sz = 20;
label_sz = 14;
ax_sz = 16;
lgd_sz = 16;
colorDeg = ["0", "45", "90", "135", "180", "225", "270", "315"];
sat = [0.0316,0.0388,0.0460];
graphColor = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]];

load('../../mat/HKeffect/cf.mat');
load('../../mat/HKeffect/Rsq.mat');
figure;
for i = 1:8
    subplot(4,2,i);
    
    yHK = cf(1,i) + sat*cf(2,i);
    
    %scatter(sat,HKlum.subject_k_mean(HKlum.color==hue(i)),'filled');
    %hold on;
    %scatter(sat,data_high_lum.HKave(data_high_lum.color==hue(i)),'filled');
    %scatter(sat,data_all.HKall(data_all.color==hue(i)),'filled');
    plot(sat,yHK,'--','Color',graphColor(3,:));
    ax = gca;

    xlabel('彩度','FontSize',label_sz)
    ylabel('H-K効果','FontSize',label_sz)
    xlim([0.03 0.047]);
    ylim([1.2 3]);
    
    lgd = legend({'high lum','subject','all'});
    %lgd.NumColumns = 3;
    lgd.Title.FontWeight = 'normal';
    lgd.FontSize = lgd_sz;
    lgd.Location = 'northeastoutside';

    title(strcat(colorDeg(i),' degree'),'FontSize',sgt_sz);
    ax.FontSize = ax_sz;
    set(gca, "FontName", "Noto Sans CJK JP");
    
    hold off;
end