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
%sn = "kosone";
sn = ["koizumi", "nohira", "totsuka", "taniguchi", "kosone", "saeki"]; 
N = size(sn,2); % 被験者数
methodName = ["SD", "D"];
colorName = ["red","orange","yellow","green","blue-green","cyan","blue","magenta"];

if N == 1
    dirName = sn(1);
elseif N > 1
    dirName = 'all';
end
mkdir(strcat('../../data/',exp,'/',dirName,'/winTable'));

% method, method, light, diffuse, roughness, color
%mtx = zeros(2,2,2,3,3,8);
OutOfNum = zeros(2,2,2,3,3,8);
NumGreater = zeros(2,2,2,3,3,8);

idx = 0;
for i = 1:2 % light
    for j = 1:3 % diffuse
        for k = 1:3 % roughness
            for l = 1:8 % color
                idx = idx + 1;
                for s = 1:N
                    load(strcat('../../data/',exp,'/',sn(s),'/table_',sn(s)));

                    winMethod = find(methodName == dataTable.win(idx));

                    OutOfNum(1,2,i,j,k,l) = OutOfNum(1,2,i,j,k,l) + 1;
                    OutOfNum(2,1,i,j,k,l) = OutOfNum(2,1,i,j,k,l) + 1;
                    if winMethod == 1
                        NumGreater(winMethod,2,i,j,k,l) = NumGreater(winMethod,2,i,j,k,l) + 1;
                    elseif winMethod == 2
                        NumGreater(winMethod,1,i,j,k,l) = NumGreater(winMethod,1,i,j,k,l) + 1;
                    end
                    
                    clear dataTable;
                end
            end
        end
    end
end

mtx = NumGreater./OutOfNum;

for n = 1:2
    mtx(n,n) = nan;
end

save(strcat('../../data/',exp,'/',dirName,'/winTable/mtx'), 'mtx');
save(strcat('../../data/',exp,'/',dirName,'/winTable/OutOfNum'), 'OutOfNum');
save(strcat('../../data/',exp,'/',dirName,'/winTable/NumGreater'), 'NumGreater');
