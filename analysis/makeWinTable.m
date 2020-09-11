% 実験結果をまとめたテーブルから勝率・対戦数・勝数を出す
% mtx : 勝率
% OutOfNUm : 対戦数
% NumGreater : 勝数

exp = 'experiment_gloss';
sn = 'koizumi';
colorName = ["gray","red","orange","yellow","green","blue-green","cyan","blue","magenta"];

mkdir(strcat('../../data/',exp,'/',sn,'/winTable'));
load(strcat('../../data/',exp,'/',sn,'/table_',sn));

% color1, color2, shape, light, diffuse, roughness, colorize(method)
mtx = zeros(9,9,3,2,3,3,2);
OutOfNum = zeros(9,9,3,2,3,3,2);
NumGreater = zeros(9,9,3,2,3,3,2);

idx = 0;
for i = 1:3 % shape
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                for m = 1:2 % colorize(method)
                    for n = 1:36
                        idx = idx + 1;
                        
                        color1 = find(colorName == dataTable.color1(idx));
                        color2 = find(colorName == dataTable.color2(idx));
                        winColor = find(colorName == dataTable.win(idx));

                        OutOfNum(color1,color2,i,j,k,l,m) = OutOfNum(color1,color2,i,j,k,l,m) + 1;
                        OutOfNum(color2,color1,i,j,k,l,m) = OutOfNum(color2,color1,i,j,k,l,m) + 1;
                        if winColor == color1
                            NumGreater(winColor,color2,i,j,k,l,m) = NumGreater(winColor,color2,i,j,k,l,m) + 1;
                        elseif winColor == color2
                            NumGreater(winColor,color1,i,j,k,l,m) = NumGreater(winColor,color1,i,j,k,l,m) + 1;
                        end
                    end
                end
            end
        end
    end
end

mtx = NumGreater./OutOfNum;

for n = 1:9
    mtx(n,n) = nan;
end

save(strcat('../../data/',exp,'/',sn,'/winTable/mtx'), 'mtx');
save(strcat('../../data/',exp,'/',sn,'/winTable/OutOfNum'), 'OutOfNum');
save(strcat('../../data/',exp,'/',sn,'/winTable/NumGreater'), 'NumGreater');
