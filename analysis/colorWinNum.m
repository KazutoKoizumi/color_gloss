% 各被験者の色ごとの勝利数を求める

clear all;

exp = 'experiment_gloss';
sn = ["koizumi", "nohira", "totsuka", "taniguchi", "saeki", "kosone"]; 
N = size(sn,2); % 被験者数
colorName = ["gray","red","orange","yellow","green","blue-green","cyan","blue","magenta"];
colorNum = size(colorName,2);
varNames = {'subject','color1','color2','color3','color4','color5','color6','color7','color8','color9',};

sn = reshape(sn,[N,1]);
winNum = table(sn);
win = zeros(N,colorNum);
for i = 1:N
    load(strcat('../../data/',exp,'/',sn(i),'/table_',sn(i)));
    for j = 1:9
        win(i,j) = nnz(dataTable.win == colorName(j));   
    end
end

winNum = table(sn,'VariableNames',{'subject'});
for i = 1:9
    winNum = addvars(winNum,win(:,i),'NewVariableNames',colorName(i));
end
