% SDvsDの実験結果をまとめたテーブルから勝率・対戦数・勝数を出す
% mtx : 勝率
% OutOfNUm : 対戦数
% NumGreater : 勝数

% shape : bunny
% light : 2
% diffuse : 3
% roughness : 3
% color : 8

exp = 'experiment_SDvsD';
sn = 'preexp_koizumi';
methodName = ["SD", "D"];
colorName = ["red","orange","yellow","green","blue-green","cyan","blue","magenta"];

mkdir(strcat('../../data/',exp,'/',sn,'/winTable'));
load(strcat('../../data/',exp,'/',sn,'/table_',sn));

% method, method, light, diffuse, roughness
% colorが異なる結果は同じlight,diffuse,roughnessパラメータのものでまとめる
% （colorごとに結果をまとめて解析するのもやる）
mtx = zeros(2,2,2,3,3);
OutOfNum = zeros(2,2,2,3,3);
NumGreater = zeros(2,2,2,3,3);

idx = 0;
for i = 1:2 % light
    for j = 1:3 % diffuse
        for k = 1:3 % roughness
            for n = 1:8
                idx = idx + 1;
                
                winMethod = find(methodName == dataTable.win(idx));
                
                OutOfNum(1,2,i,j,k) = OutOfNum(1,2,i,j,k) + 1;
                OutOfNum(2,1,i,j,k) = OutOfNum(2,1,i,j,k) + 1;
                if winMethod == 1
                    NumGreater(winMethod,2,i,j,k) = NumGreater(winMethod,2,i,j,k) + 1;
                elseif winMethod == 2
                    NumGreater(winMethod,1,i,j,k) = NumGreater(winMethod,1,i,j,k) + 1;
                end
            end
        end
    end
end

mtx = NumGreater./OutOfNum;

for n = 1:2
    mtx(n,n) = nan;
end

save(strcat('../../data/',exp,'/',sn,'/winTable/mtx'), 'mtx');
save(strcat('../../data/',exp,'/',sn,'/winTable/OutOfNum'), 'OutOfNum');
save(strcat('../../data/',exp,'/',sn,'/winTable/NumGreater'), 'NumGreater');
