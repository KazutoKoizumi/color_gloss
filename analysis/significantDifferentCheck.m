% 色相間の選考尺度値に有意差があるかをブートストラップサンプルをもとに検定する
%clear all;

exp = 'experiment_gloss';
sn = 'all';

B = 10000; %ブートストラップサンプル数
alpha = 5/8; % 有意水準 (片側検定)、ボンフェローニ補正
bonferroni_alpha = 5/8; % ボンフェローニ補正、無彩色との比較
ubi = round(B*(100-alpha)/100);
lbi = round(B*alpha/100);

load(strcat('../../analysis_result/',exp,'/',sn,'/BSsample.mat'));

% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"];
light = ["area", "envmap"];
diffuse = ["D01", "D03", "D05"];
diffuseVar = [0.1,0.3,0.5];
roughness = ["rough005", "rough01", "rough02"];
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

sampleGlossEffect = zeros(B,108);

for i = 1:shapeNum
    for j = 1:lightNum
        for k = 1:diffuseNum
            for l = 1:roughnessNum
                for m = 1:colorizeNum
                    progress = progress + 1;
                    p = zeros(8,1);
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
                        
                        % ｐ値を求める
                        if n <= 8
                            num = nnz(sdata>=0);
                            p(n) = num/B;
                        end
                        
                        sigDiffTable(count,:) = {shape(i),light(j),diffuseVar(k),roughVar(l),colorizeW(m),colorName(colorPair(n,1)),colorName(colorPair(n,2)),sigDiff};
                        count = count+1;
                    end
                    
                    %{
                    % Holm法で有意差求める
                    p_sort = sort(p);
                    count = count-36;
                    for n = 1:8
                        alpha_holm = 5/(9-n);
                        ubi_holm = round(B*(100-alpha_holm)/100);
                        lbi_holm = round(B*alpha_holm/100);
                        
                        sampleDiff = BSsample(:,1,i,j,k,l,m) - BSsample(:,n+1,i,j,k,l,m);
                        sdata = sort(sampleDiff);
                        upLim = sdata(ubi_holm);
                        lowLim = sdata(lbi_holm);
                        
                        if upLim*lowLim > 0 % 有意差あり
                            sigDiff = 1;
                        else % 有意差なし
                            sigDiff = 0;
                        end
                        
                        sigDiffTable(count,:) = {shape(i),light(j),diffuseVar(k),roughVar(l),colorizeW(m),colorName(colorPair(n,1)),colorName(colorPair(n,2)),sigDiff};
                        count = count + 1;
                    end
                    count = count + 28;
                    %}
                    
                    % 効果量を求める（ブートストラップサンプル10000個分）
                    sampleColorMean = mean(BSsample(:,2:9,i,j,k,l,m),2);
                    sampleGlossEffect(:,progress) = sampleColorMean - BSsample(:,1,i,j,k,l,m);
                    
                    fprintf('analysis progress : %d / %d\n\n', progress, trial);
                end
            end
        end
    end
end

% 効果量が有意に正か検定
sampleGlossEffectMean = mean(sampleGlossEffect,2);
sdata = sort(sampleGlossEffectMean);
lowLim = sdata(B*5/100);
if lowLim > 0
    sigDiffGE = 1;
else
    sigDiffGE = 0;
end

save(strcat('../../analysis_result/',exp,'/',sn,'/sigDiffTable'), 'sigDiffTable');

