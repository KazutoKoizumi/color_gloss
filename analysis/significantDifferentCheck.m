% 色相間の選考尺度値に有意差があるかをブートストラップサンプルをもとに検定する
clear all;

exp = 'experiment_gloss';
sn = 'all';

B = 10000; %ブートストラップサンプル数
ubi = round(B*97.5/100);
lbi = round(B*2.5/100);

load(strcat('../../analysis_result/',exp,'/',sn,'/BSsample.mat'));

% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"];
light = ["area", "envmap"];
diffuse = ["D01", "D03", "D05"];
diffuseVar = [0.1,0.3,0.5];
roughness = ["alpha005", "alpha01", "alpha02"];
roughVar = [0.05,0.1,0.2];
colorizeW = ["SD", "D"];
colorName = ["gray","red","orange","yellow","green","blue-green","cyan","blue","magenta"];


% 各パラメータの数
shapeNum = size(shape,2); % bunny, dragon, blob
lightNum = size(light,2); % area, envmap
diffuseNum = size(diffuse,2); % 0.1, 0.3, 0.5
roughnessNum = size(roughness,2); % 0.05, 0.1, 0.2
colorizeNum = size(colorizeW,2); % SD, D
color = 1:9;
colorPair = nchoosek(color,2);

% 結果記録用のテーブル
parNum = shapeNum*lightNum*diffuseNum*roughnessNum*colorizeNum*size(colorPair,1);
varTypes = {'string','string','double','double','string','string','string','int8'};
varNames = {'shape','light','diffuse','roughness','colorize','color1','color2','significantDifference'};
sigDiffTable = table('Size',[parNum,8],'VariableTypes',varTypes,'VariableNames',varNames);

count = 1;
trial = 3*2*3*3*2;
progress = 0;

for i = 1:shapeNum
    for j = 1:lightNum
        for k = 1:diffuseNum
            for l = 1:roughnessNum
                for m = 1:colorizeNum
                    for n = 1:size(colorPair,1)
                        sampleDiff = BSsample(:,colorPair(n,1),i,j,k,l,m) - BSsample(:,colorPair(n,2),i,j,k,l,m);
                        
                        sdata = sort(sampleDiff);
                        upLim = sdata(ubi);
                        lowLim = sdata(lbi);
                        
                        if upLim*lowLim > 0 % 有意差あり
                            sigDiff = 1;
                        else % 有意差なし
                            sigDiff = 0;
                        end
                        
                        sigDiffTable(count,:) = {shape(i),light(j),diffuseVar(k),roughVar(l),colorizeW(m),colorName(colorPair(n,1)),colorName(colorPair(n,2)),sigDiff};
                        count = count+1;
                        
                    end
                    progress = progress + 1;
                    fprintf('analysis progress : %d / %d\n\n', progress, trial);
                end
            end
        end
    end
end

save(strcat('../../analysis_result/',exp,'/',sn,'/sigDiffTable'), 'sigDiffTable');

